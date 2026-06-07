/********************************************************************
Phase 4 §4.4 — Stocks v2 Market Data

Three additive tables on the existing `stocks` schema:

  1. `stocks.daily_nav`        — one row per (isin, exchange, date)
                                 carrying the closing NAV/price.
  2. `stocks.corporate_action` — splits, bonuses, mergers, demergers,
                                 rights — anything that changes the
                                 quantity or cost basis of a holding
                                 without a user trade.
  3. `stocks.dividend`         — declared/paid dividends per ISIN.

All three are write-once, never silently mutated. Free-tier installs
populate them via CSV/manual upload; paid-tier installs (gated by
`meta.feature_flag.nav_live_quotes`) ingest from live feeds.

Design notes
------------
* `daily_nav` is a *fact* table; expect millions of rows once history is
  backfilled. Partitioning by year is deferred (§8.2) until row counts
  warrant it; for now a single table + (isin, nav_date) composite PK
  serves the planner well.
* `corporate_action` is intentionally schema-light: `payload JSONB`
  carries action-specific fields (ratio for splits, record_date for
  rights, etc.) so we don't reshape the table for every new action type.
* `dividend` is split out from `corporate_action` because dividends are
  cash events (they post a cash leg via §4.1) whereas the rest are
  quantity-only events.
********************************************************************/

-- =====================================================================
-- meta.corporate_action_type — ENUM of supported actions
-- =====================================================================
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'corporate_action_type') THEN
        CREATE TYPE stocks.corporate_action_type AS ENUM (
            'SPLIT',
            'BONUS',
            'RIGHTS',
            'MERGER',
            'DEMERGER',
            'BUYBACK',
            'CONSOLIDATION',
            'NAME_CHANGE',
            'ISIN_CHANGE'
        );
    END IF;
END $$;

-- =====================================================================
-- stocks.daily_nav — closing price/NAV time series
-- =====================================================================
CREATE TABLE IF NOT EXISTS stocks.daily_nav (
  isin_code
    CHAR(12) NOT NULL
    CONSTRAINT fk_dnav_isin
      REFERENCES stocks.assets_master (isin_code)
      ON DELETE CASCADE
      ON UPDATE CASCADE,

  exchange_name
    stocks.stock_exchange NOT NULL,

  nav_date
    DATE NOT NULL,

  nav_value
    NUMERIC(18, 6) NOT NULL,

  -- AMFI publishes a daily NAV; exchanges publish OHLC. Optional
  -- OHLC columns let us reuse this table for equities + MFs without
  -- a parallel `daily_price` cousin.
  open_value     NUMERIC(18, 6),
  high_value     NUMERIC(18, 6),
  low_value      NUMERIC(18, 6),
  volume         BIGINT,

  source
    VARCHAR(32) NOT NULL DEFAULT 'manual',

  created_on
    TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT pk_daily_nav PRIMARY KEY (isin_code, exchange_name, nav_date),
  CONSTRAINT ck_dnav_positive CHECK (nav_value > 0)
);

CREATE INDEX IF NOT EXISTS ix_daily_nav_date
  ON stocks.daily_nav (nav_date DESC);

-- =====================================================================
-- stocks.corporate_action — quantity/cost-basis events
-- =====================================================================
CREATE TABLE IF NOT EXISTS stocks.corporate_action (
  corporate_action_id
    BIGINT GENERATED ALWAYS AS IDENTITY
    CONSTRAINT pk_corporate_action PRIMARY KEY,

  isin_code
    CHAR(12) NOT NULL
    CONSTRAINT fk_ca_isin
      REFERENCES stocks.assets_master (isin_code)
      ON DELETE CASCADE
      ON UPDATE CASCADE,

  action_type
    stocks.corporate_action_type NOT NULL,

  ex_date         DATE NOT NULL,
  record_date     DATE,
  effective_date  DATE,

  -- action-specific payload (ratio for SPLIT/BONUS, target_isin for
  -- MERGER, price for BUYBACK, etc.) — kept flexible on purpose.
  payload         JSONB NOT NULL DEFAULT '{}'::JSONB,

  notes           VARCHAR(512),

  created_on
    TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by
    VARCHAR(16),

  CONSTRAINT uq_corporate_action UNIQUE (isin_code, action_type, ex_date)
);

CREATE INDEX IF NOT EXISTS ix_corporate_action_isin
  ON stocks.corporate_action (isin_code);
CREATE INDEX IF NOT EXISTS ix_corporate_action_ex_date
  ON stocks.corporate_action (ex_date DESC);

-- =====================================================================
-- stocks.dividend — cash dividend declarations
-- =====================================================================
CREATE TABLE IF NOT EXISTS stocks.dividend (
  dividend_id
    BIGINT GENERATED ALWAYS AS IDENTITY
    CONSTRAINT pk_dividend PRIMARY KEY,

  isin_code
    CHAR(12) NOT NULL
    CONSTRAINT fk_div_isin
      REFERENCES stocks.assets_master (isin_code)
      ON DELETE CASCADE
      ON UPDATE CASCADE,

  declaration_date  DATE NOT NULL,
  ex_date           DATE NOT NULL,
  record_date       DATE,
  payment_date      DATE,

  amount_per_unit   NUMERIC(18, 6) NOT NULL,
  currency_code     CHAR(3) NOT NULL DEFAULT 'INR',

  -- INTERIM / FINAL / SPECIAL etc. — free text for now; promote to
  -- ENUM once domain stabilises.
  dividend_type     VARCHAR(16) NOT NULL DEFAULT 'FINAL',

  created_on
    TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT uq_dividend UNIQUE (isin_code, ex_date, dividend_type),
  CONSTRAINT ck_div_positive CHECK (amount_per_unit > 0)
);

CREATE INDEX IF NOT EXISTS ix_dividend_isin ON stocks.dividend (isin_code);
CREATE INDEX IF NOT EXISTS ix_dividend_ex_date ON stocks.dividend (ex_date DESC);
