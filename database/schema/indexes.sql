/********************************************************************
B-tree Indexes for Foreign Key columns and common dashboard lookups

-- ..versionadded:: 2026-06-07 [B21] Postgres does NOT auto-index FK
columns (only the referenced side's PK is indexed). Without these,
every ON DELETE CASCADE / ON UPDATE CASCADE has to seq-scan the
referencing table, and every dashboard join against a parent table
degrades on growth. Idempotent via CREATE INDEX IF NOT EXISTS.

Naming: ix_<table>_<column>  (compact, schema implied by table prefix).

Also adds two composite indexes that the API RPCs actually use:
  - private.user_transaction (account_id, trx_date) — net_worth() filter
  - stocks.user_transaction   (account_id, trade_date)
********************************************************************/

-- ===== public.user_account_detail =====
CREATE INDEX IF NOT EXISTS ix_user_account_detail_managed_by
  ON public.user_account_detail (managed_by);

-- ===== public.ledger_account_detail =====
CREATE INDEX IF NOT EXISTS ix_ledger_account_detail_account_owner
  ON public.ledger_account_detail (account_owner);
CREATE INDEX IF NOT EXISTS ix_ledger_account_detail_account_type_key
  ON public.ledger_account_detail (account_type_key);

-- ===== public.points_account_detail =====
CREATE INDEX IF NOT EXISTS ix_points_account_detail_ledger_account_id
  ON public.points_account_detail (ledger_account_id);
CREATE INDEX IF NOT EXISTS ix_points_account_detail_account_type_key
  ON public.points_account_detail (account_type_key);

-- ===== private.user_transaction =====
CREATE INDEX IF NOT EXISTS ix_user_transaction_account_id
  ON private.user_transaction (account_id);
CREATE INDEX IF NOT EXISTS ix_user_transaction_self_account_id
  ON private.user_transaction (self_account_id);
CREATE INDEX IF NOT EXISTS ix_user_transaction_income_category_key
  ON private.user_transaction (income_category_key);
CREATE INDEX IF NOT EXISTS ix_user_transaction_expense_category_key
  ON private.user_transaction (expense_category_key);
-- Composite for api.net_worth / api.net_value_by_account roll-ups
CREATE INDEX IF NOT EXISTS ix_user_transaction_account_date
  ON private.user_transaction (account_id, trx_date);

-- ===== private.user_points_transaction =====
CREATE INDEX IF NOT EXISTS ix_user_points_transaction_account_id
  ON private.user_points_transaction (account_id);
CREATE INDEX IF NOT EXISTS ix_user_points_transaction_account_date
  ON private.user_points_transaction (account_id, trx_date);

-- ===== stocks.asset_symbol_master =====
CREATE INDEX IF NOT EXISTS ix_asset_symbol_master_isin_code
  ON stocks.asset_symbol_master (isin_code);

-- ===== stocks.user_transaction =====
CREATE INDEX IF NOT EXISTS ix_stocks_user_transaction_account_id
  ON stocks.user_transaction (account_id);
CREATE INDEX IF NOT EXISTS ix_stocks_user_transaction_isin_code
  ON stocks.user_transaction (isin_code);
CREATE INDEX IF NOT EXISTS ix_stocks_user_transaction_account_date
  ON stocks.user_transaction (account_id, trade_date);
