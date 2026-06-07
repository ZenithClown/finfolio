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

-- ..versionchanged:: 2026-06-07 [B13] p_account_type_key VARCHAR(7) -> (16).
-- Drop the legacy signature before recreating (CREATE OR REPLACE cannot
-- change a parameter type).
DROP FUNCTION IF EXISTS api.net_value_by_account_type(VARCHAR(16), VARCHAR(7));

-- ..versionchanged:: 2026-06-07 [Phase 3 §4.1] swap underlying storage
-- from private.user_transaction (single-row) to private.transaction_line
-- (double-entry). Balance = SUM over lines, signed by the account's
-- normal side: DBT-prefixed accounts are debit-normal (asset/expense),
-- CDT-prefixed are credit-normal (liability/equity/income). System
-- accounts (is_system = true) are filtered out so user-facing net
-- worth never includes the SYSIN/SYSEX contras.

CREATE OR REPLACE FUNCTION api.net_worth(
  p_account_id CHAR(5)[]
)
RETURNS JSON
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = pg_catalog, public
AS $$
BEGIN
  RETURN (
    SELECT ROW_TO_JSON(t) FROM
    (
      SELECT
        SUM(
          CASE
            WHEN atm.account_type_id = 'DBT' AND tl.side = 'DEBIT'  THEN  tl.amount * tl.fx_rate_to_base
            WHEN atm.account_type_id = 'DBT' AND tl.side = 'CREDIT' THEN -tl.amount * tl.fx_rate_to_base
            WHEN atm.account_type_id = 'CDT' AND tl.side = 'CREDIT' THEN  tl.amount * tl.fx_rate_to_base
            WHEN atm.account_type_id = 'CDT' AND tl.side = 'DEBIT'  THEN -tl.amount * tl.fx_rate_to_base
            ELSE 0
          END
        )::NUMERIC(18, 2) AS net_value
        , MAX(th.trx_date) AS last_updated
      FROM private.transaction_line tl
      JOIN private.transaction_header th
        ON th.transaction_uid = tl.transaction_uid
       AND th.deleted_on IS NULL
      JOIN public.ledger_account_detail lad
        ON lad.ledger_account_id = tl.account_id
       AND lad.is_system = FALSE
       AND lad.deleted_on IS NULL
      JOIN meta.account_type_master atm
        ON atm.account_type_key = lad.account_type_key
      WHERE CASE
        WHEN ARRAY_LENGTH(p_account_id, 1) IS NULL
          OR ARRAY_LENGTH(p_account_id, 1) = 0 THEN TRUE
        ELSE tl.account_id = ANY(p_account_id)
        END
    ) t
  );
END
$$;


CREATE OR REPLACE FUNCTION api.net_value_by_account(
  p_account_id CHAR(5)[]
)
RETURNS TABLE (
  account_id CHAR(5)
  , net_value NUMERIC(18, 2)
  , last_updated DATE
)
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = pg_catalog, public
AS $$
BEGIN
  RETURN QUERY (
    SELECT
      tl.account_id
      , SUM(
        CASE
          WHEN atm.account_type_id = 'DBT' AND tl.side = 'DEBIT'  THEN  tl.amount * tl.fx_rate_to_base
          WHEN atm.account_type_id = 'DBT' AND tl.side = 'CREDIT' THEN -tl.amount * tl.fx_rate_to_base
          WHEN atm.account_type_id = 'CDT' AND tl.side = 'CREDIT' THEN  tl.amount * tl.fx_rate_to_base
          WHEN atm.account_type_id = 'CDT' AND tl.side = 'DEBIT'  THEN -tl.amount * tl.fx_rate_to_base
          ELSE 0
        END
      )::NUMERIC(18, 2) AS net_value
      , MAX(th.trx_date) AS last_updated
    FROM private.transaction_line tl
    JOIN private.transaction_header th
      ON th.transaction_uid = tl.transaction_uid
     AND th.deleted_on IS NULL
    JOIN public.ledger_account_detail lad
      ON lad.ledger_account_id = tl.account_id
     AND lad.is_system = FALSE
     AND lad.deleted_on IS NULL
    JOIN meta.account_type_master atm
      ON atm.account_type_key = lad.account_type_key
    WHERE CASE
      WHEN ARRAY_LENGTH(p_account_id, 1) IS NULL
        OR ARRAY_LENGTH(p_account_id, 1) = 0 THEN TRUE
      ELSE tl.account_id = ANY(p_account_id)
      END
    GROUP BY tl.account_id
  );
END
$$;


CREATE OR REPLACE FUNCTION api.net_value_by_account_type(
  p_username VARCHAR(16)
  -- ! use like clause to search, with equal functionality
  -- by either passing % wild character search, or values directly
  -- returns all debit account types by default for querying
  , p_account_type_key VARCHAR(16) = NULL
)
RETURNS TABLE (
  account_type_id CHAR(3)
  , account_type_name VARCHAR(32)
  , account_subtype_id CHAR(3)
  , account_subtype_name VARCHAR(34)
  , net_value NUMERIC(18, 2)
  , last_updated DATE
)
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = pg_catalog, public
AS $$
BEGIN
  RETURN QUERY (
    SELECT
      atm.account_type_id
      , atm.account_type_name
      , atm.account_subtype_id
      , atm.account_subtype_name
      , SUM(
        CASE
          WHEN atm.account_type_id = 'DBT' AND tl.side = 'DEBIT'  THEN  tl.amount * tl.fx_rate_to_base
          WHEN atm.account_type_id = 'DBT' AND tl.side = 'CREDIT' THEN -tl.amount * tl.fx_rate_to_base
          WHEN atm.account_type_id = 'CDT' AND tl.side = 'CREDIT' THEN  tl.amount * tl.fx_rate_to_base
          WHEN atm.account_type_id = 'CDT' AND tl.side = 'DEBIT'  THEN -tl.amount * tl.fx_rate_to_base
          ELSE 0
        END
      )::NUMERIC(18, 2) AS net_value
      , MAX(th.trx_date) AS last_updated
    FROM private.transaction_line tl
    JOIN private.transaction_header th
      ON th.transaction_uid = tl.transaction_uid
     AND th.deleted_on IS NULL
    JOIN public.ledger_account_detail lad
      ON lad.ledger_account_id = tl.account_id
     AND lad.is_system = FALSE
     AND lad.deleted_on IS NULL
    JOIN meta.account_type_master atm
      ON atm.account_type_key = lad.account_type_key
    WHERE
      lad.account_owner IN (
        SELECT managed_username FROM base.get_managed_users(p_username)
      )
      AND CASE
        WHEN p_account_type_key IS NULL THEN TRUE
        ELSE lad.account_type_key LIKE p_account_type_key
        END
    GROUP BY
      atm.account_type_id
      , atm.account_type_name
      , atm.account_subtype_id
      , atm.account_subtype_name
  );
END
$$;
