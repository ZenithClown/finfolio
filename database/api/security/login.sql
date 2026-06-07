/********************************************************************
api.login - issue an HMAC-SHA256 signed JWT for PostgREST

-- ..versionchanged:: 2026-06-07 [B19/Q2] hardened: SECURITY DEFINER,
hardened search_path, lower-cased email comparison, returns a signed
JWT instead of leaking the user row. The function runs with the
definer's privileges so it can read public.user_account_detail even
when invoked by web_anon (which has no direct SELECT on that table).

Return payload:
  { token, exp, role, username }   on success
  NULL                              on bad credentials
                                    (caller cannot distinguish unknown
                                     user from wrong password by
                                     design - timing-safe via the
                                     CRYPT() comparison)
********************************************************************/

CREATE OR REPLACE FUNCTION api.login(
  p_login_by VARCHAR(256),
  p_password TEXT
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public
AS $$
DECLARE
  v_user public.user_account_detail%ROWTYPE;
  v_exp  INTEGER;
  v_role TEXT;
  v_jwt  TEXT;
BEGIN
  SELECT *
    INTO v_user
    FROM public.user_account_detail
   WHERE (lower(email) = lower(p_login_by) OR username = p_login_by)
     AND password = public.crypt(p_password, password)
   LIMIT 1;

  IF NOT FOUND THEN
    RETURN NULL;
  END IF;

  -- ROOT/SUDO users get web_user too; future Phase 4 can split
  -- premium roles. Keep the in-DB user_role for app-level checks.
  v_role := 'web_user';
  v_exp  := extract(epoch FROM (now() + interval '12 hours'))::INTEGER;
  v_jwt  := base.jwt_sign(
    jsonb_build_object(
      'role',     v_role,
      'username', v_user.username,
      'app_role', v_user.user_role,
      'iat',      extract(epoch FROM now())::INTEGER,
      'exp',      v_exp
    )
  );

  RETURN json_build_object(
    'token',    v_jwt,
    'exp',      v_exp,
    'role',     v_role,
    'username', v_user.username
  );
END;
$$;

-- api.login must be callable by unauthenticated traffic.
REVOKE ALL ON FUNCTION api.login(VARCHAR, TEXT) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION api.login(VARCHAR, TEXT) TO web_anon, web_user;
