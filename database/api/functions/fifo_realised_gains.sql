/********************************************************************
Phase 4 — FIFO Realised Gains UDF

Indian tax law (and most other jurisdictions) requires First-In-First-Out
cost-basis matching for capital gains: the first lot bought is the first
lot sold. This RPC walks every BUY/SELL on `stocks.user_transaction` for
a given (account, isin) pair in trade-date order, maintains a FIFO queue
of open buy lots, and emits one row per SELL with its matched cost basis,
holding period, and realised P&L.

Output columns
--------------
* sell_date         — date of the closing trade
* isin_code         — instrument
* exchange_name     — exchange the sell happened on
* quantity_sold     — units closed
* sell_value        — gross proceeds
* cost_basis        — sum of matched buy-side cost (FIFO)
* realised_gain     — sell_value - cost_basis
* holding_days      — weighted-average days between matched buy(s) and sell
* is_long_term      — TRUE if holding_days > 365 (Indian equity rule;
                      consumers can re-classify for debt/MF if needed)

Notes
-----
* Brokerage/charges are NOT pulled in; this UDF reports gross gains
  only. Net-of-charges reporting is deferred to a Phase 4.5 RPC that
  joins to a (future) `stocks.trade_charge` table.
* Corporate actions (splits/bonuses) are NOT yet applied to the FIFO
  queue. A SPLIT 1:2 on a 100-unit lot should leave a 200-unit lot. This
  is documented as a known limitation in CLAUDE.md §7 Phase 4.5 and will
  be addressed once `stocks.corporate_action` carries enough metadata
  to apply automatically.
* Returns NUMERIC(18,2) for currency values, matching `api.net_worth`.
********************************************************************/

DROP FUNCTION IF EXISTS api.fifo_realised_gains(CHAR(5), CHAR(12));

CREATE OR REPLACE FUNCTION api.fifo_realised_gains(
    p_account_id CHAR(5),
    p_isin_code  CHAR(12) DEFAULT NULL  -- NULL => all instruments
)
RETURNS TABLE (
    sell_date       DATE,
    isin_code       CHAR(12),
    exchange_name   stocks.stock_exchange,
    quantity_sold   NUMERIC(18, 6),
    sell_value      NUMERIC(18, 2),
    cost_basis      NUMERIC(18, 2),
    realised_gain   NUMERIC(18, 2),
    holding_days    INTEGER,
    is_long_term    BOOLEAN
)
LANGUAGE plpgsql
VOLATILE
SECURITY DEFINER
AS $$
DECLARE
    r_trade   RECORD;
    v_lot     RECORD;
    v_remaining     NUMERIC(18, 6);
    v_take          NUMERIC(18, 6);
    v_matched_cost  NUMERIC(18, 2);
    v_matched_days  NUMERIC(18, 6);
BEGIN
    -- Per-call FIFO queue of open BUY lots, scoped to this connection.
    CREATE TEMP TABLE IF NOT EXISTS _fifo_lots (
        isin_code       CHAR(12),
        exchange_name   stocks.stock_exchange,
        trade_date      DATE,
        qty_remaining   NUMERIC(18, 6),
        unit_cost       NUMERIC(18, 6),
        ord             BIGSERIAL
    ) ON COMMIT DROP;
    TRUNCATE _fifo_lots;

    FOR r_trade IN
        SELECT t.trade_date,
               t.isin_code,
               t.exchange_name,
               t.trade_type,
               t.trade_quantity,
               t.trade_price
          FROM stocks.user_transaction t
         WHERE t.account_id = p_account_id
           AND (p_isin_code IS NULL OR t.isin_code = p_isin_code)
         ORDER BY t.trade_date, t.transaction_idkey
    LOOP
        IF r_trade.trade_type = 'BUY' THEN
            INSERT INTO _fifo_lots (isin_code, exchange_name, trade_date,
                                    qty_remaining, unit_cost)
            VALUES (r_trade.isin_code, r_trade.exchange_name,
                    r_trade.trade_date,
                    r_trade.trade_quantity, r_trade.trade_price);

        ELSIF r_trade.trade_type = 'SELL' THEN
            v_remaining    := r_trade.trade_quantity;
            v_matched_cost := 0;
            v_matched_days := 0;

            -- Walk open lots oldest-first for the same instrument.
            FOR v_lot IN
                SELECT *
                  FROM _fifo_lots fl
                 WHERE fl.isin_code     = r_trade.isin_code
                   AND fl.exchange_name = r_trade.exchange_name
                   AND fl.qty_remaining > 0
                 ORDER BY fl.trade_date, fl.ord
            LOOP
                EXIT WHEN v_remaining <= 0;

                v_take := LEAST(v_remaining, v_lot.qty_remaining);
                v_matched_cost := v_matched_cost + (v_take * v_lot.unit_cost);
                v_matched_days := v_matched_days
                                  + (v_take * (r_trade.trade_date - v_lot.trade_date));

                UPDATE _fifo_lots
                   SET qty_remaining = qty_remaining - v_take
                 WHERE ord = v_lot.ord;

                v_remaining := v_remaining - v_take;
            END LOOP;

            -- Emit one row per sell, even if (in pathological data) lots
            -- ran dry — the consumer can spot short-sell artefacts.
            sell_date     := r_trade.trade_date;
            isin_code     := r_trade.isin_code;
            exchange_name := r_trade.exchange_name;
            quantity_sold := r_trade.trade_quantity;
            sell_value    := ROUND(r_trade.trade_quantity * r_trade.trade_price, 2);
            cost_basis    := ROUND(v_matched_cost, 2);
            realised_gain := sell_value - cost_basis;
            holding_days  := CASE
                                WHEN r_trade.trade_quantity > 0
                                    THEN ROUND(v_matched_days / r_trade.trade_quantity)::INTEGER
                                ELSE NULL
                             END;
            is_long_term  := COALESCE(holding_days, 0) > 365;
            RETURN NEXT;
        END IF;
    END LOOP;

    RETURN;
END;
$$;

COMMENT ON FUNCTION api.fifo_realised_gains(CHAR(5), CHAR(12)) IS
    'Phase 4: FIFO-matched realised capital gains for an account. '
    'Does NOT yet apply corporate actions; deferred to Phase 4.5.';
