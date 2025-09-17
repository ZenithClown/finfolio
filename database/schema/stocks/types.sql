CREATE TYPE stocks.asset_class AS ENUM (
  'EQUITY', 'MUTUAL FUND', 'DEBT', 'COMMODITY', 'OPTION', 'CRYPTO'
);


CREATE TYPE stocks.stock_exchange AS ENUM (
  'NSE', 'BSE'
);


CREATE TYPE stocks.public_offering_type  AS ENUM(
  'MAINBOARD IPO', 'SME IPO', 'ReITs IPO', 'InvITs IPO', 'MAINBOARD FPO', 'SME FPO'
);
