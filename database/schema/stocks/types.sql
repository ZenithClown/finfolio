CREATE TYPE stocks.asset_class AS ENUM (
  'EQUITY', 'MUTUAL FUND', 'DEBT', 'COMMODITY', 'OPTION', 'CRYPTO'
);


CREATE TYPE stocks.stock_exchange AS ENUM (
  'NSE', 'BSE'
);


CREATE TYPE stocks.public_offering_type  AS ENUM(
  'MAINBOARD IPO', 'SME IPO', 'ReITs IPO', 'InvITs IPO', 'MAINBOARD FPO', 'SME FPO'
);


CREATE TYPE stocks.trade_type AS ENUM ('BUY', 'SELL');


CREATE TYPE stocks.trade_special_flag AS ENUM (
  'BONUS ISSUE', 'RIGHT ISSUE', 'IPO ALLOTTED'
);
