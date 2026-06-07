/********************************************************************
Row-Level Security Policies

-- ..versionadded:: 2026-06-07 [F2] enable RLS on owner-scoped tables.
PostgREST passes JWT claims to the database as `request.jwt.claims`;
custom claims (e.g. `username`) are accessible via
`current_setting('request.jwt.claim.username', true)`. The policies
delegate the owner-graph traversal to `base.get_managed_users()` so
the same membership rules used by the API RPCs apply to direct table
queries too.

Tables protected:
  - public.user_account_detail     (a managed user sees themselves + their tree)
  - public.ledger_account_detail   (owner-scoped via account_owner)
  - public.points_account_detail   (points scoping via underlying ledger)
  - private.user_transaction       (owner-scoped via account_id -> ledger.owner)
  - private.user_points_transaction (same)

The `postgres` superuser BYPASSRLS by default; `authenticator` does
NOT, so once it switches into web_user only the visible rows come back.

Policies are wrapped in DO blocks so re-running is safe.
********************************************************************/

-- Helper: extract the username claim from the request JWT.
CREATE OR REPLACE FUNCTION base.current_username()
RETURNS TEXT
LANGUAGE sql
STABLE
SET search_path = pg_catalog, public
AS $$
  SELECT NULLIF(current_setting('request.jwt.claim.username', true), '');
$$;

GRANT EXECUTE ON FUNCTION base.current_username() TO web_anon, web_user;

-- =====================================================================
-- public.user_account_detail
-- =====================================================================
ALTER TABLE public.user_account_detail ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_account_detail FORCE  ROW LEVEL SECURITY;

DROP POLICY IF EXISTS user_account_detail_owner ON public.user_account_detail;
CREATE POLICY user_account_detail_owner
  ON public.user_account_detail
  FOR SELECT
  TO web_user
  USING (
    username IN (
      SELECT managed_username
        FROM base.get_managed_users(base.current_username()::VARCHAR(16))
    )
  );

-- =====================================================================
-- public.ledger_account_detail
-- =====================================================================
ALTER TABLE public.ledger_account_detail ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ledger_account_detail FORCE  ROW LEVEL SECURITY;

DROP POLICY IF EXISTS ledger_account_detail_owner ON public.ledger_account_detail;
CREATE POLICY ledger_account_detail_owner
  ON public.ledger_account_detail
  FOR ALL
  TO web_user
  USING (
    account_owner IN (
      SELECT managed_username
        FROM base.get_managed_users(base.current_username()::VARCHAR(16))
    )
  )
  WITH CHECK (
    account_owner IN (
      SELECT managed_username
        FROM base.get_managed_users(base.current_username()::VARCHAR(16))
    )
  );

-- =====================================================================
-- public.points_account_detail (scoped via parent ledger)
-- =====================================================================
ALTER TABLE public.points_account_detail ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.points_account_detail FORCE  ROW LEVEL SECURITY;

DROP POLICY IF EXISTS points_account_detail_owner ON public.points_account_detail;
CREATE POLICY points_account_detail_owner
  ON public.points_account_detail
  FOR ALL
  TO web_user
  USING (
    ledger_account_id IN (
      SELECT ledger_account_id
        FROM public.ledger_account_detail
       WHERE account_owner IN (
         SELECT managed_username
           FROM base.get_managed_users(base.current_username()::VARCHAR(16))
       )
    )
  );

-- =====================================================================
-- private.user_transaction
-- =====================================================================
ALTER TABLE private.user_transaction ENABLE ROW LEVEL SECURITY;
ALTER TABLE private.user_transaction FORCE  ROW LEVEL SECURITY;

DROP POLICY IF EXISTS user_transaction_owner ON private.user_transaction;
CREATE POLICY user_transaction_owner
  ON private.user_transaction
  FOR ALL
  TO web_user
  USING (
    account_id IN (
      SELECT ledger_account_id
        FROM public.ledger_account_detail
       WHERE account_owner IN (
         SELECT managed_username
           FROM base.get_managed_users(base.current_username()::VARCHAR(16))
       )
    )
  );

-- =====================================================================
-- private.user_points_transaction
-- =====================================================================
ALTER TABLE private.user_points_transaction ENABLE ROW LEVEL SECURITY;
ALTER TABLE private.user_points_transaction FORCE  ROW LEVEL SECURITY;

DROP POLICY IF EXISTS user_points_transaction_owner ON private.user_points_transaction;
CREATE POLICY user_points_transaction_owner
  ON private.user_points_transaction
  FOR ALL
  TO web_user
  USING (
    account_id IN (
      SELECT points_account_id
        FROM public.points_account_detail
       WHERE ledger_account_id IN (
         SELECT ledger_account_id
           FROM public.ledger_account_detail
          WHERE account_owner IN (
            SELECT managed_username
              FROM base.get_managed_users(base.current_username()::VARCHAR(16))
          )
       )
    )
  );

-- Grant baseline SELECT to web_user so RLS has rows to filter. RLS is
-- the actual access gate; without these grants every SELECT errors
-- with "permission denied" before any policy is checked.
GRANT SELECT ON public.user_account_detail     TO web_user;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.ledger_account_detail TO web_user;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.points_account_detail TO web_user;
GRANT USAGE  ON SCHEMA private                 TO web_user;
GRANT SELECT, INSERT, UPDATE, DELETE ON private.user_transaction       TO web_user;
GRANT SELECT, INSERT, UPDATE, DELETE ON private.user_points_transaction TO web_user;
