# Changelog

<div align = "justify">

All notable changes, bug-fixes, and improvements will be documented here. The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html). Please note, each version release is captioned as `<Version-Number> - <Release Date>` format.

</div>

## [v1.0.0-rc.1] - 2026-06-08

First release candidate after the multi-phase `refactor/database` work.

### Added
- **Phase 1 — Security baseline.** Roles triad (`web_anon`/`web_user`), JWT signer in `meta.config`, RLS policies on every per-user table, audit columns on protected tables, `api.login` bcrypt flow.
- **Phase 2 — Schema correctness.** Domain `CHECK` constraints, FK covering indexes, dashboard composite indexes, IPO PK fix (`(isin_code, po_type, opening_date)`), `account_type_key` widened to `VARCHAR(16)`, MF quantity `NUMERIC(18,6)`.
- **Phase 3 — Double-entry core.** `private.transaction_header` + `private.transaction_line` with deferrable balance trigger (≥ 2 lines per uid, Σ debit × fx = Σ credit × fx), `meta.audit_log` + generic row-change trigger, `is_system` SYS/IN + SYS/EX contras, soft-delete pattern, `api.post_transaction` write RPC, `api.net_worth*` rewritten on the new storage.
- **Phase 4 — Stocks v2 + paid-tier scaffolding.** `stocks.daily_nav`, `stocks.corporate_action`, `stocks.dividend`, `stocks.price_alert`. `meta.feature_flag` + `meta.is_feature_enabled()`. `api_pro` schema + `web_pro` role. `private.attachment`. `api.fifo_realised_gains` FIFO UDF. `api.mv_holdings_vw` materialised view.
- **Tooling.** Sqitch migration harness (`sqitch.conf`, `sqitch.plan`, deploy/revert/verify per change), Docker-only workflow documented in `database/sqitch/README.md`.
- **Docs.** `database/MIGRATION.md`, `database/SECURITY.md`, `database/API.md`, `database/CLAUDE.md` as the engineering brief.

### Fixed
- Latent stocks-ordering bug in `database/initialize.sql` (constraints/indexes ran before stocks schema existed; masked because dev DBs were never truly clean).
- Latent idempotency bug in `stocks/transactions.sql`: unconditional `ALTER COLUMN trade_quantity` failed on second init once `api.mv_holdings_vw` referenced the column.

### Deferred (planned for `v1.1.0`)
- Currency & FX (§4.2), unified points ledger (§4.3), recurring/budgets/goals (§4.5).
- Live FX/NAV fetchers, alerts evaluator, LLM summary RPC, Tally/GnuCash/ITR exporters.
- Corporate-action replay onto FIFO lots and `mv_holdings_vw`.

<div align = "justify">
