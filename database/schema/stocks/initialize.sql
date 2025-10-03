/********************************************************************
Initialization File for Extended Schema : Stocks Table

The stocks table are optional to use and is thus available under a
special schema. Check the database/initialize.sql for more details on
setting the configurations.

Copywright © [2025] Debmalya Pramanik (ZenithClown)
********************************************************************/

CREATE SCHEMA stocks;

-- ? create tables and seed data in below sequence
\i database/schema/stocks/types.sql
\i database/schema/stocks/masters.sql
\i database/schema/stocks/transactions.sql
