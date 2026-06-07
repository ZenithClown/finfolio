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

-- ..versionadded:: 2026-06-08 [Phase 5 hotfix] auto-seed SYSIN/SYSEX
-- the moment the first ROOT user is created. Resolves the chicken-
-- and-egg between init (no users yet) and api.post_transaction (needs
-- SYSIN/SYSEX). The helper function itself is a no-op if the rows
-- already exist, so this trigger is safe on every subsequent ROOT
-- creation too (e.g. import scenarios).
CREATE OR REPLACE FUNCTION public.trg_fn_seed_system_accounts()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
  IF NEW.user_role = 'ROOT' THEN
    PERFORM meta.ensure_system_accounts(NEW.username);
  END IF;
  RETURN NEW;
END
$$;

DROP TRIGGER IF EXISTS trg_seed_system_accounts ON public.user_account_detail;
CREATE TRIGGER trg_seed_system_accounts
  AFTER INSERT
  ON public.user_account_detail
  FOR EACH ROW EXECUTE PROCEDURE public.trg_fn_seed_system_accounts();
