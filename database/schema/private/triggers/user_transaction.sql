DROP TRIGGER IF EXISTS trg_user_transaction_onupdate ON private.user_transaction;
CREATE TRIGGER trg_user_transaction_onupdate
  BEFORE UPDATE
  ON private.user_transaction
  FOR EACH ROW EXECUTE PROCEDURE public.onupdate();


-- ..versionchanged:: 2026-06-07 [B4] interim fix - the trigger below
-- writes to record fields `trx_fiscalyear` and `trx_month` which do
-- not exist on `private.user_transaction`, so every INSERT/UPDATE
-- raised: ERROR: record "new" has no field "trx_fiscalyear".
-- Binding removed. The function definition is left in place but unused.
-- Phase 3 will replace this with GENERATED ALWAYS AS (...) STORED
-- columns on the new `private.transaction_header` table (see CLAUDE.md
-- §4.1). Once those columns exist, restore the binding or - preferred -
-- drop both the function and this trigger entirely.
--
-- CREATE TRIGGER trg_user_transaction_datefields
--   BEFORE INSERT OR UPDATE
--   ON private.user_transaction
--   FOR EACH ROW EXECUTE PROCEDURE private.set_datefields();
