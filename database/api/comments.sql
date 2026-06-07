/********************************************************************
COMMENT ON statements for PostgREST / Swagger UI surfacing

-- ..versionadded:: 2026-06-07 [docs] PostgREST publishes COMMENT ON
content as the `description` field in its OpenAPI/Swagger document at
GET / (root). Without these comments the API explorer shows blank
descriptions, which is unfriendly for both internal developers and
end-user integrations.

Reference - PostgREST docs, OpenAPI Support:
"PostgREST supports OpenAPI v2.0 ... documentation is automatically
generated for tables, foreign tables, views, and RPC."
********************************************************************/

-- ===== Views =====
COMMENT ON VIEW api.account_type_master_vw IS
  'Catalogue of supported account types (savings, current, credit card, '
  'wallet, ...). Read-only; web_anon may SELECT for signup forms.';

COMMENT ON VIEW api.expense_category_master_vw IS
  'Catalogue of expense categories and sub-categories (housing/rent, '
  'fooding/grocery, ...). Used to populate transaction-entry dropdowns.';

COMMENT ON VIEW api.income_category_master_vw IS
  'Catalogue of income categories and sub-categories (salary, '
  'investment/dividend, rental income, ...).';

-- ===== RPC functions =====
COMMENT ON FUNCTION api.login(VARCHAR, TEXT) IS
  'Authenticate by username OR email + password and return an HMAC-'
  'SHA256 JWT for subsequent calls. Returns NULL on bad credentials. '
  'Payload: { token: jwt, exp: epoch, role: web_user, username: text }.';

COMMENT ON FUNCTION api.net_worth(CHAR(5)[]) IS
  'Sum (deposits - withdrawals) across the supplied account ids, or '
  'across ALL accounts visible to the caller when an empty array is '
  'passed. RLS restricts visibility to the caller''s managed users.';

COMMENT ON FUNCTION api.net_value_by_account(CHAR(5)[]) IS
  'Per-account breakdown of net value (deposits - withdrawals) with '
  'last transaction date. Pass an empty array for all visible accounts.';

COMMENT ON FUNCTION api.net_value_by_account_type(VARCHAR, VARCHAR) IS
  'Net value grouped by account type and subtype for the given '
  'username. Optional account_type_key LIKE pattern (e.g. ''DBT/%'') '
  'narrows the rollup.';

COMMENT ON FUNCTION api.get_ledger_account_json(VARCHAR, VARCHAR) IS
  'Returns [{ledger_account_id: account_name}, ...] for ledger '
  'accounts visible to the caller. Defaults to debit accounts (key '
  'matching ''DBT/%''); pass NULL to get every account type.';

COMMENT ON FUNCTION api.get_account_count_json(VARCHAR, VARCHAR) IS
  'Returns [{account_type_name: count}, ...] grouped by primary '
  'account type. Optional LIKE pattern restricts to a type family.';

-- ===== Tables (selected high-signal columns) =====
COMMENT ON TABLE public.user_account_detail IS
  'Application users. ROOT/SUDO/USER role hierarchy with self-FK '
  '(managed_by) so a parent or spouse can oversee dependants.';

COMMENT ON COLUMN public.user_account_detail.username IS
  'Stable identifier used in JWT claim and FKs; min 4 chars.';

COMMENT ON COLUMN public.user_account_detail.managed_by IS
  'Parent in the *nix-style account graph. NULL for ROOT/standalone.';

COMMENT ON COLUMN public.user_account_detail.password IS
  'bcrypt hash from pgcrypto crypt(... gen_salt(''bf'', 12)). Never '
  'returned by api.login (which surfaces only a signed JWT).';

COMMENT ON TABLE public.ledger_account_detail IS
  'A user-owned financial account (savings, credit card, wallet, ...). '
  'Five-char id is a hex slice of gen_random_uuid().';

COMMENT ON TABLE public.points_account_detail IS
  'A rewards / cashback wallet linked to a parent ledger account. '
  'conversion_factor maps points to currency for net_worth roll-up.';

COMMENT ON TABLE private.user_transaction IS
  'Single-entry transactions (income + expense + transfers). Phase 3 '
  'will migrate to a double-entry encoding without breaking this API.';

COMMENT ON COLUMN private.user_transaction.self_account_id IS
  'When set, this row is one leg of an internal transfer; the matching '
  'leg points back via the same transaction_idkey grouping.';
