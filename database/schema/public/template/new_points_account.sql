/********************************************************************
Template Code to Create a New Points / Rewards Account

  -- ..versionchanged:: 2026-06-07 [B6] match the actual schema of
  -- ``public.points_account_detail``. The previous template referenced
  -- columns that do not exist (``points_account_owner``,
  -- ``account_type_id``, ``account_subtype_id``); ownership is
  -- currently expressed indirectly via the linked ``ledger_account_id``.
  --
  -- Phase 3 will unify points into the ledger model with a synthetic
  -- ``currency='PTS'`` per CLAUDE.md §4.3 and this template will be
  -- removed in favour of ``new_ledger.sql``.

Copywright © [2025] Debmalya Pramanik (ZenithClown)
********************************************************************/

INSERT INTO public.points_account_detail (
  points_account_id
  , points_account_name
  , ledger_account_id
  , account_type_key
  , conversion_factor
  , opening_balance
  , opening_balance_recorded_on
) VALUES
  (LEFT(UPPER(gen_random_uuid()::varchar(36)), 5), ?, ?, ?, ?, ?, ?);
