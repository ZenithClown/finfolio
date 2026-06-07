/********************************************************************
meta.ensure_system_accounts(p_owner)

-- ..versionadded:: 2026-06-08 [Phase 5 hotfix] resolves the
chicken-and-egg between `database/initialize.sql` (which runs before
any user exists) and `api.post_transaction` (which needs SYSIN/SYSEX
to be present on the very first call).

Behaviour
---------
* If `SYSIN` or `SYSEX` already exists, this is a no-op for that row.
* If `p_owner` is NULL, picks the oldest ROOT user.
* If no ROOT user exists either, the function returns FALSE without
  raising; the caller is expected to retry after a user is created.
* Returns TRUE iff both system accounts exist after the call.

Callers
-------
1. `schema/private/system_accounts.sql` - boot-time best-effort seed.
2. `schema/public/triggers/user_account_detail.sql` - fires once
   when the first ROOT user is created.
3. `api/functions/post_transaction.sql` - defensive lazy call so the
   first deposit ever on a fresh DB still succeeds even if the
   admin somehow bypassed the trigger.
********************************************************************/

CREATE OR REPLACE FUNCTION meta.ensure_system_accounts(p_owner VARCHAR DEFAULT NULL)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public
AS $$
DECLARE
  v_owner VARCHAR(16) := p_owner;
BEGIN
  IF v_owner IS NULL THEN
    SELECT username INTO v_owner
      FROM public.user_account_detail
     WHERE user_role = 'ROOT'
     ORDER BY created_on
     LIMIT 1;
  END IF;

  IF v_owner IS NULL THEN
    RETURN FALSE;
  END IF;

  INSERT INTO public.ledger_account_detail (
    ledger_account_id, account_name, account_owner, account_type_key,
    account_opened_on, opening_balance, opening_balance_recorded_on, is_system
  ) VALUES
    ('SYSIN', 'System: External Income Source', v_owner, 'SYS/INC',
     CURRENT_DATE, 0, CURRENT_DATE, TRUE),
    ('SYSEX', 'System: External Expense Sink',  v_owner, 'SYS/EXP',
     CURRENT_DATE, 0, CURRENT_DATE, TRUE)
  ON CONFLICT (ledger_account_id) DO NOTHING;

  RETURN EXISTS (
    SELECT 1 FROM public.ledger_account_detail
     WHERE ledger_account_id = 'SYSIN'
  ) AND EXISTS (
    SELECT 1 FROM public.ledger_account_detail
     WHERE ledger_account_id = 'SYSEX'
  );
END
$$;

COMMENT ON FUNCTION meta.ensure_system_accounts(VARCHAR) IS
  'Idempotently seeds the SYSIN / SYSEX system contra accounts under '
  'the given (or first ROOT) user. Returns TRUE iff both exist on return.';
