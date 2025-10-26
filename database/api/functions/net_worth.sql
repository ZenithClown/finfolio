/********************************************************************
Create a Function to Calculate Net Worth for a User

The function returns a JSON data containing the net worth for a user
based on the provided account IDs (optional), along with the last date
of the transaction.

The API exposes a POST endpoint to the underlying call function at
`http://localhost:3100/rpc/net_worth` and the data can be passed as
a RAW JSON Object in the request body, like:

```json
{
  "account_id": ["12345", "67890"]
}
```

The same can be checked in PgAdmin via a simple select query of below
choice like:

```sql
SELECT api.net_worth(array['12345', '67890']);

-- or, get for all using:
SELECT api.net_worth(ARRAY[]::CHAR(5)[]);
```

The return is always a single JSON ROW that returns the net worth in
the default currency and the last updated date in database.

Copyright © [2025] Debmalya Pramanik, DigitPhilia INC.
********************************************************************/

CREATE OR REPLACE FUNCTION api.net_worth(
  p_account_id CHAR(5)[]
)
RETURNS JSON AS $$
BEGIN
  RETURN (
      SELECT ROW_TO_JSON(t) FROM
      (
        SELECT
          SUM(
            CASE
              WHEN tbl.trx_type = 'DEPOSIT' THEN tbl.trx_amount
              WHEN tbl.trx_type = 'WITHDRAW' THEN tbl.trx_amount * -1
              ELSE 0 END
          ) AS net_value
          , MAX(tbl.trx_date) AS last_updated
        FROM private.user_transaction tbl
        WHERE CASE
          WHEN
            ARRAY_LENGTH(p_account_id, 1) IS NULL
            OR ARRAY_LENGTH(p_account_id, 1) = 0 THEN TRUE
          ELSE tbl.account_id = ANY(p_account_id)
          END
      ) t
  );
END
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION api.net_value_by_account(
  p_account_id CHAR(5)[]
)
RETURNS TABLE (
  account_id CHAR(5)
  , net_value NUMERIC(12, 2)
  , last_updated DATE
) AS $$
BEGIN
  RETURN QUERY (
    SELECT
      tbl.account_id
      , SUM(
        CASE
          WHEN tbl.trx_type = 'DEPOSIT' THEN tbl.trx_amount
          WHEN tbl.trx_type = 'WITHDRAW' THEN tbl.trx_amount * -1
          ELSE 0 END
      ) AS net_value
      , MAX(tbl.trx_date) AS last_updated
    FROM private.user_transaction tbl
    WHERE CASE
      WHEN
        ARRAY_LENGTH(p_account_id, 1) IS NULL
        OR ARRAY_LENGTH(p_account_id, 1) = 0 THEN TRUE
      ELSE tbl.account_id = ANY(p_account_id)
      END
    GROUP BY tbl.account_id
  );
END
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION api.net_value_by_account_type(
  p_username VARCHAR(16)
  -- ! use like clause to search, with equal functionality
  -- by either passing % wild character search, or values directly
  -- returns all debit account types by default for querying
  , p_account_type_key VARCHAR(7) = NULL
)
RETURNS TABLE (
  account_type_id CHAR(3)
  , account_type_name VARCHAR(32)
  , account_subtype_id CHAR(3)
  , account_subtype_name VARCHAR(34)
  , net_value NUMERIC(12, 2)
  , last_updated DATE
) AS $$
BEGIN
  RETURN QUERY (
    SELECT
      accounts.account_type_id
      , accounts.account_type_name
      , accounts.account_subtype_id
      , accounts.account_subtype_name
      , SUM(
        CASE
          WHEN tbl.trx_type = 'DEPOSIT' THEN tbl.trx_amount
          WHEN tbl.trx_type = 'WITHDRAW' THEN tbl.trx_amount * -1
          ELSE 0 END
      ) AS net_value
      , MAX(tbl.trx_date) AS last_updated
    FROM private.user_transaction tbl
    LEFT JOIN public.ledger_account_detail ledgers
      ON tbl.account_id = ledgers.ledger_account_id
    LEFT JOIN meta.account_type_master accounts
      ON ledgers.account_type_key = accounts.account_type_key
    WHERE
      ledgers.account_owner IN (
        SELECT managed_username FROM base.get_managed_users(p_username)
      )
      AND CASE
        WHEN p_account_type_key IS NULL THEN TRUE
        ELSE ledgers.account_type_key LIKE p_account_type_key
        END
    GROUP BY
      accounts.account_type_id
      , accounts.account_type_name
      , accounts.account_subtype_id
      , accounts.account_subtype_name
  );
END
$$ LANGUAGE plpgsql;
