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

  -- ..versionchanged:: 2026-06-07 [B23] widen trade_quantity. Mutual
  -- fund units (and fractional ETF holdings) routinely carry 3-4
  -- decimals; NUMERIC(12,2) silently truncated. Bumped to (18,6) to
  -- match AMFI NAV precision (4 dp) with headroom for crypto-style
  -- assets later.
  trade_quantity
    NUMERIC(18, 6) NOT NULL,

  trade_price
    NUMERIC(12, 2) NOT NULL,

  created_on
    TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

  updated_on
    TIMESTAMPTZ,

  trade_special_flag
    stocks.trade_special_flag
);

-- ..versionadded:: 2026-06-07 [B23] idempotent widening for upgrades.
-- Lossless on PG (just rewrites pg_attribute).
-- ..versionchanged:: 2026-06-08 [Phase 4] skip the ALTER when the column
-- is already NUMERIC(18,6) — otherwise Postgres refuses with
-- "cannot alter type of a column used by a view or rule" because
-- api.mv_holdings_vw (Phase 4) references this column on second init.
DO $$
DECLARE
    v_precision INTEGER;
    v_scale     INTEGER;
BEGIN
    SELECT numeric_precision, numeric_scale
      INTO v_precision, v_scale
      FROM information_schema.columns
     WHERE table_schema = 'stocks'
       AND table_name   = 'user_transaction'
       AND column_name  = 'trade_quantity';

    IF v_precision <> 18 OR v_scale <> 6 THEN
        ALTER TABLE stocks.user_transaction
          ALTER COLUMN trade_quantity TYPE NUMERIC(18, 6);
    END IF;
END $$;
