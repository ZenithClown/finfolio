-- Verify finfolio:phase4_stocks_paid on pg

DO $$
BEGIN
    -- Schemas / roles
    IF NOT EXISTS (SELECT 1 FROM pg_namespace WHERE nspname = 'api_pro') THEN
        RAISE EXCEPTION 'verify: api_pro schema missing';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'web_pro') THEN
        RAISE EXCEPTION 'verify: web_pro role missing';
    END IF;

    -- Stocks v2 tables
    PERFORM 'stocks.daily_nav'::regclass;
    PERFORM 'stocks.corporate_action'::regclass;
    PERFORM 'stocks.dividend'::regclass;
    PERFORM 'stocks.price_alert'::regclass;

    -- Phase 4 §4.6 attachments
    PERFORM 'private.attachment'::regclass;

    -- Feature flag registry
    PERFORM 'meta.feature_flag'::regclass;
    IF NOT EXISTS (SELECT 1 FROM meta.feature_flag WHERE feature_key = 'fx_live_quotes') THEN
        RAISE EXCEPTION 'verify: feature_flag seed missing';
    END IF;

    -- RPC + matview
    PERFORM 1 FROM pg_proc WHERE proname = 'fifo_realised_gains' AND pronamespace = 'api'::regnamespace;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'verify: api.fifo_realised_gains missing';
    END IF;
    PERFORM 'api.mv_holdings_vw'::regclass;
END $$;
