/********************************************************************
PostgREST Object Grants (post-creation pass)

-- ..versionadded:: 2026-06-07 [B8] keep grants separate from role
creation so that ordering inside initialize.sql is unambiguous:

  1. security/roles.sql   (top of init - creates the roles)
  2. ... all schema/api objects come into existence ...
  3. security/grants.sql  (bottom of init - this file)

This way, no GRANT statement names an object that doesn't exist yet
and no CREATE statement references a role that hasn't been created.
********************************************************************/

GRANT USAGE ON SCHEMA api  TO web_anon, web_user;
GRANT USAGE ON SCHEMA base TO web_anon, web_user;

-- Lookup views are world-readable inside the API
GRANT SELECT ON api.account_type_master_vw     TO web_anon, web_user;
GRANT SELECT ON api.expense_category_master_vw TO web_anon, web_user;
GRANT SELECT ON api.income_category_master_vw  TO web_anon, web_user;

-- Owner-scoped RPCs: web_user only. (api.login is granted in its own
-- definition file because it needs web_anon as well.)
GRANT EXECUTE ON FUNCTION api.net_worth(CHAR(5)[])                              TO web_user;
GRANT EXECUTE ON FUNCTION api.net_value_by_account(CHAR(5)[])                   TO web_user;
GRANT EXECUTE ON FUNCTION api.net_value_by_account_type(VARCHAR, VARCHAR(16))   TO web_user;
GRANT EXECUTE ON FUNCTION api.get_ledger_account_json(VARCHAR, VARCHAR(16))     TO web_user;
GRANT EXECUTE ON FUNCTION api.get_account_count_json(VARCHAR, VARCHAR(16))      TO web_user;
GRANT EXECUTE ON FUNCTION base.get_managed_users(VARCHAR)                       TO web_user;
-- ..versionadded:: 2026-06-07 [Phase 3 §4.1] double-entry write RPC.
GRANT EXECUTE ON FUNCTION api.post_transaction(
  CHAR(5), NUMERIC, meta.transaction_type, DATE, VARCHAR,
  meta.transaction_method, VARCHAR, VARCHAR, CHAR(5), VARCHAR
)                                                                              TO web_user;
