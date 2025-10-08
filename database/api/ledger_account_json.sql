CREATE VIEW api.ledger_account_json AS (
  SELECT
    JSON_AGG(JSON_BUILD_OBJECT(t.ledger_account_id, t.account_name))
  FROM (
  SELECT
    tbl.ledger_account_id
    , tbl.account_name
  FROM public.ledger_account_detail tbl
  ) t
);
