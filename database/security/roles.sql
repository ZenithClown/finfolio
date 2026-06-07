/********************************************************************
PostgREST Roles and Privilege Grants

-- ..versionadded:: 2026-06-07 [B8] introduce least-privilege roles to
replace the dangerous `db-anon-role = "postgres"` default. Per the
PostgREST docs ("PostgREST is designed to keep the database at the
center of API security"), every HTTP request enters the database with
a specific role; unauthenticated traffic now lands on `web_anon` with
ZERO grants on `private` / `public` user tables, instead of running
as a cluster superuser.

Roles created:
  - authenticator : LOGIN NOINHERIT - the role PostgREST connects as.
                    Holds no privileges; only switches into the role
                    advertised in the JWT `role` claim (or web_anon
                    when no JWT is presented).
  - web_anon      : NOLOGIN - the anonymous (pre-login) role. Can
                    read meta views and call `api.login` only.
  - web_user      : NOLOGIN - the post-login role. Owner-scoped
                    access is enforced by RLS policies (see
                    database/security/rls.sql).

Re-runnable: uses DO blocks with EXCEPTION handlers so the script is
idempotent against an existing cluster.
********************************************************************/

DO $$
BEGIN
  CREATE ROLE web_anon NOLOGIN;
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$
BEGIN
  CREATE ROLE web_user NOLOGIN;
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$
BEGIN
  CREATE ROLE authenticator LOGIN NOINHERIT PASSWORD 'authenticator';
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

GRANT web_anon TO authenticator;
GRANT web_user TO authenticator;

-- Allow both roles to traverse the exposed API schema
GRANT USAGE ON SCHEMA api  TO web_anon, web_user;
GRANT USAGE ON SCHEMA base TO web_anon, web_user;

-- web_anon: read-only on the public meta lookup views and execute
-- rights only on `api.login` (granted in api/security/login.sql).
GRANT SELECT ON api.account_type_master_vw     TO web_anon;
GRANT SELECT ON api.expense_category_master_vw TO web_anon;
GRANT SELECT ON api.income_category_master_vw  TO web_anon;

-- web_user: read access to the lookup views + execute on owner-
-- scoped RPCs (granted in the RPC files themselves). Direct table
-- access stays revoked; everything flows through SECURITY DEFINER
-- api.* functions + RLS policies on the underlying tables.
GRANT SELECT ON api.account_type_master_vw     TO web_user;
GRANT SELECT ON api.expense_category_master_vw TO web_user;
GRANT SELECT ON api.income_category_master_vw  TO web_user;
