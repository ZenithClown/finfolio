/********************************************************************
PostgREST Role Definitions (creation only)

-- ..versionadded:: 2026-06-07 [B8] role creation must run BEFORE any
GRANT statement that names these roles. Object grants live in
database/security/grants.sql and run after api/initialize.sql.
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

