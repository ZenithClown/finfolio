CREATE TRIGGER trg_user_transaction_onupdate
  BEFORE UPDATE
  ON private.user_transaction
  FOR EACH ROW EXECUTE PROCEDURE public.onupdate();
