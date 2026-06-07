/********************************************************************
Phase 4 — `api_pro` Schema Bootstrap (Paid Tier)

PostgREST is configured (postgrest.conf) to expose `api` only; the
`api_pro` schema sits alongside and is only mounted when the operator
adds `db-schemas = "api, api_pro"`. This keeps the free-tier install
hermetic — paid endpoints simply do not exist in the OpenAPI surface.

Authorisation pattern for every api_pro RPC:

    CREATE OR REPLACE FUNCTION api_pro.<name>(...)
    RETURNS ...
    LANGUAGE plpgsql SECURITY DEFINER AS $$
    BEGIN
        IF NOT meta.is_feature_enabled('<flag>') THEN
            RAISE EXCEPTION USING ERRCODE = '42501',
                MESSAGE = 'feature <flag> is not enabled on this tenant';
        END IF;
        -- ... real work ...
    END;
    $$;

This file only stands up the namespace + a paid-tier role (`web_pro`)
inheriting from `web_user`. Concrete RPCs live in api_pro/functions/.
********************************************************************/

CREATE SCHEMA IF NOT EXISTS api_pro;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'web_pro') THEN
        CREATE ROLE web_pro NOLOGIN;
        GRANT web_user TO web_pro;
    END IF;
END $$;

GRANT USAGE ON SCHEMA api_pro TO web_pro;
