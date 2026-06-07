/********************************************************************
Phase 3 §4.1 — System Contra Accounts & Soft-Delete Columns

-- ..versionadded:: 2026-06-07 [Phase 3] every double-entry posting needs
two accounts. For flows that cross the system boundary (income from a
salary, expense to a merchant) we need a counter-party account that
sits inside the model but never appears in net-worth reports.

We solve this with two SYSTEM accounts, owned by the ROOT user and
flagged `is_system = true`:

  * `SYSIN` — External Income source (where deposits "come from")
  * `SYSEX` — External Expense sink   (where withdrawals "go to")

Every system account is excluded from `api.net_worth*` by an
`is_system = false` filter. Self-account transfers (between two of the
user's own accounts) need NO system account — both legs hit real
accounts.

Soft-delete columns are also added to `public.ledger_account_detail`
here (§4.7) so accounts can be retired without breaking historical
transaction_line FK references.
********************************************************************/

-- ..versionadded:: 2026-06-07 [Phase 3] is_system flag + soft-delete pair.
ALTER TABLE public.ledger_account_detail
  ADD COLUMN IF NOT EXISTS is_system BOOLEAN NOT NULL DEFAULT FALSE;

ALTER TABLE public.ledger_account_detail
  ADD COLUMN IF NOT EXISTS deleted_on TIMESTAMPTZ;

ALTER TABLE public.ledger_account_detail
  ADD COLUMN IF NOT EXISTS deleted_by VARCHAR(16);

-- Soft-delete invariant: both columns set together or neither.
ALTER TABLE public.ledger_account_detail
  DROP CONSTRAINT IF EXISTS ck_lad_soft_delete_pair;
ALTER TABLE public.ledger_account_detail
  ADD  CONSTRAINT ck_lad_soft_delete_pair CHECK (
    (deleted_on IS NULL AND deleted_by IS NULL)
    OR
    (deleted_on IS NOT NULL AND deleted_by IS NOT NULL)
  );

-- Phase 3 also retires the unrelated `uq_user_fullname` UNIQUE we
-- removed in Phase 2 [B16]; the matching index on lower(fullname) is
-- already present. No-op here.

-- The two account_type_keys we need for system contras.
-- 'SYS/INC' = system inflow source. 'SYS/EXP' = system outflow sink.
-- Both belong to a new primary type SYS (System) that is filtered out
-- of every dashboard / net-worth report.
INSERT INTO meta.account_type_master (
  account_type_key, account_type_id, account_type_name, account_type_desc,
  account_subtype_id, account_subtype_name, account_subtype_desc
) VALUES
  ('SYS/INC', 'SYS', 'System', 'Internal counter-party accounts; never appear in net worth.',
   'INC', 'External Income Source', 'Off-ledger source for deposits, salary credits, refunds.'),
  ('SYS/EXP', 'SYS', 'System', 'Internal counter-party accounts; never appear in net worth.',
   'EXP', 'External Expense Sink', 'Off-ledger sink for withdrawals, merchant payments, fees.')
ON CONFLICT (account_type_key) DO NOTHING;

-- Seed the two system accounts. They MUST be owned by a real user
-- (account_owner FK), so we attach them to the first ROOT-role user
-- found at boot. If no ROOT user exists yet (greenfield install) the
-- helper returns FALSE and a deferred trigger on user_account_detail
-- will retry the seed the moment the first ROOT user is created.
-- See database/schema/meta/functions/ensure_system_accounts.sql.
DO $$
BEGIN
  PERFORM meta.ensure_system_accounts();
END $$;
