CREATE OR REPLACE FUNCTION public.udf_get_to_update_record_for_transaction_method (reference VARCHAR(64))
  RETURNS TABLE (
    transaction_id BIGINT
    , account_id   CHAR(5)
    , trx_date     DATE
    , trx_type     CHAR(1)
    , trx_desc     VARCHAR(512)
    , trx_amount   NUMERIC(12, 2)
  )
  LANGUAGE plpgsql AS
  $func$
  BEGIN
    RETURN QUERY
    SELECT
      t.transaction_id
      , t.account_id
      , t.trx_date
      , t.trx_type
      , t.trx_desc
      , t.trx_amount
    FROM private.user_transaction t
    WHERE
      t.trx_desc LIKE reference
      AND t.transfer_method IS NULL
    ORDER BY
      t.account_id
      , t.trx_date DESC;
  END
  $func$;
