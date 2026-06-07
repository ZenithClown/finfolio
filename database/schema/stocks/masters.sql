/********************************************************************
Master Table for Stocks Data - Extended Schema for Project FINFOLIO

Stocks data are stored for all available assets in the market. Check
more details on GH#8 for more informations.

  SHA-256 HEX Digest for Asset Symbol : Combination is generated from
    ISIN + Stock Exchange ENUM Value; The data is stored in format
    CHAR(64), which is always a ``str.upper()`` formatted data.

Copyright © [2025] Debmalya Pramanik (ZenithClown)
********************************************************************/

CREATE TABLE IF NOT EXISTS stocks.assets_master (
  isin_code
    CHAR(12) NOT NULL
    CONSTRAINT pk_isin_code PRIMARY KEY,

  asset_name
    VARCHAR(128) NOT NULL,

  asset_class
    stocks.asset_class NOT NULL
);


CREATE TABLE IF NOT EXISTS stocks.asset_symbol_master (
  hexdigest
    CHAR(64) NOT NULL
    CONSTRAINT pk_hex_asset_symbol PRIMARY KEY,

  isin_code
    CHAR(12) NOT NULL
    CONSTRAINT fk_asset_symbol_isin
      REFERENCES stocks.assets_master (isin_code)
      ON DELETE CASCADE
      ON UPDATE CASCADE,

  stock_exchange
    stocks.stock_exchange NOT NULL,

  stock_symbol
    VARCHAR(32) NOT NULL,

  -- ..versionadded:: 2026-06-07 [B24] an ISIN may only be symbolised
  -- once per exchange; this guards against accidental duplicate
  -- hexdigest rows for the same (asset, exchange) pair.
  CONSTRAINT uq_asset_symbol_isin_exchange UNIQUE (isin_code, stock_exchange)
);

-- Idempotent variant for upgrade paths (CREATE TABLE IF NOT EXISTS
-- skips the UNIQUE constraint above on an existing table).
ALTER TABLE stocks.asset_symbol_master
  DROP CONSTRAINT IF EXISTS uq_asset_symbol_isin_exchange;
ALTER TABLE stocks.asset_symbol_master
  ADD  CONSTRAINT uq_asset_symbol_isin_exchange UNIQUE (isin_code, stock_exchange);


CREATE TABLE IF NOT EXISTS stocks.historic_public_offering (
  isin_code
    CHAR(12)
    CONSTRAINT fk_public_offering_isin
      REFERENCES stocks.assets_master (isin_code)
      ON DELETE CASCADE
      ON UPDATE CASCADE,

  opening_date
    DATE NOT NULL,

  closing_date
    DATE NOT NULL,

  listing_date
    DATE NOT NULL,

  floor_price
    NUMERIC(12, 2) NOT NULL,

  ceiling_price
    NUMERIC(12, 2) NOT NULL,

  issue_amount_in_cr
    NUMERIC(12, 2),

  po_type
    stocks.public_offering_type NOT NULL,

  -- ..versionchanged:: 2026-06-07 [B22] composite PK so a single ISIN
  -- can carry both an IPO and one or more later FPOs. The previous
  -- design (PK = isin_code) silently blocked legitimate follow-on
  -- offerings.
  CONSTRAINT pk_public_offering PRIMARY KEY (isin_code, po_type, opening_date)
);

-- Upgrade-path: replace the legacy single-column PK if present.
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM pg_constraint
     WHERE conname = 'pk_public_offering_isin'
       AND conrelid = 'stocks.historic_public_offering'::regclass
  ) THEN
    ALTER TABLE stocks.historic_public_offering
      DROP CONSTRAINT pk_public_offering_isin;
    ALTER TABLE stocks.historic_public_offering
      ADD  CONSTRAINT pk_public_offering
      PRIMARY KEY (isin_code, po_type, opening_date);
  END IF;
END $$;
