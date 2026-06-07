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

-- ..versionadded:: 2026-06-07 [B8] roles must exist before any GRANT
-- in subsequent schema files (e.g. jwt.sql, login.sql) names them.
\i database/security/roles.sql

-- ..versionadded:: 2026-06-07 [B19/Q2] JWT signer must exist before
-- api.login (which calls base.jwt_sign).
\i database/security/jwt.sql

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

-- ..versionadded:: 2026-06-07 [Phase 3 §4.1] double-entry header + lines
-- + balance trigger. Must run after meta.transaction_method type exists
-- (meta/types.sql) and before any RPC that reads private.transaction_*.
\i database/schema/private/transaction_double_entry.sql

-- ..versionadded:: 2026-06-07 [Phase 3 §4.7] audit log table + generic
-- row-change trigger function. Triggers bind to private.transaction_*
-- and public.ledger_account_detail.
\i database/schema/meta/audit.sql

-- ..versionadded:: 2026-06-07 [Phase 3] add is_system + soft-delete to
-- public.ledger_account_detail and seed SYS/IN, SYS/EX system contras.
-- Idempotent: ALTER ... ADD COLUMN IF NOT EXISTS + ON CONFLICT DO NOTHING.
\i database/schema/private/system_accounts.sql

-- ..versionadded:: 2026-06-07 [Phase 3] one-shot backfill of legacy
-- private.user_transaction rows into the new header+lines structure.
-- Idempotent (deterministic UUID per legacy idkey); no-op on fresh DBs
-- and on already-migrated DBs.
\i database/schema/private/transaction_backfill.sql

-- ! populate the api endpoints using the initialize.sql
\i database/api/initialize.sql

-- ..versionadded:: 2026-06-07 [F2] enable row-level security on
-- owner-scoped tables. Must run after roles + tables exist.
\i database/security/rls.sql

-- ..versionadded:: 2026-06-07 [B7] include the optional stocks extension.
-- The README and CLAUDE.md both advertise stocks tracking; the schema and
-- master/transaction tables exist but were never wired into the master
-- initializer. Stocks tracking is an optional extension - if you do not
-- want it, comment the line below. Future work: gate via \set var.
--
-- ..versionchanged:: 2026-06-07 [P3-ORDER-FIX] moved BEFORE constraints.sql
-- and indexes.sql so they can ALTER stocks.* tables. Plain `psql -f` on a
-- clean DB previously failed at constraints.sql:89 with "schema stocks
-- does not exist"; the bug went unnoticed because earlier dev sessions
-- always ran against a database that had been seeded once already.
\i database/schema/stocks/initialize.sql

-- ..versionadded:: 2026-06-08 [Phase 4 §4.4] stocks v2 market data:
-- daily_nav, corporate_action, dividend. Additive; must run AFTER
-- stocks/initialize.sql (FKs to stocks.assets_master).
\i database/schema/stocks/market_data.sql

-- ..versionadded:: 2026-06-08 [Phase 4] price alerts schema.
\i database/schema/stocks/alerts.sql

-- ..versionadded:: 2026-06-08 [Phase 4 §4.6] transaction attachments.
-- Lives in `private` (per-user data); FKs to private.transaction_header.
\i database/schema/private/attachments.sql

-- ..versionadded:: 2026-06-08 [Phase 4] meta.feature_flag — paid-tier gating.
\i database/schema/meta/feature_flag.sql

-- ..versionadded:: 2026-06-08 [Phase 4] api_pro schema (paid-tier endpoints).
\i database/schema/api_pro/initialize.sql

-- ..versionadded:: 2026-06-08 [Phase 4 §8.3] holdings materialised view.
-- Built here (after stocks.daily_nav exists) rather than from
-- api/initialize.sql which runs before stocks/initialize.sql.
\i database/api/views/mv_holdings_vw.sql

-- ..versionadded:: 2026-06-08 [Phase 4 §4.4] FIFO realised gains RPC.
-- Also deferred to here so that stocks.user_transaction (referenced in
-- the RETURNS TABLE signature) exists at function-create time.
\i database/api/functions/fifo_realised_gains.sql

-- ..versionchanged:: 2026-06-08 [Phase 4] grants moved here (was earlier
-- in the file) so that Phase 4 paid-tier objects (api.fifo_realised_gains,
-- api.mv_holdings_vw, api_pro.*) are also covered in a single pass.
\i database/security/grants.sql

-- ..versionadded:: 2026-06-07 [B18] domain CHECK constraints. Must run
-- after every protected table exists (incl. stocks).
\i database/schema/constraints.sql

-- ..versionadded:: 2026-06-07 [B21] FK covering indexes + dashboard
-- composites. Idempotent (CREATE INDEX IF NOT EXISTS).
\i database/schema/indexes.sql

-- ? populate all the tables with the seed data, only allow when all
-- the above table creation succeds then proceed for constraint checks
\i database/schema/meta/seed.sql
