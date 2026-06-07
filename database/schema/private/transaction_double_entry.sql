/********************************************************************
Phase 3 §4.1 — Double-Entry Storage

-- ..versionadded:: 2026-06-07 [Phase 3] replaces the single-row-per-event
`private.user_transaction` model with a header + lines structure where
every business event is materialised as one `transaction_header` and
two or more `transaction_line` rows whose debits and credits balance.

Why double-entry?
  * No more "synthetic" sign games in net_worth (DEPOSIT = +, WITHDRAW = -);
    the sign is intrinsic to the entry side and the account's normal side.
  * Self-account transfers and FX become natural (two lines, two
    accounts, two currencies) instead of bolt-on columns.
  * Audit + reversal become trivial: revert one header, both legs
    disappear via FK CASCADE.
  * Industry-standard model (Tally, GnuCash, Beancount, QuickBooks).

Backward compatibility:
  * The legacy `private.user_transaction` table is kept in place for
    this phase as a read-historical fallback. New writes go to the
    header/line pair via `api.post_transaction(...)`. A data backfill
    (database/schema/private/transaction_backfill.sql) copies every
    existing row into the new model on first run, idempotently.

Invariants:
  * Every transaction_header MUST have >= 2 lines.
  * SUM(amount * fx_rate_to_base) of DEBIT lines = SUM of CREDIT lines,
    per transaction_uid. Enforced via deferrable constraint trigger so
    intermediate states inside a single transaction are allowed.
  * amount > 0 always; the sign lives in `side`.
  * currency_code is a 3-letter ISO code; FX rate to base currency is
    captured at write time so historical reports stay stable.

References:
  * CLAUDE.md §4.1 (the spec)
  * CLAUDE.md §4.7 (audit + soft-delete pattern)
********************************************************************/

-- =====================================================================
-- meta.entry_side — the double-entry side enum
-- =====================================================================
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'entry_side') THEN
    CREATE TYPE meta.entry_side AS ENUM ('DEBIT', 'CREDIT');
  END IF;
END $$;

-- =====================================================================
-- private.transaction_header — one row per business event
-- =====================================================================
CREATE TABLE IF NOT EXISTS private.transaction_header (
  transaction_uid
    UUID NOT NULL DEFAULT gen_random_uuid()
    CONSTRAINT pk_transaction_header PRIMARY KEY,

  trx_date
    DATE NOT NULL,

  trx_desc
    VARCHAR(512) NOT NULL,

  transfer_method
    meta.transaction_method,

  -- Categorisation lives on the header (not the line) because a single
  -- business event has one purpose, even if it touches multiple
  -- accounts. Income XOR expense, never both — enforced below.
  income_category_key
    VARCHAR(65)
    CONSTRAINT fk_th_income_category_key
      REFERENCES meta.income_category_master (income_category_key)
      ON DELETE SET NULL
      ON UPDATE SET NULL,

  expense_category_key
    VARCHAR(65)
    CONSTRAINT fk_th_expense_category_key
      REFERENCES meta.expense_category_master (expense_category_key)
      ON DELETE SET NULL
      ON UPDATE SET NULL,

  -- ..versionadded:: 2026-06-07 [F4] idempotency key for api.post_transaction.
  -- UNIQUE so duplicate client retries (same key) collapse to one row.
  idempotency_key
    VARCHAR(64) UNIQUE,

  -- audit columns (§2.2)
  created_on
    TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by
    VARCHAR(16),
  updated_on
    TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by
    VARCHAR(16),

  -- soft-delete columns (§4.7). A deleted header hides itself + its
  -- lines from every read RPC, but stays on disk for audit replay.
  deleted_on
    TIMESTAMPTZ,
  deleted_by
    VARCHAR(16),

  CONSTRAINT ck_th_not_both_income_and_expense CHECK (
    NOT (income_category_key IS NOT NULL AND expense_category_key IS NOT NULL)
  ),

  CONSTRAINT ck_th_soft_delete_pair CHECK (
    (deleted_on IS NULL AND deleted_by IS NULL)
    OR
    (deleted_on IS NOT NULL AND deleted_by IS NOT NULL)
  )
);

-- =====================================================================
-- private.transaction_line — the balanced entries
-- =====================================================================
CREATE TABLE IF NOT EXISTS private.transaction_line (
  line_id
    BIGINT GENERATED ALWAYS AS IDENTITY
    CONSTRAINT pk_transaction_line PRIMARY KEY,

  transaction_uid
    UUID NOT NULL
    CONSTRAINT fk_tl_header
      REFERENCES private.transaction_header (transaction_uid)
      ON DELETE CASCADE
      ON UPDATE CASCADE,

  account_id
    CHAR(5) NOT NULL
    CONSTRAINT fk_tl_account_id
      REFERENCES public.ledger_account_detail (ledger_account_id)
      ON DELETE RESTRICT  -- never silently drop money rows
      ON UPDATE CASCADE,

  side
    meta.entry_side NOT NULL,

  -- 18,6 matches stocks.user_transaction.trade_quantity post-B23 and is
  -- wide enough for sub-rupee currencies (BTC, USD cents, MF unit allotments).
  amount
    NUMERIC(18, 6) NOT NULL,

  -- ..versionadded:: 2026-06-07 [Phase 3 stub] currency + FX. Today both
  -- columns are stubs (default to base currency, fx=1) so Phase 3 can ship
  -- without §4.2. Phase 3.5 will wire meta.currency_master + fx_rate_history.
  currency_code
    CHAR(3) NOT NULL DEFAULT 'INR',
  fx_rate_to_base
    NUMERIC(18, 8) NOT NULL DEFAULT 1,

  -- audit
  created_on
    TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by
    VARCHAR(16),

  CONSTRAINT ck_tl_amount_positive CHECK (amount > 0),
  CONSTRAINT ck_tl_fx_positive     CHECK (fx_rate_to_base > 0)
);

-- Covering indexes (B21-style for the new tables).
CREATE INDEX IF NOT EXISTS ix_transaction_line_transaction_uid
  ON private.transaction_line (transaction_uid);
CREATE INDEX IF NOT EXISTS ix_transaction_line_account_id
  ON private.transaction_line (account_id);
CREATE INDEX IF NOT EXISTS ix_transaction_header_trx_date
  ON private.transaction_header (trx_date)
  WHERE deleted_on IS NULL;

-- =====================================================================
-- Balanced-entry trigger
--
-- Deferrable CONSTRAINT TRIGGER so multi-statement transactions can
-- insert header + first leg + second leg in any order; the balance is
-- only checked at COMMIT time.
-- =====================================================================
CREATE OR REPLACE FUNCTION private.check_transaction_balance()
RETURNS TRIGGER
LANGUAGE plpgsql
SET search_path = pg_catalog, public
AS $$
DECLARE
  v_uid      UUID;
  v_dr_sum   NUMERIC(18, 6);
  v_cr_sum   NUMERIC(18, 6);
  v_n_lines  INTEGER;
BEGIN
  -- TG_OP is INSERT|UPDATE|DELETE on transaction_line.
  -- On DELETE OLD has the relevant uid; on INSERT/UPDATE NEW does.
  IF TG_OP = 'DELETE' THEN
    v_uid := OLD.transaction_uid;
  ELSE
    v_uid := NEW.transaction_uid;
  END IF;

  -- If the header itself has been deleted (CASCADE removed all lines)
  -- there is nothing to balance. Same for fully removed transactions.
  IF NOT EXISTS (SELECT 1 FROM private.transaction_header WHERE transaction_uid = v_uid) THEN
    RETURN NULL;
  END IF;

  SELECT
    COUNT(*),
    COALESCE(SUM(CASE WHEN side = 'DEBIT'  THEN amount * fx_rate_to_base END), 0),
    COALESCE(SUM(CASE WHEN side = 'CREDIT' THEN amount * fx_rate_to_base END), 0)
  INTO v_n_lines, v_dr_sum, v_cr_sum
  FROM private.transaction_line
  WHERE transaction_uid = v_uid;

  IF v_n_lines < 2 THEN
    RAISE EXCEPTION USING
      ERRCODE = 'check_violation',
      MESSAGE = format('transaction_uid %s has %s line(s); double-entry requires >= 2',
                       v_uid, v_n_lines);
  END IF;

  -- Compare in base-currency NUMERIC; 6 dp tolerance matches column scale.
  IF ROUND(v_dr_sum, 6) <> ROUND(v_cr_sum, 6) THEN
    RAISE EXCEPTION USING
      ERRCODE = 'check_violation',
      MESSAGE = format('transaction_uid %s is unbalanced: debit=%s credit=%s (base ccy)',
                       v_uid, v_dr_sum, v_cr_sum);
  END IF;

  RETURN NULL;
END
$$;

-- Drop+recreate so the trigger picks up any function-signature change
-- on subsequent re-runs (idempotent).
DROP TRIGGER IF EXISTS trg_check_transaction_balance ON private.transaction_line;
CREATE CONSTRAINT TRIGGER trg_check_transaction_balance
  AFTER INSERT OR UPDATE OR DELETE
  ON private.transaction_line
  DEFERRABLE INITIALLY DEFERRED
  FOR EACH ROW
  EXECUTE FUNCTION private.check_transaction_balance();

-- =====================================================================
-- Touch updated_on on header UPDATE (reuse public.onupdate()).
-- =====================================================================
DROP TRIGGER IF EXISTS trg_transaction_header_onupdate ON private.transaction_header;
CREATE TRIGGER trg_transaction_header_onupdate
  BEFORE UPDATE ON private.transaction_header
  FOR EACH ROW
  EXECUTE FUNCTION public.onupdate();
