/********************************************************************
Initialization File for Extended Schema : Stocks Table

The stocks table are optional to use and is thus available under a
special schema. Check the database/initialize.sql for more details on
setting the configurations.

  -- ..versionadded:: 2025-09-17 add the ``stocks`` schema for market

Optional schemas can be initialized and tables added into the database
if the extension is required by the end user. This must be provided
in a dropdown to take necessary actions during setup.

The stocks schema represents stocks market data (mutual funds, shares,
etc.) which can be tracked and analyzed.

Copywright © [2025] Debmalya Pramanik (ZenithClown)
********************************************************************/

CREATE SCHEMA stocks;

-- ? create tables and seed data in below sequence
\i database/schema/stocks/types.sql
\i database/schema/stocks/masters.sql
\i database/schema/stocks/transactions.sql
