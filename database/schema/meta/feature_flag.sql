/********************************************************************
Phase 4 — Feature Flag Registry

A tiny key-value table that gates paid-tier (`api_pro.*`) functionality
without forcing a separate database or a heavyweight entitlement
service. Reads are cheap (single PK lookup) and writes are admin-only.

Usage from an RPC:

    IF NOT meta.is_feature_enabled('fx_live_quotes') THEN
        RAISE EXCEPTION USING
            ERRCODE = '42501',
            MESSAGE = 'feature fx_live_quotes is not enabled on this tenant';
    END IF;

A flag is "enabled" when:
  * the row exists, AND
  * `is_enabled = TRUE`, AND
  * (`enabled_until` IS NULL OR `enabled_until` > now()).

Free-tier installations ship with every paid flag = FALSE. Phase 4
paid-tier installers flip the relevant rows.
********************************************************************/

CREATE TABLE IF NOT EXISTS meta.feature_flag (
  feature_key
    VARCHAR(64) NOT NULL
    CONSTRAINT pk_feature_flag PRIMARY KEY,

  description
    VARCHAR(512) NOT NULL,

  is_enabled
    BOOLEAN NOT NULL DEFAULT FALSE,

  -- optional time-boxed entitlement (trials, lapsed subscriptions)
  enabled_until
    TIMESTAMPTZ,

  created_on
    TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_on
    TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_by
    VARCHAR(16)
);

CREATE OR REPLACE FUNCTION meta.is_feature_enabled(p_feature_key VARCHAR)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
AS $$
    SELECT COALESCE(
        (SELECT is_enabled
                AND (enabled_until IS NULL OR enabled_until > CURRENT_TIMESTAMP)
           FROM meta.feature_flag
          WHERE feature_key = p_feature_key),
        FALSE
    );
$$;

-- Seed the canonical paid-tier flag catalog. Idempotent.
INSERT INTO meta.feature_flag (feature_key, description, is_enabled) VALUES
  ('fx_live_quotes',        'Live FX rate refresh via paid provider',                FALSE),
  ('nav_live_quotes',       'Live NAV refresh from AMFI/exchange feeds',             FALSE),
  ('llm_summary',           'LLM-backed narrative summary RPC',                      FALSE),
  ('alerts_engine',         'Price/threshold alert evaluator',                       FALSE),
  ('export_tally',          'Tally XML export',                                      FALSE),
  ('export_gnucash',        'GnuCash XML export',                                    FALSE),
  ('export_itr_prefill',    'ITR (Indian income-tax return) prefill export',         FALSE),
  ('mv_holdings_auto',      'Nightly auto-refresh of api_pro.mv_holdings_vw',        FALSE)
ON CONFLICT (feature_key) DO NOTHING;
