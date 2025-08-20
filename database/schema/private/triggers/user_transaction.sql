CREATE TRIGGER trg_user_transaction_onupdate
  BEFORE UPDATE
  ON private.user_transaction
  FOR EACH ROW EXECUTE PROCEDURE public.onupdate();


CREATE TRIGGER trg_user_transaction_datefields
  BEFORE INSERT OR UPDATE
  ON private.user_transaction
  FOR EACH ROW EXECUTE PROCEDURE private.set_datefields();
