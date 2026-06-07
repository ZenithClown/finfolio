/********************************************************************
HMAC-SHA256 JWT Signer (JWS Compact Serialization)

-- ..versionadded:: 2026-06-07 [B19/Q2] inline plpgsql HMAC JWT to
support PostgREST authentication without adding the third-party
`pgjwt` extension (which would require a custom Postgres build on
Alpine images). Uses `pgcrypto.hmac()` (already declared in
initialize.sql for bcrypt) so no new dependency is introduced.

Reference: RFC 7519 (JWT) + RFC 7515 (JWS).

Wire format produced:
  base64url(header) "." base64url(payload) "." base64url(HMAC-SHA256(...))

The header is always {"alg":"HS256","typ":"JWT"}. PostgREST verifies
HS256 signatures natively when `jwt-secret` is configured.

The secret is supplied via the `app.jwt_secret` GUC, set by the same
mechanism that populates the PGRST_JWT_SECRET env var. Set per-cluster
once with:

  ALTER DATABASE finfolio SET app.jwt_secret = 'a-32+-char-secret';

This keeps the secret out of source control. base.jwt_sign() is
SECURITY DEFINER + STABLE so it can be granted EXECUTE to web_anon
(needed by api.login) without exposing the secret directly.
********************************************************************/

CREATE SCHEMA IF NOT EXISTS base;

-- Base64URL encoding (RFC 4648 §5): strip '=' padding, replace
-- '+' -> '-' and '/' -> '_'. Postgres' encode(..., 'base64') uses
-- standard alphabet + newlines every 76 chars, so we also strip
-- whitespace.
CREATE OR REPLACE FUNCTION base.b64url_encode(p_bytes BYTEA)
RETURNS TEXT
LANGUAGE sql IMMUTABLE
SET search_path = pg_catalog, public
AS $$
  SELECT translate(
           rtrim(replace(encode(p_bytes, 'base64'), E'\n', ''), '='),
           '+/',
           '-_'
         );
$$;

-- HS256-signed JWT. Accepts a payload as JSONB; caller is responsible
-- for including registered claims (`exp`, `iat`, `role`, custom).
CREATE OR REPLACE FUNCTION base.jwt_sign(
  p_payload JSONB,
  p_secret  TEXT DEFAULT NULL
)
RETURNS TEXT
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = pg_catalog, public
AS $$
DECLARE
  v_secret  TEXT;
  v_header  TEXT;
  v_payload TEXT;
  v_signing TEXT;
  v_sig     TEXT;
BEGIN
  v_secret := COALESCE(
    p_secret,
    NULLIF(current_setting('app.jwt_secret', true), '')
  );

  IF v_secret IS NULL OR length(v_secret) < 32 THEN
    RAISE EXCEPTION 'JWT secret missing or shorter than 32 chars (set app.jwt_secret)';
  END IF;

  v_header  := base.b64url_encode(convert_to('{"alg":"HS256","typ":"JWT"}', 'utf8'));
  v_payload := base.b64url_encode(convert_to(p_payload::text, 'utf8'));
  v_signing := v_header || '.' || v_payload;
  v_sig     := base.b64url_encode(public.hmac(v_signing, v_secret, 'sha256'));

  RETURN v_signing || '.' || v_sig;
END;
$$;

REVOKE ALL ON FUNCTION base.jwt_sign(JSONB, TEXT) FROM PUBLIC;
-- Only api.login (running as SECURITY DEFINER itself) needs this;
-- grant to web_anon so unauthenticated /rpc/login works.
GRANT EXECUTE ON FUNCTION base.jwt_sign(JSONB, TEXT) TO web_anon, web_user;
GRANT EXECUTE ON FUNCTION base.b64url_encode(BYTEA)  TO web_anon, web_user;
