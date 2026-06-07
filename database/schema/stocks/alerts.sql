/********************************************************************
Phase 4 — Price/Threshold Alert Schema

Stores user-defined price triggers for stocks/MFs. The *evaluator* (the
job that compares live prices and fires notifications) is paid-tier and
gated by `meta.feature_flag.alerts_engine`. This schema is free-tier
because the rows still encode user intent and we want the import/export
story to round-trip them cleanly.

Trigger semantics
-----------------
* `ABOVE`  — fire when nav_value >= threshold_value
* `BELOW`  — fire when nav_value <= threshold_value
* `CROSSES_UP`   — last close < threshold AND new close >= threshold
* `CROSSES_DOWN` — last close > threshold AND new close <= threshold

Each alert is one-shot by default (`auto_disable = TRUE`); the evaluator
flips `is_active` to FALSE after firing. Set `auto_disable = FALSE` for
recurring alerts.
********************************************************************/

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'alert_trigger_type') THEN
        CREATE TYPE stocks.alert_trigger_type AS ENUM (
            'ABOVE', 'BELOW', 'CROSSES_UP', 'CROSSES_DOWN'
        );
    END IF;
END $$;

CREATE TABLE IF NOT EXISTS stocks.price_alert (
  alert_id
    BIGINT GENERATED ALWAYS AS IDENTITY
    CONSTRAINT pk_price_alert PRIMARY KEY,

  username
    VARCHAR(16) NOT NULL
    CONSTRAINT fk_alert_user
      REFERENCES public.user_account_detail (username)
      ON DELETE CASCADE
      ON UPDATE CASCADE,

  isin_code
    CHAR(12) NOT NULL
    CONSTRAINT fk_alert_isin
      REFERENCES stocks.assets_master (isin_code)
      ON DELETE CASCADE
      ON UPDATE CASCADE,

  exchange_name
    stocks.stock_exchange NOT NULL,

  trigger_type
    stocks.alert_trigger_type NOT NULL,

  threshold_value
    NUMERIC(18, 6) NOT NULL,

  is_active
    BOOLEAN NOT NULL DEFAULT TRUE,

  auto_disable
    BOOLEAN NOT NULL DEFAULT TRUE,

  -- Set by the evaluator on fire; NULL while still armed.
  last_fired_on
    TIMESTAMPTZ,
  last_fired_value
    NUMERIC(18, 6),

  created_on
    TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_on
    TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

  CONSTRAINT ck_alert_threshold_positive CHECK (threshold_value > 0)
);

CREATE INDEX IF NOT EXISTS ix_alert_user_active
  ON stocks.price_alert (username)
  WHERE is_active = TRUE;
CREATE INDEX IF NOT EXISTS ix_alert_isin_active
  ON stocks.price_alert (isin_code, exchange_name)
  WHERE is_active = TRUE;
