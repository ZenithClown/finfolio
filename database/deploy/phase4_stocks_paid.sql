-- Deploy finfolio:phase4_stocks_paid to pg
-- requires: baseline_v02

BEGIN;

\cd ..
\i database/schema/stocks/market_data.sql
\i database/schema/stocks/alerts.sql
\i database/schema/private/attachments.sql
\i database/schema/meta/feature_flag.sql
\i database/schema/api_pro/initialize.sql
\i database/api/functions/fifo_realised_gains.sql
\i database/api/views/mv_holdings_vw.sql

-- Refresh grants so web_user picks up the new RPC + matview.
-- (security/grants.sql is fully idempotent — every statement is a GRANT,
-- which is set-replace on PostgreSQL.)
\i database/security/grants.sql

COMMIT;
