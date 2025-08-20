/********************************************************************
Template Code to Create a New Ledger Account for a User

The template statement can be used to create a new ledger account for
a user. The template statement may also be integrated with an external
API to create a new ledger account for a user.

Copywright © [2025] Debmalya Pramanik (ZenithClown)
********************************************************************/

INSERT INTO public.ledger_account_detail (
  account_name
  , account_owner
  , account_type_id
  , account_subtype_id
  , account_opened_on
  , account_closed_on
  , account_marked_inactive_on
  , opening_balance
  , opening_balance_recorded_on
) VALUES
  (?, ?, ?, ?, ?, ?, ?, ?, ?);
