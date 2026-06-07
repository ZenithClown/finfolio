CREATE TABLE IF NOT EXISTS private.user_transaction (
  transaction_idkey
    BIGINT GENERATED ALWAYS AS IDENTITY
    CONSTRAINT pk_transaction_idkey PRIMARY KEY,

  account_id
    CHAR(5) NOT NULL
    CONSTRAINT fk_trx_ledger_account_id
      REFERENCES public.ledger_account_detail (ledger_account_id)
      ON DELETE SET NULL
      ON UPDATE SET NULL,

  trx_date
    DATE NOT NULL,

  trx_type
    meta.transaction_type NOT NULL,

  trx_desc
    VARCHAR(512) NOT NULL,

  trx_amount
    NUMERIC(12, 2) NOT NULL,

  transfer_method
    meta.transaction_method,

  income_category_key
    VARCHAR(65)
    CONSTRAINT fk_income_category_key
      REFERENCES meta.income_category_master (income_category_key)
      ON DELETE SET NULL
      ON UPDATE SET NULL,

  expense_category_key
    VARCHAR(65)
    CONSTRAINT fk_expense_category_key
      REFERENCES meta.expense_category_master (expense_category_key)
      ON DELETE SET NULL
      ON UPDATE SET NULL,

  -- ..versionadded:: 2025-08-24 Self Account Transactions
  -- A self account transfer is from one account to another for the
  -- same person, typically useful for tracking credit card payments,
  -- and/or calculations of rewards from merchants, etc.
  self_account_id
    CHAR(5)
    CONSTRAINT fk_self_account_id
      REFERENCES public.ledger_account_detail (ledger_account_id)
      ON DELETE SET NULL
      ON UPDATE SET NULL
    CONSTRAINT ck_self_account_id CHECK (
      self_account_id != account_id
    ),

  created_on
    TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

  updated_on
    TIMESTAMPTZ,

  -- ..versionchanged:: 2026-06-07 [B1] reference correct column names
  -- (real columns end in `_key`, not `_head`) and enforce the original
  -- design intent: a row may be categorised as income XOR expense, OR
  -- left uncategorised (e.g. freshly-imported bank rows pending
  -- classification). The previous draft of this fix was too strict and
  -- blocked uncategorised inserts; relaxed here. See CLAUDE.md §6 [B1].
  CONSTRAINT ck_not_both_income_and_expense CHECK (
    NOT (income_category_key IS NOT NULL AND expense_category_key IS NOT NULL)
  )
);


CREATE TABLE IF NOT EXISTS private.user_points_transaction (
  pts_transaction_idkey
    BIGINT GENERATED ALWAYS AS IDENTITY
    CONSTRAINT pk_points_transaction_idkey PRIMARY KEY,

  account_id
    CHAR(5) NOT NULL
    CONSTRAINT fk_points_ledger_account_id
      REFERENCES public.ledger_account_detail (ledger_account_id)
      ON DELETE SET NULL
      ON UPDATE SET NULL,

  trx_date
    DATE NOT NULL,

  trx_type
    meta.points_transaction_type NOT NULL,

  trx_desc
    VARCHAR(512) NOT NULL,

  trx_points_amount
    NUMERIC(12, 2) NOT NULL,

  created_on
    TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

  updated_on
    TIMESTAMPTZ
);
