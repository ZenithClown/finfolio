/********************************************************************
Domain CHECK Constraints (Phase 2 — B18)

-- ..versionadded:: 2026-06-07 [B18] enforce the contractual invariants
the data model already assumes everywhere else: dates that should be
non-decreasing, amounts that should be positive, prices that should
be ordered. All constraints are added via ALTER TABLE ... ADD
CONSTRAINT (after DROP IF EXISTS) so the script is fully idempotent
and safely runs against populated clusters.

Constraints live in one file (instead of being inlined per table) so
the rules stay together for review and audit.
********************************************************************/

-- =====================================================================
-- public.ledger_account_detail
-- =====================================================================
ALTER TABLE public.ledger_account_detail
  DROP CONSTRAINT IF EXISTS ck_ledger_close_after_open;
ALTER TABLE public.ledger_account_detail
  ADD  CONSTRAINT ck_ledger_close_after_open CHECK (
    account_closed_on IS NULL OR account_closed_on >= account_opened_on
  );

ALTER TABLE public.ledger_account_detail
  DROP CONSTRAINT IF EXISTS ck_ledger_inactive_after_open;
ALTER TABLE public.ledger_account_detail
  ADD  CONSTRAINT ck_ledger_inactive_after_open CHECK (
    account_marked_inactive_on IS NULL
      OR account_marked_inactive_on >= account_opened_on
  );

ALTER TABLE public.ledger_account_detail
  DROP CONSTRAINT IF EXISTS ck_ledger_opening_recorded_after_open;
ALTER TABLE public.ledger_account_detail
  ADD  CONSTRAINT ck_ledger_opening_recorded_after_open CHECK (
    opening_balance_recorded_on >= account_opened_on
  );

-- =====================================================================
-- public.points_account_detail
-- =====================================================================
ALTER TABLE public.points_account_detail
  DROP CONSTRAINT IF EXISTS ck_points_conversion_positive;
ALTER TABLE public.points_account_detail
  ADD  CONSTRAINT ck_points_conversion_positive CHECK (conversion_factor > 0);

-- =====================================================================
-- private.user_transaction
-- =====================================================================
ALTER TABLE private.user_transaction
  DROP CONSTRAINT IF EXISTS ck_trx_amount_positive;
ALTER TABLE private.user_transaction
  ADD  CONSTRAINT ck_trx_amount_positive CHECK (trx_amount > 0);

-- =====================================================================
-- private.user_points_transaction
-- =====================================================================
ALTER TABLE private.user_points_transaction
  DROP CONSTRAINT IF EXISTS ck_pts_trx_amount_positive;
ALTER TABLE private.user_points_transaction
  ADD  CONSTRAINT ck_pts_trx_amount_positive CHECK (trx_points_amount > 0);

-- =====================================================================
-- stocks.historic_public_offering
-- =====================================================================
ALTER TABLE stocks.historic_public_offering
  DROP CONSTRAINT IF EXISTS ck_po_closing_after_opening;
ALTER TABLE stocks.historic_public_offering
  ADD  CONSTRAINT ck_po_closing_after_opening CHECK (closing_date >= opening_date);

ALTER TABLE stocks.historic_public_offering
  DROP CONSTRAINT IF EXISTS ck_po_listing_after_closing;
ALTER TABLE stocks.historic_public_offering
  ADD  CONSTRAINT ck_po_listing_after_closing CHECK (listing_date >= closing_date);

ALTER TABLE stocks.historic_public_offering
  DROP CONSTRAINT IF EXISTS ck_po_ceiling_ge_floor;
ALTER TABLE stocks.historic_public_offering
  ADD  CONSTRAINT ck_po_ceiling_ge_floor CHECK (ceiling_price >= floor_price);

ALTER TABLE stocks.historic_public_offering
  DROP CONSTRAINT IF EXISTS ck_po_floor_positive;
ALTER TABLE stocks.historic_public_offering
  ADD  CONSTRAINT ck_po_floor_positive CHECK (floor_price > 0);

-- =====================================================================
-- stocks.user_transaction
-- =====================================================================
ALTER TABLE stocks.user_transaction
  DROP CONSTRAINT IF EXISTS ck_strx_quantity_positive;
ALTER TABLE stocks.user_transaction
  ADD  CONSTRAINT ck_strx_quantity_positive CHECK (trade_quantity > 0);

ALTER TABLE stocks.user_transaction
  DROP CONSTRAINT IF EXISTS ck_strx_price_nonneg;
ALTER TABLE stocks.user_transaction
  ADD  CONSTRAINT ck_strx_price_nonneg CHECK (trade_price >= 0);
