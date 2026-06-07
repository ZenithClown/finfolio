-- Revert finfolio:baseline_v02 from pg
--
-- Drops every schema introduced by initialize.sql plus the PostgREST
-- roles. Runs in the order reverse to creation: drop dependent objects
-- (api views/RPCs / RLS) before the tables they reference.
--
-- IMPORTANT: this is a destructive revert. All data in finfolio is
-- gone. sqitch will ask for confirmation by default; pass
-- `--no-prompt -y` only on disposable databases.

BEGIN;

-- Drop schemas with CASCADE: this kills tables, views, functions,
-- triggers, sequences, types, and grants in a single shot.
DROP SCHEMA IF EXISTS stocks  CASCADE;
DROP SCHEMA IF EXISTS api     CASCADE;
DROP SCHEMA IF EXISTS base    CASCADE;
DROP SCHEMA IF EXISTS private CASCADE;
DROP SCHEMA IF EXISTS public  CASCADE;
DROP SCHEMA IF EXISTS meta    CASCADE;

-- public is special: PG expects it to exist for the search_path default.
CREATE SCHEMA public;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;

-- Drop the PostgREST role triad. authenticator inherits web_anon/web_user,
-- so revoke + drop in dependency order.
REVOKE ALL ON SCHEMA public FROM web_anon, web_user, authenticator;
DROP ROLE IF EXISTS authenticator;
DROP ROLE IF EXISTS web_user;
DROP ROLE IF EXISTS web_anon;

COMMIT;
