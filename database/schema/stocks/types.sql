CREATE TYPE stocks.asset_class AS ENUM (
  'EQUITY', 'MUTUAL FUND', 'DEBT', 'COMMODITY', 'OPTION', 'CRYPTO'
);


CREATE TYPE stocks.stock_exchange AS ENUM (
  'NSE', 'BSE'
);
