CREATE TABLE stocks.assets_master (
  isin_code
    CHAR(12) NOT NULL
    CONSTRAINT pk_isin_code PRIMARY KEY,

  asset_name
    VARCHAR(128) NOT NULL,

  asset_class
    stocks.asset_class NOT NULL
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
