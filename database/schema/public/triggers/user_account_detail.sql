CREATE TRIGGER trg_assert_only_one_root_user
  BEFORE INSERT OR UPDATE
  ON public.user_account_detail
  FOR EACH ROW EXECUTE PROCEDURE meta.root_user_exists();
