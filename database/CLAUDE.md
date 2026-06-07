# `finfolio` — Database Engineering Brief (CLAUDE.md)

> **Audience:** Future contributors and AI assistants (Claude / Copilot / Codex) working in `./database/**`.
> **Status:** Living document. Last full audit: 2026-06-07.
> **Authoritative for:** schema conventions, security model, bug ledger, feature backlog, roadmap.
> **Companion files:** `../schema.dbml` (ERD), `../postgrest.conf` (API config), `../README.md` (project overview).

---

## 0. TL;DR for Agents

If you are an AI agent making changes inside `./database/**`, read this checklist **before any edit**:

1. The schema is split into 6 namespaces: `meta`, `public`, `private`, `stocks`, `api`, `base`. Pick the right one — see §2.
2. **Never expose** internal tables to PostgREST. Only `api.*` is reachable over HTTP (`postgrest.conf` → `db-schemas = "api"`). Wrap data with views/RPC under `api`.
3. The DB has a **single super-administrator (ROOT) invariant** enforced by `meta.root_user_exists()`. Don't break it.
4. RLS is the security boundary in production. Anything new on `private.*` and ownership-bearing tables in `public.*` **must** carry an RLS policy keyed off `current_setting('request.jwt.claim.username', true)`.
5. Every transactional table needs `created_on TIMESTAMPTZ DEFAULT now()` and `updated_on TIMESTAMPTZ` wired to the `public.onupdate()` trigger.
6. Money columns are **`NUMERIC(18, 6)`** (not `(12,2)`) to support multi-currency, FX, and mutual-fund unit fractions. Every monetary row carries a `currency_code CHAR(3)` referencing `meta.currency_master`.
7. Run `psql -f database/initialize.sql` against a clean DB and confirm exit code 0 before pushing.
8. Update `../schema.dbml` in the same commit as any DDL change (DBML is the public-facing contract via dbdocs.io).
9. Migrations are managed by **sqitch** (decision Q3) under `database/{deploy,revert,verify}/`, tracked by `database/sqitch.plan`. Do not hand-edit applied migrations — add a new one. See `database/sqitch/README.md` for the full workflow.
10. Open the §6 bug ledger before adding new features — many planned features depend on Phase 0/1 fixes.

---

## 1. Project Mission & Product Tiers

`finfolio` is a **privacy-first, self-hosted personal-finance and portfolio-management system**. Data never leaves the user's machine; the only network surface is the localhost PostgREST API consumed by the Next.js dashboard.

### 1.1 Product Tiers (confirmed via interview, see §10)

| Tier | What's included |
| ---- | --------------- |
| **Free (forever, single-host)** | All schema correctness fixes; double-entry bookkeeping; multi-currency; recurring transactions; budgets & goals; soft-delete/void; audit log; RLS + JWT auth; basic stocks tracking (NSE/BSE/MFs); net-worth, category, fiscal-year reports; CSV import/export. |
| **Paid (premium add-on)** | Receipt attachments; live FX & NAV fetchers; alerts engine; FIFO realised gains; corporate-actions handling; LLM summary notes; advanced exporters (Tally, GnuCash, ITR-prefill); collaborator/advisor roles. |

Premium-only RPC lives in a separate schema **`api_pro`** (not yet created). Feature gating is centralised in `meta.feature_flag(feature_key, tier)`.

### 1.2 Confirmed Product Decisions

| # | Decision | Implication |
|---|----------|-------------|
| Q1 | Double-entry is **free-tier**. | Header/lines schema split (E1) lands in Phase 3, not paid. |
| Q2 | **PostgREST-native JWT** via `pgjwt`. | `api.login` returns a signed token; RLS policies read `request.jwt.claims`. |
| Q3 | **sqitch** for migrations. ✅ landed on `tooling/sqitch`. | Plain SQL, PG-native, no JVM. Layout: `database/sqitch.{conf,plan}` + `deploy/`, `revert/`, `verify/`. Baseline change `baseline_v02 @v0.2-phase2` wraps the post-Phase-2 `initialize.sql`; future changes ship one feature per change. See `database/sqitch/README.md`. |
| Q4 | **Multi-currency from day one.** | Every monetary row carries `currency_code`; `meta.currency_master` + `meta.fx_rate` from v1. |
| Q5 | **Double-entry storage, single-entry UX.** | One UI row → server expands to a header + 2 balanced lines. Reporting reads lines. |
| Q6 | **Unified ledger** (points = ledger account with `currency='PTS'`). | Drops `public.points_account_detail` & `private.user_points_transaction`; deprecate gracefully. |
| Q7 | **Indian market only (v1).** | NSE/BSE/AMFI; ISIN regex `^IN[A-Z0-9]{10}$`; INR is the reporting currency; global stocks deferred to a paid Phase 4 add-on. |

---

## 2. Schema Layout

| Schema | Purpose | Exposed over HTTP? |
|--------|---------|:------------------:|
| `meta`     | Master/lookup tables, ENUM types, integrity-guard functions, currency master, FX rates, feature flags. | Read-only via `api.*_vw` views. |
| `public`   | User accounts, ledger accounts (the "chart of accounts"). | Behind RLS, via `api.*` only. |
| `private`  | Transaction headers + balanced lines, audit log, attachments hashes, recurring templates, budgets, goals. | RLS-enforced; `api.*` RPC only. |
| `stocks`   | Optional extension: assets master, NAV, corporate actions, dividend log, IPO history. | `api.*` views/RPC. |
| `api`      | **Only schema in `db-schemas`.** Views, RPC functions, RLS-aware RPC. | ✅ Public. |
| `api_pro`  | (Phase 4) Premium-only RPC. | ✅ Public, but RPC checks `meta.feature_flag`. |
| `base`     | Internal helper functions (e.g. `get_managed_users`). | ❌ Never exposed. |

### 2.1 Naming Conventions (binding)

* `snake_case`, singular table names. **No plurals.**
* Primary keys: `pk_<table_or_logical_name>`.
* Foreign keys: `fk_<purpose>` (e.g. `fk_account_owner`).
* Unique: `uq_<purpose>`. Check: `ck_<purpose>`.
* Trigger functions: `<schema>.<verb>_<noun>()`. Triggers: `trg_<table>_<event>`.
* Views suffix `_vw`. Master tables suffix `_master` or `_mw`. Transactional tables suffix `_trx` (new tables — existing tables are grandfathered).
* User-defined functions/procedures: `_udf` / `_usp` (DBML guidance).
* Timestamps: **`created_on`** and **`updated_on`** (both `TIMESTAMPTZ`). Never `*_at`. Fix DBML drift on any commit you touch.
* Money: `NUMERIC(18, 6)` + adjacent `currency_code CHAR(3)`.
* Booleans: `is_<adj>` (e.g. `is_active`, `is_voided`).

### 2.2 Mandatory columns on every transactional table

```sql
created_on  TIMESTAMPTZ NOT NULL DEFAULT now(),
updated_on  TIMESTAMPTZ,
created_by  VARCHAR(16) REFERENCES public.user_account_detail(username),
voided_at   TIMESTAMPTZ,
voided_by   VARCHAR(16) REFERENCES public.user_account_detail(username),
void_reason TEXT
```

Bind `public.onupdate()` trigger for `updated_on`. Soft-delete only — never `DELETE`.

---

## 3. Security Model

### 3.1 Roles

| Role         | Granted privileges |
|--------------|---------------------|
| `web_anon`   | `USAGE` on `api`; `SELECT` on `api.<lookup>_vw` views (categories, account types, currencies). **Nothing else.** |
| `web_user`   | Inherits `web_anon`; `EXECUTE` on `api.*` RPCs that read/write user-owned data. |
| `web_pro`    | Inherits `web_user`; `EXECUTE` on `api_pro.*`. |
| `web_admin`  | DB-side only — for support/maintenance, never used as the JWT role. |

> **Replace `db-anon-role = "postgres"`** in `postgrest.conf` with `web_anon` before any non-localhost deployment (bug B8).

### 3.2 JWT Flow (Q2 confirmed)

* `api.login(login_by, password)` → returns `{token, exp}`.
* `pgjwt.sign(...)` with claims `{role: 'web_user', username: 'X', exp: now()+8h}`.
* `api.login` is `SECURITY DEFINER`, owned by a role with `SELECT` on `public.user_account_detail`, then `REVOKE` direct table access from `web_anon`/`web_user`.
* Dashboard sends `Authorization: Bearer <jwt>`; PostgREST switches role and exposes claims as `request.jwt.claims`.

### 3.3 RLS Pattern (binding template)

```sql
ALTER TABLE private.transaction_header ENABLE ROW LEVEL SECURITY;

CREATE POLICY p_owner_select ON private.transaction_header
  FOR SELECT USING (
    created_by IN (
      SELECT managed_username
      FROM base.get_managed_users(current_setting('request.jwt.claim.username', true))
    )
  );

CREATE POLICY p_owner_modify ON private.transaction_header
  FOR ALL USING (
    created_by = current_setting('request.jwt.claim.username', true)
  );
```

ROOT user bypasses via `base.get_managed_users` returning all usernames (existing behaviour).

### 3.4 Password Hashing

* `pgcrypto` extension is **mandatory** (currently missing — bug B9). Add to migration `0001_extensions`.
* Storage: `password = crypt(plain, gen_salt('bf', 12))`.
* Verify: `password = crypt(plain, password)`.
* Never SELECT the `password` column from any view exposed in `api`.

---

## 4. Domain Model — Target Shape (post-Phase 3)

### 4.1 Double-Entry Storage (Q5)

Replaces `private.user_transaction`:

```
private.transaction_header        -- one row per business event
  transaction_uid       UUID PK
  trx_date              DATE NOT NULL
  trx_desc              VARCHAR(512) NOT NULL
  transfer_method       meta.transaction_method
  income_category_id    INT REFERENCES meta.income_category_master (surrogate key, see E11)
  expense_category_id   INT REFERENCES meta.expense_category_master
  -- audit + soft-delete columns per §2.2

private.transaction_line          -- two or more rows per header, must balance
  line_id               BIGINT GENERATED ALWAYS AS IDENTITY PK
  transaction_uid       UUID REFERENCES transaction_header ON DELETE CASCADE
  account_id            CHAR(5) REFERENCES public.ledger_account_detail
  side                  meta.entry_side  -- ENUM ('DEBIT','CREDIT')
  amount                NUMERIC(18,6) NOT NULL CHECK (amount > 0)
  currency_code         CHAR(3) REFERENCES meta.currency_master
  fx_rate_to_base       NUMERIC(18,8) NOT NULL DEFAULT 1
  CHECK (...)
```

Invariant (deferrable trigger): `Σ debit.amount × fx = Σ credit.amount × fx` per `transaction_uid`.

The **single-entry UX** layer is a writable RPC `api.post_transaction(...)` that accepts the user's mental model (one account, one signed amount, one category) and expands it into a header + two lines internally. Reporting reads lines.

### 4.2 Currency & FX (Q4)

```
meta.currency_master(currency_code CHAR(3) PK, name, symbol, minor_unit_digits, is_active)
meta.fx_rate(rate_date DATE, base_code CHAR(3), quote_code CHAR(3), rate NUMERIC(18,8),
             PRIMARY KEY (rate_date, base_code, quote_code))
```

* Reporting currency per user: `meta.user_preference(username, key='reporting_currency', value)`.
* Default reporting currency: INR (Q7).
* Free tier ships with manual FX entry; **paid** unlocks scheduled fetch.
* `'PTS'` is a synthetic currency for reward points (Q6).

### 4.3 Unified Reward-Points Ledger (Q6)

Drop `public.points_account_detail` and `private.user_points_transaction`. A points wallet is a `ledger_account_detail` row with `account_type_key = 'WLT'` and a `currency_code = 'PTS'` plus a `conversion_factor` stored on a per-account preferences row (`meta.account_preference`). Existing data is migrated by the Phase 3 migration `0030_unify_points_ledger`.

### 4.4 Stocks (Indian-only v1, Q7)

Tables (after fixes):

* `stocks.assets_master(isin_code CHAR(12) PK CHECK (isin_code ~ '^IN[A-Z0-9]{10}$'), asset_name, asset_class, base_currency CHAR(3) DEFAULT 'INR')`.
* `stocks.asset_symbol_master` — UNIQUE `(isin_code, stock_exchange)`.
* `stocks.daily_nav(isin_code, exchange, trade_date, close_price, PRIMARY KEY ...)`.
* `stocks.corporate_action(isin_code, action_type, ratio, ex_date, record_date)`.
* `stocks.dividend_received(isin_code, account_id, pay_date, amount, currency_code)`.
* `stocks.user_transaction.trade_quantity NUMERIC(18,6)`; extended `trade_type` to `('BUY','SELL','SIP','STP','SWP','DIV_REINVEST')`.
* `stocks.historic_public_offering` PK = `(isin_code, po_type, opening_date)`.

Each stock transaction must auto-generate the cash-leg posting against the linked debit account (per §4.1).

### 4.5 Budgets, Goals, Recurring (Phase 3)

* `private.budget(username, category_id, period_start, period_end, amount, currency_code)`.
* `private.goal(goal_id PK, username, target_amount, target_currency, target_date, linked_account_ids[])`.
* `private.recurring_template(template_id, owner, cadence_rule, next_run_on, last_run_on, header_template JSONB)`. Generator function `private.materialise_due_recurring()` runs from cron / pg_cron / external scheduler.

### 4.6 Attachments (Paid)

`private.transaction_attachment(transaction_uid, file_uri, sha256 CHAR(64), mime_type, byte_size, uploaded_on)`. Files live on disk; only the hash + URI are stored to keep DB privacy-first.

### 4.7 Audit Log

`private.audit_log(audit_id BIGSERIAL, table_name, row_pk, op CHAR(1), actor, occurred_at, diff JSONB)`. Generic trigger function `private.audit_capture()` is bound to every table touched by RLS.

---

## 5. Conventions for `api.*` and `api_pro.*`

* Every RPC takes a JSON object (PostgREST style). For multi-arg RPCs, prefer named params.
* RPCs that read user-owned data **must** filter by `base.get_managed_users(current_setting('request.jwt.claim.username', true))`. (Pattern already used in `api.net_value_by_account_type` — replicate.)
* Add `COMMENT ON FUNCTION api.<x> IS '<description>';` and `COMMENT ON COLUMN ...` on every view column. PostgREST surfaces these in Swagger — currently empty.
* Set `db-max-rows = 1000` in `postgrest.conf` to prevent accidental table dumps.
* Premium RPCs (`api_pro.*`) check `EXISTS (SELECT 1 FROM meta.feature_flag WHERE feature_key = '...' AND tier = 'PAID')` and `RAISE EXCEPTION` with HTTP-401 mapping if the deployment is free-tier.

---

## 6. Bug Ledger (line-cited; address in Phase 0/1)

Severity legend: 🔴 P0 (blocks init / runtime crash), 🟠 P1 (security or data corruption), 🟡 P2 (correctness / hygiene).
Status legend: ✅ fixed on `refactor/database`, ⏳ planned, 🕓 deferred.

### 6.1 P0 — `psql -f initialize.sql` will not succeed today

| ID | Status | File:Line | Bug | Fix |
|----|:------:|-----------|-----|-----|
| 🔴 **B1**  | ✅ | `database/schema/private/tables.sql` L62-65 | CHECK references `income_category_head` / `expense_category_head` — actual columns end in `_key`. | Relaxed to original XOR intent: `CHECK (NOT (income_category_key IS NOT NULL AND expense_category_key IS NOT NULL))` — allows uncategorised rows (bulk-import workflow) but blocks dual-category rows. Phase 3 will move this onto `transaction_header`. |
| 🔴 **B2**  | ✅ | `database/schema/meta/seed.sql` L11-28 | INSERT lists 4 columns but supplies 7 values per row. | Added the 3 subtype columns to the INSERT column list. |
| 🔴 **B3**  | ✅ | `database/schema/meta/seed.sql` L67 | Trailing `,;` syntax error after the OTT subscription row. | Removed the stray comma. *(Bundled into the B2 commit due to a working-tree race; visible in the B2 diff.)* |
| 🔴 **B4**  | ✅ | `database/schema/private/functions/set_datefields.sql` | Trigger writes to `trx_fiscalyear` / `trx_month` columns that don't exist on `private.user_transaction`. | Phase 0 interim: trigger binding commented out in `private/triggers/user_transaction.sql`. Function definition retained for Phase 3 rework as GENERATED columns. |
| 🔴 **B5**  | ✅ | `database/schema/public/template/new_ledger.sql` L14-15 | INSERTs into `account_type_id, account_subtype_id` — table actually has `account_type_key`. | Template now matches `public.ledger_account_detail` shape. |
| 🔴 **B6**  | ✅ | `database/schema/public/template/new_points_account.sql` | INSERTs into non-existent columns. | Template aligned to current `public.points_account_detail` schema; will be deleted in Phase 3 when the points table is unified into the ledger. |
| 🔴 **B7**  | ✅ | `database/initialize.sql` | Never `\i database/schema/stocks/initialize.sql` — stocks schema silently absent. | Added the include after `api/initialize.sql`. |
| 🔴 **B9**  | ✅ | `database/initialize.sql` | `pgcrypto` never created — `crypt()`, `gen_salt()` break at runtime. | `CREATE EXTENSION IF NOT EXISTS pgcrypto;` added immediately after schema creation. |
| 🔴 **B10** | ✅ | `database/schema/meta/functions/root_user_exists.sql` | UPDATE of the existing root user re-fires the EXISTS check against itself → exception on every change. | Added `AND username <> NEW.username` to the EXISTS subquery. Verified with 5-case behavioural test. |
| 🔴 **B11** | ⏳ | `database/initialize.sql` (whole) | Not idempotent. | Deferred to Phase 1 (sqitch adoption makes this moot). |
| 🔴 **B26** | ✅ | `database/initialize.sql` L95 | References non-existent file `database/schema/public/triggers/ledger_account_detail.sql` (real file: `user_account_detail.sql`). | *Newly discovered during Phase 0 baseline run.* Path corrected. |
| 🔴 **B27** | ✅ | `database/initialize.sql` + `database/api/initialize.sql` | `base/get_managed_users.sql`, `api/functions/*.sql`, `api/security/*.sql` never sourced — every documented RPC absent after init. | *Newly discovered during Phase 0 E2E run.* Added `\i` directives in correct dependency order. |

### 6.2 P1 — Security & Correctness

| ID | Status | Source | Issue | Fix |
|----|--------|--------|-------|-----|
| 🟠 **B8**  | ✅ | `postgrest.conf` L4 | `db-anon-role = "postgres"` → unauthenticated HTTP runs as superuser. | `database/security/roles.sql` creates `web_anon`/`web_user`/`authenticator`; `postgrest.conf` switched to `web_anon` + `db-max-rows = 1000`. |
| 🟠 **B11** | ✅ | `database/initialize.sql` (whole) | Re-running aborts on first object collision. | `CREATE SCHEMA IF NOT EXISTS`, `DO $$ ... EXCEPTION WHEN duplicate_object` for ENUMs, `CREATE OR REPLACE FUNCTION`, `DROP TRIGGER IF EXISTS` + recreate, `CREATE OR REPLACE VIEW`, `INSERT ... ON CONFLICT DO NOTHING`. Verified twice-run exits 0. |
| 🟠 **B19** | ✅ | `database/api/security/login.sql` | Returns user JSON not JWT; not `SECURITY DEFINER`; case-sensitive email. | Rewritten: `SECURITY DEFINER`, `SET search_path=pg_catalog,public`, lowercased email; returns `{token,exp,role,username}` signed via `base.jwt_sign` (inline plpgsql HMAC-SHA256). |
| 🟠 **F2**  | ✅ | (no existing RLS) | Owner-scoped tables wide-open. | `database/security/rls.sql` enables + FORCEs RLS on `user_account_detail` / `ledger_account_detail` / `points_account_detail` / `private.user_transaction` / `private.user_points_transaction`; policies use `base.current_username()` → `base.get_managed_users()`. |
| 🟠 **B15** | 🕓 | `database/api/functions/net_worth.sql` | Self-transfers via `self_account_id` cause one-leg miss in net-worth. | Resolved by §4.1 (every event balanced) — Phase 3. |
| 🟡 **B12** | ✅ | `schema.dbml` vs SQL | DBML drift: `account_type_key char(3)` (real: VARCHAR(7)); category keys `varchar(16)` (real: 65); `updated_at` (real: `updated_on`); missing `points_account_detail`; missing audit columns; outdated note. | Resynced in this phase. |
| 🟡 **B13** | ✅ | `meta.account_type_master.account_type_key VARCHAR(7)` | Tight: a 4-char subtype overflows. | Widened to VARCHAR(16) on master + ledger/points FK columns + 3 RPC param signatures (Phase 2). |
| 🟡 **B14** | ✅ | `database/schema/meta/seed.sql` L73, L77 | Uses `''` instead of `NULL` for missing subcategory. | Seed rows now use NULL + idempotent UPDATE backfill (Phase 2). |
| 🟡 **B16** | ✅ | `public/tables.sql` L20 | `uq_user_fullname UNIQUE` contradicts the comment. | UNIQUE dropped; replaced with case-insensitive index `ix_user_account_detail_fullname_lower` (Phase 2). |
| 🟡 **B17** | 🕓 | `public.fiscalyear` | Result not stored anywhere. | After §4.1 refactor (Phase 3). |
| 🟡 **B18** | ✅ | Multiple tables | Missing CHECKs. | 12 domain CHECKs in new `schema/constraints.sql` (idempotent ADD/DROP); covers date ordering, positive amounts, IPO price floor/ceiling (Phase 2). |
| 🟡 **B20** | ✅ | `public/tables.sql` L29 | Phone regex allows empty string. | Tightened to `phone IS NULL OR phone ~ '^[0-9+\- ]+$'` (Phase 2). |
| 🟡 **B21** | ✅ | All FK columns | No covering B-tree indexes. | 16 indexes in new `schema/indexes.sql` + composite `(account_id, trx_date)` for dashboards (Phase 2). |
| 🟡 **B22** | ✅ | `stocks.historic_public_offering` PK = `isin_code` | One asset cannot have IPO + later FPO. | Composite PK `(isin_code, po_type, opening_date)` with upgrade DO block (Phase 2). |
| 🟡 **B23** | ✅ | `stocks.user_transaction.trade_quantity NUMERIC(12,2)` | MF units have 3-4 decimals. | Widened to NUMERIC(18,6) with idempotent ALTER COLUMN (Phase 2). |
| 🟡 **B24** | ✅ | `stocks.asset_symbol_master` | Missing `UNIQUE (isin_code, stock_exchange)`. | Added inline + idempotent ALTER for upgrades (Phase 2). |
| 🟡 **B25** | ✅ | `public.user_account_detail`, `public.ledger_account_detail` | No `updated_on`; `onupdate()` not bound. | TIMESTAMPTZ `created_on`/`updated_on` added (idempotent ALTER); triggers bound; `onupdate()` switched `CURRENT_TIMESTAMP` → `clock_timestamp()` so updates within the same txn still advance. |

### 6.3 Quality / Convention

* ✅ `COMMENT ON` pass shipped (`database/api/comments.sql`) — Swagger now populated.
* ✅ `search_path` hardened on every `SECURITY DEFINER` function (`api.*`, `base.*`, `meta.root_user_exists`, `public.fiscalyear`) per CVE-2018-1058 mitigation.
* ⏳ No CI runs `psql -f initialize.sql` against a fresh PG container.
* ✅ `db-max-rows = 1000` set in `postgrest.conf`.
* ✅ Naming normalised to `updated_on` (DBML resynced).

---

## 7. Roadmap

### Phase 0 — Stop the Bleeding (≈1 day)  ✅ COMPLETE (2026-06-07)
**Goal:** `psql -f database/initialize.sql` returns 0 on a clean DB; `api.login` works.
**Tickets shipped on `refactor/database`:** B26, B1, B2, B3, B9, B7, B10, B4, B5, B6, B27 (+ a B1 relaxation amendment).
**Discovered during the phase:** B26 and B27 were not in the original 25-bug audit.
**Verification:** end-to-end smoke test in commit history; net-worth aggregation, login, managed-users RLS pattern, stocks tables, and points wallet creation all green against a fresh `postgres:16-alpine` container.

### Phase 1 — Security & Hygiene (≈3 days)  ✅ COMPLETE (2026-06-07)
**Shipped on `refactor/database`:** B11 (idempotent init), B8 (`web_anon`/`web_user`/`authenticator` roles + `postgrest.conf` rewrite + `db-max-rows`), B25 (audit columns + `clock_timestamp()` fix), B19 + Q2 (HMAC-SHA256 JWT in inline plpgsql — no `pgjwt` extension dependency), F2 (RLS policies on all owner-scoped tables driven by `request.jwt.claim.username`), CVE-2018-1058 search_path hardening across `api.*` / `base.*` / `meta.*` SECURITY DEFINER functions, COMMENT ON pass for Swagger, B12 DBML resync.
**Deferred:** Q3 (sqitch migration tooling) — landed on `tooling/sqitch` after Phase 2; merged into `refactor/database` ahead of Phase 3 so every Phase 3 change ships as a sqitch migration.
**Verification:** full init exits 0 on first run AND on re-run against populated DB; JWT signature verified via independent HMAC recompute; RLS verified by three claims (ROOT/managed/orphan) → three distinct row sets + `web_anon` `permission denied`; net_worth E2E reproduces Phase 0 baseline ₹43,500.

### Phase 2 — Schema Correctness ✅ COMPLETE
B13, B14, B16, B18, B20, B21, B22, B23, B24 — all delivered on `refactor/database` in 5 atomic commits (data-quality nits → CHECKs → FK indexes → stocks fixes → account_type_key widening). E11 (surrogate keys for category masters) and E12 (richer `transaction_method` lookup table) **deferred to Phase 3** because both are entangled with the §4.1 double-entry refactor and require data migration that is cleaner to do once.
**Verification:** twice-run idempotency holds; all CHECK constraints verified via negative-case smoke tests; `api.net_worth` continues to return the Phase 0 baseline (₹43,500); composite PO PK accepts IPO + later FPO; mutual-fund unit precision retained as 123.456700.

### Phase 3 — Free-Tier Domain Features (≈2 weeks)
* §4.1 Double-entry refactor (Q5) — biggest change; full data migration of existing `private.user_transaction` → `transaction_header` + `transaction_line`.
* §4.2 Currency & FX (Q4).
* §4.3 Unified points ledger (Q6).
* §4.5 Recurring, Budgets, Goals.
* §4.7 Audit log + soft-delete pattern.
* `api.post_transaction(...)` UX-friendly RPC.
* Updated `api.net_worth*` to read from `transaction_line` + FX.

### Phase 4 — Stocks v2 + Paid Tier (≈3 weeks)
* §4.4 Stocks Indian-market scope (Q7): NAV, corporate actions, dividends, IPO PK fix.
* `api_pro` schema bootstrap, `meta.feature_flag`.
* Attachments (§4.6).
* Live FX & NAV fetchers (paid).
* FIFO realised-gains UDF.
* Alerts engine schema.
* LLM summary RPC.
* Exporters (Tally, GnuCash, ITR-prefill).

### Phase 5 — Documentation & Release
* Regenerate dbdocs.
* `database/MIGRATION.md`, `database/SECURITY.md`, `database/API.md` (auto from PostgREST swagger).
* Versioned `1.0.0` tag.

---

## 8. Performance Patterns

### 8.1 Required Indexes (Phase 1/2)

```sql
-- FK covers
CREATE INDEX ix_trx_header_owner          ON private.transaction_header(created_by);
CREATE INDEX ix_trx_header_date           ON private.transaction_header(trx_date DESC);
CREATE INDEX ix_trx_line_header           ON private.transaction_line(transaction_uid);
CREATE INDEX ix_trx_line_account_date     ON private.transaction_line(account_id, (SELECT trx_date FROM ...));  -- materialise via view
CREATE INDEX ix_ledger_owner              ON public.ledger_account_detail(account_owner);
CREATE INDEX ix_ledger_type               ON public.ledger_account_detail(account_type_key);
CREATE INDEX ix_user_managed_by           ON public.user_account_detail(managed_by);
CREATE INDEX ix_stocks_trx_account_date   ON stocks.user_transaction(account_id, trade_date DESC);
CREATE INDEX ix_stocks_trx_isin           ON stocks.user_transaction(isin_code);
```

### 8.2 Partitioning

* `private.transaction_line` and `stocks.daily_nav` partitioned BY RANGE on year once row counts exceed ~1 M.
* `private.audit_log` partitioned monthly with retention drop after 7 fiscal years.

### 8.3 Materialised Views

* `api.mv_holdings_vw` — current portfolio + market value (Phase 4). Refresh nightly.
* `api.mv_monthly_cashflow_vw` — month × category × account aggregates.

---

## 9. Testing & CI

* **Smoke test:** `psql -f database/initialize.sql` on a fresh PG-16 Docker container in CI on every PR.
* **Migration test:** `sqitch deploy` then `sqitch revert` round-trips each new migration.
* **RLS test:** pgTAP tests under `database/tests/` confirming a `web_user` JWT cannot read another user's rows.
* **Seed test:** insert one user + one account + one transaction via `api.*`, query `api.net_worth`, assert.

---

## 10. Decision Log (Q&A confirmed 2026-06-07)

| Q | Question | Answer |
|---|----------|--------|
| 1 | Tier of double-entry bookkeeping | **Free** |
| 2 | Auth model | **PostgREST-native JWT** (pgjwt) |
| 3 | Migration tooling | **sqitch** |
| 4 | Currency support | **Multi-currency from day one** |
| 5 | Double-entry surface | **Double-entry storage with single-entry UX layer** |
| 6 | Reward-points modelling | **Unified into ledger** (`currency='PTS'`) |
| 7 | Stocks scope | **Indian market only (NSE/BSE/AMFI) for v1** |

---

## 11. Sources & References

* PostgREST v13 — *Authentication*: "PostgREST is designed to keep the database at the center of API security. All authorization happens in the database." — https://docs.postgrest.org/en/v13/references/auth.html
* PostgREST v13 — *Configuration / `db-anon-role`*: "the database role to use when executing commands on behalf of unauthenticated clients." — https://docs.postgrest.org/en/v13/references/configuration.html#db-anon-role
* PostgreSQL — *pgcrypto* extension: https://www.postgresql.org/docs/current/pgcrypto.html
* PostgreSQL — *Row Security Policies*: https://www.postgresql.org/docs/current/ddl-rowsecurity.html
* `pgjwt` extension: https://github.com/michelp/pgjwt
* sqitch — *Tutorial*: https://sqitch.org/docs/manual/sqitchtutorial/
* DBML reference: https://dbml.dbdiagram.io/home

---

## 12. Change Log of This Document

| Date       | Author        | Change |
|------------|---------------|--------|
| 2026-06-07 | DB audit pass | Initial authoritative version. Captured 25 bugs, confirmed product decisions Q1-Q7, defined 5-phase roadmap. |
| 2026-06-07 | Phase 0 implementation | Marked B1, B2, B3, B4, B5, B6, B7, B9, B10 fixed. Added B26 (broken include path) and B27 (orphaned api/base includes) discovered during baseline + E2E runs. Updated B6/B11 status, refined B1 to a less-strict CHECK. |
