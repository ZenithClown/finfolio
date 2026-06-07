/********************************************************************
Template Code to Create a New Ledger Account for a User

The template statement can be used to create a new ledger account for
a user. The template statement may also be integrated with an external
API to create a new ledger account for a user.

  -- ..versionchanged:: 2026-06-07 [B5] match the actual schema:
  -- ``public.ledger_account_detail`` uses a single composite key column
  -- ``account_type_key`` (e.g. 'CDT/CCD'), not the separate
  -- ``account_type_id`` + ``account_subtype_id`` pair this template
  -- previously listed. The PK ``ledger_account_id`` is auto-defaulted
  -- from ``LEFT(UPPER(gen_random_uuid()::varchar(36)), 5)`` so it is
  -- intentionally omitted here.

Copywright © [2025] Debmalya Pramanik (ZenithClown)
********************************************************************/

INSERT INTO public.ledger_account_detail (
  account_name
  , account_owner
  , account_type_key
  , account_opened_on
  , account_closed_on
  , account_marked_inactive_on
  , opening_balance
  , opening_balance_recorded_on
) VALUES
  (?, ?, ?, ?, ?, ?, ?, ?);
