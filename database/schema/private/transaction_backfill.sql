/********************************************************************
Phase 3 §4.1 — One-shot backfill of legacy private.user_transaction
into the new private.transaction_header + private.transaction_line.

-- ..versionadded:: 2026-06-07 [Phase 3] idempotent: each legacy row is
mapped to a deterministic UUID derived from its transaction_idkey, so
re-running this script never duplicates. The legacy table is left in
place for a release cycle as a read-only fallback; once the dashboard
has been re-pointed at the new RPCs (api.post_transaction +
api.net_worth) the legacy table can be dropped in a future migration.

Mapping rules (the only sane interpretation of the legacy fields):

  legacy.trx_type = 'DEPOSIT'
    => header(trx_date, trx_desc, transfer_method, income_category_key)
       line 1: DEBIT  legacy.account_id      legacy.trx_amount
       line 2: CREDIT SYSIN                   legacy.trx_amount

  legacy.trx_type = 'WITHDRAW'
    => header(trx_date, trx_desc, transfer_method, expense_category_key)
       line 1: DEBIT  SYSEX                   legacy.trx_amount
       line 2: CREDIT legacy.account_id      legacy.trx_amount

  legacy.self_account_id IS NOT NULL  (self-transfer)
    => OVERRIDES the second leg: the SYS account is replaced by
       legacy.self_account_id. trx_type still controls debit/credit
       polarity on the user's primary account.

The deferrable balance trigger fires on COMMIT, so we INSERT header
+ both lines in one transaction per legacy row and let the trigger
catch any mistake.

Skips silently if SYSIN/SYSEX are not seeded yet (no ROOT user) — the
caller is expected to seed root + re-run init first.
********************************************************************/

DO $$
DECLARE
  v_legacy        RECORD;
  v_uid           UUID;
  v_counter_acc   CHAR(5);
  v_n_migrated    INTEGER := 0;
  v_n_skipped     INTEGER := 0;
BEGIN
  -- bail out early if system accounts don't exist; nothing to migrate against.
  IF NOT EXISTS (SELECT 1 FROM public.ledger_account_detail WHERE ledger_account_id IN ('SYSIN','SYSEX')) THEN
    RAISE NOTICE 'transaction_backfill: SYSIN/SYSEX not yet seeded; skipping.';
    RETURN;
  END IF;

  FOR v_legacy IN
    SELECT *
      FROM private.user_transaction
     ORDER BY transaction_idkey
  LOOP
    -- Deterministic UUID from the legacy bigint PK so re-runs are idempotent.
    -- Format: 00000000-0000-0000-0000-<12-hex-padded idkey>
    v_uid := ('00000000-0000-0000-0000-' ||
              lpad(to_hex(v_legacy.transaction_idkey), 12, '0'))::UUID;

    -- Skip if already migrated.
    IF EXISTS (SELECT 1 FROM private.transaction_header WHERE transaction_uid = v_uid) THEN
      v_n_skipped := v_n_skipped + 1;
      CONTINUE;
    END IF;

    INSERT INTO private.transaction_header (
      transaction_uid, trx_date, trx_desc, transfer_method,
      income_category_key, expense_category_key,
      created_on, created_by
    ) VALUES (
      v_uid,
      v_legacy.trx_date,
      v_legacy.trx_desc,
      v_legacy.transfer_method,
      v_legacy.income_category_key,
      v_legacy.expense_category_key,
      COALESCE(v_legacy.created_on, CURRENT_TIMESTAMP),
      'backfill'
    );

    -- Determine the counter-party account.
    IF v_legacy.self_account_id IS NOT NULL THEN
      v_counter_acc := v_legacy.self_account_id;
    ELSIF v_legacy.trx_type = 'DEPOSIT' THEN
      v_counter_acc := 'SYSIN';
    ELSE  -- WITHDRAW
      v_counter_acc := 'SYSEX';
    END IF;

    IF v_legacy.trx_type = 'DEPOSIT' THEN
      INSERT INTO private.transaction_line (transaction_uid, account_id, side, amount, created_by)
      VALUES
        (v_uid, v_legacy.account_id, 'DEBIT',  v_legacy.trx_amount, 'backfill'),
        (v_uid, v_counter_acc,       'CREDIT', v_legacy.trx_amount, 'backfill');
    ELSIF v_legacy.trx_type = 'WITHDRAW' THEN
      INSERT INTO private.transaction_line (transaction_uid, account_id, side, amount, created_by)
      VALUES
        (v_uid, v_counter_acc,       'DEBIT',  v_legacy.trx_amount, 'backfill'),
        (v_uid, v_legacy.account_id, 'CREDIT', v_legacy.trx_amount, 'backfill');
    ELSE
      RAISE EXCEPTION 'transaction_backfill: unknown trx_type "%" on legacy idkey %',
                      v_legacy.trx_type, v_legacy.transaction_idkey;
    END IF;

    v_n_migrated := v_n_migrated + 1;
  END LOOP;

  RAISE NOTICE 'transaction_backfill: migrated=%, already-migrated=%', v_n_migrated, v_n_skipped;
END $$;
