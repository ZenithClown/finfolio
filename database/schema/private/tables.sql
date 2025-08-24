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

  -- ? Fiscal Year & Month are Calculated from Transaction Date
  -- the fields are not triggered when inserted using pd.to_sql(...)
  -- as pandas directly interacts with db at lower level thus, bypass
  -- the defined triggers during bulk insert of records
  trx_fiscalyear
    VARCHAR(12) NOT NULL
    CONSTRAINT ck_fy_pattern CHECK (
      trx_fiscalyear ~* 'F.Y. \d{4}-\d{2}'
    ),

  trx_month
    CHAR(7) NOT NULL
    CONSTRAINT ck_month_pattern CHECK (
      trx_month ~* '\d{4}-\d{2}'
    ),

  trx_type
    meta.transaction_type NOT NULL,

  trx_desc
    VARCHAR(512) NOT NULL,

  trx_amount
    NUMERIC(12, 2) NOT NULL,

  transfer_method
    meta.transaction_method,

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

  CONSTRAINT ck_either_income_or_expense CHECK (
    income_category_head IS NULL
    OR expense_category_head IS NULL
  ),

  CONSTRAINT ck_income_category_strict FOREIGN KEY
    (income_category_head, income_subcategory_head)
    REFERENCES meta.income_subcategory (
      primary_income_category, income_subcategory_name
    )
    ON DELETE SET NULL
    ON UPDATE SET NULL,

  CONSTRAINT ck_expense_category_strict FOREIGN KEY
    (expense_category_head, expense_subcategory_head)
    REFERENCES meta.expense_subcategory (
      primary_expense_category, expense_subcategory_name
    )
    ON DELETE SET NULL
    ON UPDATE SET NULL
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
