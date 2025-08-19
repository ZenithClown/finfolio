CREATE TRIGGER trg_user_points_transaction_onupdate
  BEFORE UPDATE
  ON private.user_points_transaction
  FOR EACH ROW EXECUTE PROCEDURE public.onupdate();
