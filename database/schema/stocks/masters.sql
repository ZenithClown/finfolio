CREATE TABLE stocks.assets_master (
  isin_code
    CHAR(12) NOT NULL
    CONSTRAINT pk_isin_code PRIMARY KEY,

  asset_name
    VARCHAR(128) NOT NULL,

  asset_class
    stocks.asset_class NOT NULL
);
