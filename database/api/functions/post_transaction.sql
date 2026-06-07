/********************************************************************
Phase 3 §4.1 — api.post_transaction RPC

-- ..versionadded:: 2026-06-07 [Phase 3] UX-friendly write path. Accepts
"I deposited 50000 into account AAA01" style payloads and synthesises
the balanced (header + two lines) pair under the hood. The caller never
has to know about double-entry.

Signature (kept JSON-shaped so PostgREST exposes it as a POST that
takes a single JSON body):

  api.post_transaction(
    p_account_id     CHAR(5),                -- the user-facing account
    p_amount         NUMERIC,                -- always positive
    p_trx_type       meta.transaction_type,  -- DEPOSIT | WITHDRAW
    p_trx_date       DATE DEFAULT CURRENT_DATE,
    p_trx_desc       VARCHAR DEFAULT '',
    p_transfer_method meta.transaction_method DEFAULT NULL,
    p_income_category_key  VARCHAR DEFAULT NULL,
    p_expense_category_key VARCHAR DEFAULT NULL,
    p_counter_account_id   CHAR(5) DEFAULT NULL,  -- self-transfer
    p_idempotency_key      VARCHAR DEFAULT NULL
  ) RETURNS UUID  -- the new transaction_uid

Idempotency:
  * Repeated calls with the same `p_idempotency_key` collapse to a
    single header (UNIQUE constraint on transaction_header).
  * Returns the existing transaction_uid on duplicate, without
    rewriting lines.

Security: SECURITY DEFINER with locked search_path. The body checks
that the authenticated user (from request.jwt.claim.username) owns
the source account; cross-user posting is rejected.

PostgREST URL: POST /rpc/post_transaction
********************************************************************/

CREATE OR REPLACE FUNCTION api.post_transaction(
  p_account_id            CHAR(5),
  p_amount                NUMERIC,
  p_trx_type              meta.transaction_type,
  p_trx_date              DATE                       DEFAULT CURRENT_DATE,
  p_trx_desc              VARCHAR                    DEFAULT '',
  p_transfer_method       meta.transaction_method    DEFAULT NULL,
  p_income_category_key   VARCHAR                    DEFAULT NULL,
  p_expense_category_key  VARCHAR                    DEFAULT NULL,
  p_counter_account_id    CHAR(5)                    DEFAULT NULL,
  p_idempotency_key       VARCHAR                    DEFAULT NULL
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public
AS $$
DECLARE
  v_actor         VARCHAR(64);
  v_owner         VARCHAR(16);
  v_counter       CHAR(5);
  v_uid           UUID;
  v_existing_uid  UUID;
BEGIN
  IF p_amount IS NULL OR p_amount <= 0 THEN
    RAISE EXCEPTION 'post_transaction: amount must be > 0 (got %)', p_amount;
  END IF;

  -- Idempotency: short-circuit on duplicate key.
  IF p_idempotency_key IS NOT NULL THEN
    SELECT transaction_uid INTO v_existing_uid
      FROM private.transaction_header
     WHERE idempotency_key = p_idempotency_key;
    IF v_existing_uid IS NOT NULL THEN
      RETURN v_existing_uid;
    END IF;
  END IF;

  -- Resolve actor + ownership check.
  BEGIN
    v_actor := current_setting('request.jwt.claim.username', true);
  EXCEPTION WHEN OTHERS THEN
    v_actor := NULL;
  END;
  IF v_actor IS NULL OR v_actor = '' THEN
    v_actor := SESSION_USER;
  END IF;

  SELECT account_owner INTO v_owner
    FROM public.ledger_account_detail
   WHERE ledger_account_id = p_account_id;
  IF v_owner IS NULL THEN
    RAISE EXCEPTION 'post_transaction: account % not found', p_account_id;
  END IF;
  IF v_actor <> SESSION_USER AND v_actor NOT IN (
       SELECT managed_username FROM base.get_managed_users(v_owner)
     ) THEN
    -- v_actor is not the owner and is not a manager of the owner
    RAISE EXCEPTION USING
      ERRCODE = 'insufficient_privilege',
      MESSAGE = format('post_transaction: % not authorised on account % (owner=%)',
                       v_actor, p_account_id, v_owner);
  END IF;

  -- Determine counter-party account.
  IF p_counter_account_id IS NOT NULL THEN
    v_counter := p_counter_account_id;
  ELSIF p_trx_type = 'DEPOSIT' THEN
    v_counter := 'SYSIN';
  ELSIF p_trx_type = 'WITHDRAW' THEN
    v_counter := 'SYSEX';
  ELSE
    RAISE EXCEPTION 'post_transaction: trx_type % requires p_counter_account_id', p_trx_type;
  END IF;

  v_uid := gen_random_uuid();

  INSERT INTO private.transaction_header (
    transaction_uid, trx_date, trx_desc, transfer_method,
    income_category_key, expense_category_key, idempotency_key,
    created_by, updated_by
  ) VALUES (
    v_uid, p_trx_date, p_trx_desc, p_transfer_method,
    p_income_category_key, p_expense_category_key, p_idempotency_key,
    v_actor, v_actor
  );

  IF p_trx_type = 'DEPOSIT' THEN
    INSERT INTO private.transaction_line (transaction_uid, account_id, side, amount, created_by)
    VALUES
      (v_uid, p_account_id, 'DEBIT',  p_amount, v_actor),
      (v_uid, v_counter,    'CREDIT', p_amount, v_actor);
  ELSE  -- WITHDRAW
    INSERT INTO private.transaction_line (transaction_uid, account_id, side, amount, created_by)
    VALUES
      (v_uid, v_counter,    'DEBIT',  p_amount, v_actor),
      (v_uid, p_account_id, 'CREDIT', p_amount, v_actor);
  END IF;

  RETURN v_uid;
END
$$;
