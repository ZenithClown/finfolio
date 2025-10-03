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
    VARCHAR(32) NOT NULL
);


CREATE TABLE IF NOT EXISTS stocks.historic_public_offering (
  isin_code
    CHAR(12)
    CONSTRAINT pk_public_offering_isin PRIMARY KEY
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
    stocks.public_offering_type NOT NULL
);
