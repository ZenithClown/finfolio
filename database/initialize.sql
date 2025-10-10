/********************************************************************
Personal Finance DB (finfolio) Initialization Statement (PostgreSQL)

The initialize statement for getting started with the personal finance
management application. The table structure are defined under the
``database/schema`` directory, while the initial seed data are defined
under the ``database/seed`` directory.

The system is so defined that it is upto an end user to maintain the
security of the tables and data. The owner/maintainer of the project
is not responsible for any data loss or data corruption and should not
be held liable for any data leakage.

.. code-block:: sql

  CREATE DATABASE finfolio WITH
    OWNER = postgres
    ENCODING = 'UTF8'
    CONNECTION LIMIT = -1;

Author  : Debmalya Pramanik
Contact : dpramanik.official@gmail.com

Copywright © [2024] Debmalya Pramanik (ZenithClown)
********************************************************************/

CREATE SCHEMA meta; -- schema for configuration values
CREATE SCHEMA private; -- schema to hold user transaction values

/********************************************************************
  API Schema Namespace for PostgREST Configuration - RESTful API

PostgREST configuration is set on the default schema namespace `api`
for all types of queries, stored procedures, functions, etc. Check the
configuration file for more details and usages.
********************************************************************/

CREATE SCHEMA api; -- default endpoints for rest api

/********************************************************************
  Optional Schema Namespace(s) - Create and/not Initialize Schema

Optional schemas can be initialized and tables added into the database
if the extension is required by the end user. This must be provided
in a dropdown to take necessary actions during setup.

  -- ..versionadded:: 2025-09-17 add the ``stocks`` schema for market

The stocks schema represents stocks market data (mutual funds, shares,
etc.) which can be tracked and analyzed.
********************************************************************/

CREATE SCHEMA stocks;

/********************************************************************
  Order of Initialization of the Schema Objects
********************************************************************/

-- ? create master tables, typically under the ``meta`` schema
\i database/schema/meta/types.sql
\i database/schema/meta/tables.sql

-- ? create public tables, typically under the ``public`` schema
\i database/schema/public/tables.sql

\i database/schema/public/functions/fiscalyear.sql
\i database/schema/public/functions/onupdate.sql

-- ? create private tables, typically under the ``private`` schema
\i database/schema/private/tables.sql

\i database/schema/private/functions/set_datefields.sql
\i database/schema/private/triggers/user_transaction.sql
\i database/schema/private/triggers/user_points_transaction.sql

-- ? populate all the tables with the seed data, only allow when all
-- the above table creation succeds then proceed for constraint checks
\i database/schema/meta/seed.sql
