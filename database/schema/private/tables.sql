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
    VARCHAR(7)
    CONSTRAINT fk_trx_method_name
      REFERENCES meta.transaction_method (method_name)
      ON DELETE SET NULL
      ON UPDATE SET NULL,

  income_category_head
    VARCHAR(16)
    CONSTRAINT fk_income_category_head
      REFERENCES meta.income_category (income_category_name)
      ON DELETE SET NULL
      ON UPDATE SET NULL,

  income_subcategory_head
    VARCHAR(48)
    CONSTRAINT fk_income_subcategory_head
      REFERENCES meta.income_subcategory (income_subcategory_name)
      ON DELETE SET NULL
      ON UPDATE SET NULL,

  expense_category_head
    VARCHAR(16)
    CONSTRAINT fk_expense_category_head
      REFERENCES meta.expense_category (expense_category_name)
      ON DELETE SET NULL
      ON UPDATE SET NULL,

  expense_subcategory_head
    VARCHAR(48)
    CONSTRAINT fk_expense_subcategory_head
      REFERENCES meta.expense_subcategory (expense_subcategory_name)
      ON DELETE SET NULL
      ON UPDATE SET NULL,

  created_on
    TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

  updated_on
    TIMESTAMPTZ,

  CONSTRAINT ck_either_income_or_expense CHECK (
    income_category_head IS NULL
    OR expense_category_head IS NULL
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
