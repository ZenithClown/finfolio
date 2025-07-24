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

Author  : Debmalya Pramanik
Contact : dpramanik.official@gmail.com

Copywright © [2024] Debmalya Pramanik (ZenithClown)
********************************************************************/

CREATE DATABASE finfolio WITH
  OWNER = postgres
  ENCODING = 'UTF8'
  CONNECTION LIMIT = -1;

-- ? as per documentation, the following schemas are created in db
-- postgres default schema is `public` and usage is still under dev.
CREATE SCHEMA meta; -- schema for configuration values
CREATE SCHEMA private; -- schema to hold user transaction values

-- ? create master tables, typically under the ``meta`` schema
\i database/schema/meta/types.sql
\i database/schema/meta/tables.sql

\i database/schema/meta/seed.sql

-- ? create public tables, typically under the ``public`` schema
\i database/schema/public.sql

-- ? create private tables, typically under the ``private`` schema
\i database/schema/private.sql
