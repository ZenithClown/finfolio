CREATE TABLE IF NOT EXISTS private.user_transaction (
  transaction_id
    BIGSERIAL
    CONSTRAINT pk_transaction_id PRIMARY KEY,

  account_id
    CHAR(5)
    NOT NULL
    CONSTRAINT fk_trx_ledger_account_id
      REFERENCES public.ledger_account_detail (ledger_account_id)
      ON DELETE SET NULL
      ON UPDATE SET NULL,

  trx_date
    DATE
    NOT NULL,

  trx_type
    CHAR(1)
    NOT NULL
    CONSTRAINT fk_trx_type_id
      REFERENCES meta.transaction_type (type_id)
      ON DELETE SET NULL
      ON UPDATE SET NULL,

  trx_desc
    VARCHAR(512)
    NOT NULL,

  trx_drvd
    VARCHAR(512),

  trx_amount
    NUMERIC(12, 2)
    NOT NULL,

  transfer_method
    VARCHAR(7)
    CONSTRAINT fk_trx_method_name
      REFERENCES meta.transaction_method (method_name)
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
    TIMESTAMP
    NOT NULL
    DEFAULT (timezone('utc', now())),

  updated_at
    TIMESTAMP
)