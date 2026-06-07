DROP TRIGGER IF EXISTS trg_assert_only_one_root_user ON public.user_account_detail;
CREATE TRIGGER trg_assert_only_one_root_user
  BEFORE INSERT OR UPDATE
  ON public.user_account_detail
  FOR EACH ROW EXECUTE PROCEDURE meta.root_user_exists();

-- ..versionadded:: 2026-06-07 [B25] maintain updated_on on every UPDATE
-- via the shared public.onupdate() trigger function.
DROP TRIGGER IF EXISTS trg_user_account_detail_onupdate ON public.user_account_detail;
CREATE TRIGGER trg_user_account_detail_onupdate
  BEFORE UPDATE
  ON public.user_account_detail
  FOR EACH ROW EXECUTE PROCEDURE public.onupdate();

DROP TRIGGER IF EXISTS trg_ledger_account_detail_onupdate ON public.ledger_account_detail;
CREATE TRIGGER trg_ledger_account_detail_onupdate
  BEFORE UPDATE
  ON public.ledger_account_detail
  FOR EACH ROW EXECUTE PROCEDURE public.onupdate();
