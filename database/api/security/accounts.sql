/********************************************************************
A Code to Fetch Account Details for a Logged In User for Analysis

A logged in user can view all the accounts that is either directly
managed by them or can view all the accounts that are managed by user
under the ROOT/SUDO list while a USER can view only their account.

Documentation for the function with changelog (if any) is documented
as below:

Get Ledger Account JSON : /rpc/get_ledger_account_json
======================================================

Get the list of ledger accounts for an already logged in user based
on the function that returns the value in a JSON format like below:

```json
[
  {'ledger_account_id' : 'account_name'},
  {'ledger_account_id' : 'account_name'},
  ...
]
```

The function is designed to fetch all the debit accounts (by default)
that are directly mapped under a user or is under a user who is
managed by the logged in user, with an optional parameter to fetch the
type of account. To fetch all the account pass `NULL` as the second
argument, or pass the like clause key for global search.

The function is dynamic and accepts raw JSON as parameter during the
POST call with any method:

```sql
SELECT * FROM api.get_ledger_account_json('username'); -- default
SELECT * FROM api.get_ledger_account_json('username', NULL); -- all
```

Copyright © [2025] Debmalya Pramanik (ZenithClow)
********************************************************************/

CREATE OR REPLACE FUNCTION api.get_ledger_account_json (
  p_username VARCHAR(16)
  -- ! use like clause to search, with equal functionality
  -- by either passing % wild character search, or values directly
  -- returns all debit account types by default for querying
  , p_account_type_key VARCHAR(7) = 'DBT/%'
)
RETURNS JSON AS $$
BEGIN
  RETURN (
    SELECT
      JSON_AGG(JSON_BUILD_OBJECT(
        t.ledger_account_id
        , t.account_name
      ))
    FROM (
      WITH user_role_cte AS (
        SELECT user_role FROM public.user_account_detail
        WHERE username = p_username
      ), usernames_cte AS (
        SELECT DISTINCT username
        FROM public.user_account_detail
        WHERE
          CASE
            WHEN (SELECT user_role FROM user_role_cte) = 'ROOT' THEN TRUE
          ELSE username = p_username OR managed_by = p_username
          END
      )

      SELECT
        ledger_account_id
        , account_name
      FROM public.ledger_account_detail
      WHERE
        account_owner IN (SELECT username FROM usernames_cte)
        AND CASE
          WHEN p_account_type_key IS NULL THEN TRUE
          ELSE account_type_key LIKE p_account_type_key
          END
      ORDER BY account_opened_on
    ) t
  );
END
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION api.get_account_count_json (
  p_username VARCHAR(16)
  -- ! use like clause to search, with equal functionality
  -- by either passing % wild character search, or values directly
  -- returns all debit account types by default for querying
  , p_account_type_key VARCHAR(7) = 'DBT/%'
)
RETURNS JSON AS $$
BEGIN
  RETURN (
    SELECT JSON_AGG(JSON_BUILD_OBJECT(
        t.account_type_name
        , t.account_count
      ))
    FROM (
      WITH user_role_cte AS (
        SELECT user_role FROM public.user_account_detail
        WHERE username = p_username
      ), usernames_cte AS (
        SELECT DISTINCT username
        FROM public.user_account_detail
        WHERE
          CASE
            WHEN (SELECT user_role FROM user_role_cte) = 'ROOT' THEN TRUE
          ELSE username = p_username OR managed_by = p_username
          END
      )

      SELECT
        accounts.account_type_name
        , COUNT(*) AS account_count
      FROM public.ledger_account_detail ledgers
      LEFT JOIN meta.account_type_master accounts ON
        ledgers.account_type_key = accounts.account_type_key
      WHERE
        account_owner IN (SELECT username FROM usernames_cte)
        AND CASE
          WHEN p_account_type_key IS NULL THEN TRUE
          ELSE ledgers.account_type_key LIKE p_account_type_key
          END
      GROUP BY accounts.account_type_name
    ) t
  );
END
$$ LANGUAGE plpgsql;
