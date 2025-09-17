CREATE TABLE IF NOT EXISTS stocks.user_transaction (
  transaction_idkey
    BIGINT GENERATED ALWAYS AS IDENTITY
    CONSTRAINT pk_stock_transaction_idkey PRIMARY KEY,

  account_id
    CHAR(5) NOT NULL
    CONSTRAINT fk_strx_ledger_account_id
      REFERENCES public.ledger_account_detail (ledger_account_id)
      ON DELETE SET NULL
      ON UPDATE SET NULL,

  trade_date
    DATE NOT NULL,

  isin_code
    CHAR(12) NOT NULL
    CONSTRAINT fk_strx_isin_code
      REFERENCES stocks.assets_master (isin_code)
      ON DELETE CASCADE
      ON UPDATE CASCADE,

  exchange_name
    stocks.stock_exchange NOT NULL,

  trade_type
    stocks.trade_type NOT NULL,

  trade_quantity
    NUMERIC(12, 2) NOT NULL,

  trade_price
    NUMERIC(12, 2) NOT NULL,

  created_on
    TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

  updated_on
    TIMESTAMPTZ,

  trade_special_flag
    stocks.trade_special_flag
);
