/********************************************************************
Phase 4 — Holdings Materialised View

Current portfolio per (account, isin, exchange): net quantity held +
last-known NAV from `stocks.daily_nav` + market value.

This is a *materialised* view so the dashboard's portfolio page is one
indexed lookup instead of a full scan of `stocks.user_transaction`. The
refresh policy is owner-driven:

    REFRESH MATERIALIZED VIEW CONCURRENTLY api.mv_holdings_vw;

The CONCURRENTLY mode requires a UNIQUE index — we ship one on
(account_id, isin_code, exchange_name) below. A nightly cron (paid-tier,
gated by `meta.feature_flag.mv_holdings_auto`) refreshes the view; on
free-tier the dashboard refreshes on-demand after every stock trade.

Notes
-----
* Net quantity uses signed sum (BUY = +, SELL = -). `trade_special_flag`
  rows (IPO_ALLOTTED, BONUS_ISSUE, RIGHT_ISSUE) live on the BUY rows
  themselves so they are already counted; the dedicated special-flag-as-
  trade-type ENUM that an earlier draft assumed does NOT exist (see
  `stocks.trade_type` vs `stocks.trade_special_flag`).
* `last_nav` is the most recent daily_nav for the (isin, exchange) pair
  regardless of date — consumers can detect stale prices via
  `last_nav_date < CURRENT_DATE - 5` or similar.
* `market_value` is NULL when no NAV exists, never zero — zero would
  silently look like a closed position.
********************************************************************/

DROP MATERIALIZED VIEW IF EXISTS api.mv_holdings_vw;

CREATE MATERIALIZED VIEW api.mv_holdings_vw AS
WITH net_qty AS (
    SELECT t.account_id,
           t.isin_code,
           t.exchange_name,
           SUM(
               CASE
                   WHEN t.trade_type = 'BUY'  THEN  t.trade_quantity
                   WHEN t.trade_type = 'SELL' THEN -t.trade_quantity
                   ELSE 0
               END
           )::NUMERIC(18, 6)  AS quantity,
           SUM(
               CASE WHEN t.trade_type = 'BUY'
                    THEN t.trade_quantity * t.trade_price
                    ELSE 0
               END
           )::NUMERIC(18, 2)  AS gross_cost,
           SUM(
               CASE WHEN t.trade_type = 'BUY'
                    THEN t.trade_quantity ELSE 0 END
           )::NUMERIC(18, 6)  AS gross_buy_qty
      FROM stocks.user_transaction t
     GROUP BY t.account_id, t.isin_code, t.exchange_name
), latest_nav AS (
    SELECT DISTINCT ON (n.isin_code, n.exchange_name)
           n.isin_code, n.exchange_name, n.nav_date, n.nav_value
      FROM stocks.daily_nav n
     ORDER BY n.isin_code, n.exchange_name, n.nav_date DESC
)
SELECT nq.account_id,
       nq.isin_code,
       nq.exchange_name,
       am.asset_name,
       am.asset_class,
       nq.quantity,
       CASE WHEN nq.gross_buy_qty > 0
            THEN ROUND(nq.gross_cost / nq.gross_buy_qty, 4)
       END                                                            AS avg_cost,
       ln.nav_value                                                   AS last_nav,
       ln.nav_date                                                    AS last_nav_date,
       CASE WHEN ln.nav_value IS NOT NULL
            THEN ROUND(nq.quantity * ln.nav_value, 2)
       END                                                            AS market_value,
       CASE WHEN ln.nav_value IS NOT NULL AND nq.gross_buy_qty > 0
            THEN ROUND(
                    nq.quantity * ln.nav_value
                    - nq.quantity * (nq.gross_cost / nq.gross_buy_qty),
                    2)
       END                                                            AS unrealised_gain
  FROM net_qty nq
  JOIN stocks.assets_master am ON am.isin_code = nq.isin_code
  LEFT JOIN latest_nav ln
         ON ln.isin_code     = nq.isin_code
        AND ln.exchange_name = nq.exchange_name
 WHERE nq.quantity > 0;

-- Required for REFRESH MATERIALIZED VIEW CONCURRENTLY.
CREATE UNIQUE INDEX IF NOT EXISTS uq_mv_holdings
  ON api.mv_holdings_vw (account_id, isin_code, exchange_name);

CREATE INDEX IF NOT EXISTS ix_mv_holdings_account
  ON api.mv_holdings_vw (account_id);

COMMENT ON MATERIALIZED VIEW api.mv_holdings_vw IS
    'Phase 4: current holdings + market value per (account, isin, exchange). '
    'Refresh CONCURRENTLY after stock trades or NAV ingest.';
