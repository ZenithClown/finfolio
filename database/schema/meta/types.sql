/********************************************************************
ENUM Data Types for Static Small Data Types - Self Explanatory

The enum data type is handy to define a small set of static data which
is unlikely to change and the values are finite. The enum provides
data integrity and readibility and the name(s) defined are self
explanatory and are index friendly.

-- ..versionchanged:: 2026-06-07 [B11] wrap ENUM creation in DO blocks
so that re-running the initializer does not abort with
"type ... already exists". PostgreSQL has no CREATE TYPE IF NOT EXISTS.

Copywright © [2024] Debmalya Pramanik
********************************************************************/

DO $$ BEGIN
  CREATE TYPE meta.user_role AS ENUM ('ROOT', 'SUDO', 'USER');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE meta.transaction_type AS ENUM ('DEPOSIT', 'WITHDRAW');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE meta.points_transaction_type AS ENUM (
    'EARNED', 'SPENT', 'ADJUSTED', 'LAPSED'
  );
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
  CREATE TYPE meta.transaction_method AS ENUM (
    'NEFT', 'IMPS', 'RTGS', 'UPI', 'MANDATE', 'CASH', 'CREDIT', 'NACH'
  );
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
