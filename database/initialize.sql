/********************************************************************
Personal Finance DB (finfolio) Initialization Statement (PostgreSQL)

The initialize statement for getting started with the personal finance
management application. The table structure are defined under the
``database/schema`` directory, while the initial seed data are defined
under respective schemas ``database/schema/<name>/seed.sql`` files.

-- #region:: Legal Disclaimer
The system is so defined that it is upto an end user to maintain the
security of the tables and data. The owner/maintainer of this project
is not responsible for any data loss or data corruption and should not
be held liable for any data leakage.
-- #endregion

-- #region:: DB Init Script
The initialization script creates the database ``finfolio`` and the
underlying required schemas is as below.

.. code-block:: sql

  CREATE DATABASE finfolio WITH
    OWNER = postgres
    ENCODING = 'UTF8'
    CONNECTION LIMIT = -1;

Once the database is created, the initialization script can be
executed from the command line to initialize the database, underlying
tables and seed data.

.. code-block:: bash

  $ psql -U postgres -d finfolio -f database/initialize.sql

-- #endregion

Author  : Debmalya Pramanik
Contact : dpramanik.official@gmail.com

Copywright © [2024] Debmalya Pramanik (ZenithClown)
********************************************************************/

CREATE SCHEMA IF NOT EXISTS meta;
CREATE SCHEMA IF NOT EXISTS private;

/********************************************************************
  Required Extensions

-- ..versionadded:: 2026-06-07 [B9] declare required PostgreSQL extensions
explicitly. Without `pgcrypto` the cluster lacks `crypt()` and
`gen_salt()`, which are used by user creation and `api.login` for
bcrypt password hashing. Without it those calls fail at runtime with
"function crypt(text, text) does not exist".

`gen_random_uuid()` used by `public.ledger_account_detail` is a builtin
since PostgreSQL 13 and does not require an extension. We still declare
`pgcrypto` first so older clusters degrade gracefully.
********************************************************************/

CREATE EXTENSION IF NOT EXISTS pgcrypto;

/********************************************************************
  API Schema Namespace for PostgREST Configuration - RESTful API

-- #region:: Add. Details
PostgREST configuration is set on the default schema namespace `api`
for all types of queries, stored procedures, functions, etc. Check the
configuration file for more details and usages.
-- #endregion
********************************************************************/

CREATE SCHEMA IF NOT EXISTS api;

/********************************************************************
  BASE Schema Namespace for API Configuration using PostgREST

-- #region:: Add. Details
The PostgREST exposes all tables, views, functions and other objects
by default under the exposed schema. The same can be restricted by
using - (I) role base login systems, (II) creating different users
with different permissions, etc. The ``base`` schema namespace is
defined to expose functions/objects which is used by the API but is
not directly required or should not be exposed to the user.
-- #endregion
********************************************************************/

CREATE SCHEMA IF NOT EXISTS base;

-- ..versionadded:: 2026-06-07 [B27] wire previously-orphaned base/api
-- functions into the initializer. Prior to this fix:
--   - base/get_managed_users.sql was never loaded
--   - api/functions/*.sql were never loaded
--   - api/security/*.sql were never loaded
-- ...so all RPC endpoints (api.login, api.net_worth,
-- api.get_ledger_account_json, api.get_account_count_json,
-- api.net_value_by_account, api.net_value_by_account_type) were
-- absent from a fresh database despite being shipped in the repo.
-- Order matters: base.get_managed_users is consumed by several api.*
-- functions so it must be created before the api initialization runs.
\i database/base/get_managed_users.sql

/********************************************************************
  Order of Initialization of the Schema Objects

-- #region:: Add. Details
The initialization script calls for the scripts under each of the
schema derectory in the correct order. The database objects are called
from respective schema namespaces according to the schema name.
-- #endregion
********************************************************************/

-- ? create master tables, typically under the ``meta`` schema
\i database/schema/meta/types.sql
\i database/schema/meta/tables.sql

\i database/schema/meta/functions/root_user_exists.sql

-- ? create public tables, typically under the ``public`` schema
\i database/schema/public/tables.sql

\i database/schema/public/functions/fiscalyear.sql
\i database/schema/public/functions/onupdate.sql

\i database/schema/public/triggers/user_account_detail.sql

-- ? create private tables, typically under the ``private`` schema
\i database/schema/private/tables.sql

\i database/schema/private/functions/set_datefields.sql
\i database/schema/private/triggers/user_transaction.sql
\i database/schema/private/triggers/user_points_transaction.sql

-- ! populate the api endpoints using the initialize.sql
\i database/api/initialize.sql

-- ..versionadded:: 2026-06-07 [B7] include the optional stocks extension.
-- The README and CLAUDE.md both advertise stocks tracking; the schema and
-- master/transaction tables exist but were never wired into the master
-- initializer. Stocks tracking is an optional extension - if you do not
-- want it, comment the line below. Future work: gate via \set var.
\i database/schema/stocks/initialize.sql

-- ? populate all the tables with the seed data, only allow when all
-- the above table creation succeds then proceed for constraint checks
\i database/schema/meta/seed.sql
