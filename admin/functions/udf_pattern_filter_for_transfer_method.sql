/********************************************************************
Pattern Filter for Transfer Method

A simple function can be used to filter and updated the records for
transfer methods which can be any one of the following defined under
the ``meta.transaction_method`` table. This function simply searches
for the pattern using the ``LIKE`` clause and reports the same to be
used in the stored procedure ``public.set_transfer_method`` to update
the records in one go. Check the
``scripts/exec_updated_transfer_method.sql`` for more information.
********************************************************************/

CREATE OR REPLACE FUNCTION public.udf_pattern_filter_for_transfer_method (wpattern VARCHAR(64))
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
