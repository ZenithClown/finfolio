CREATE OR REPLACE PROCEDURE set_transfer_method(
  methodname VARCHAR(7)
  , wpattern VARCHAR(64)
)
LANGUAGE plpgsql AS
$$
  DECLARE current_timestamp_ TIMESTAMP = (timezone('utc', now()));
  BEGIN
    UPDATE private.user_transaction SET
      transfer_method = methodname
      , updated_at = current_timestamp_
    WHERE transaction_id IN
    (SELECT transaction_id FROM public.udf_get_to_update_record_for_transaction_method(wpattern));
  END
$$
