-- Revert finfolio:phase4_stocks_paid from pg

BEGIN;

DROP MATERIALIZED VIEW IF EXISTS api.mv_holdings_vw;
DROP FUNCTION IF EXISTS api.fifo_realised_gains(CHAR(5), CHAR(12));

DROP TABLE IF EXISTS private.attachment;
DROP TABLE IF EXISTS stocks.price_alert;
DROP TABLE IF EXISTS stocks.dividend;
DROP TABLE IF EXISTS stocks.corporate_action;
DROP TABLE IF EXISTS stocks.daily_nav;
DROP TYPE  IF EXISTS stocks.alert_trigger_type;
DROP TYPE  IF EXISTS stocks.corporate_action_type;

DROP TABLE    IF EXISTS meta.feature_flag;
DROP FUNCTION IF EXISTS meta.is_feature_enabled(VARCHAR);

DROP SCHEMA IF EXISTS api_pro CASCADE;
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'web_pro') THEN
        REVOKE ALL ON DATABASE finfolio FROM web_pro;
        DROP OWNED BY web_pro;
        DROP ROLE web_pro;
    END IF;
END $$;

COMMIT;
