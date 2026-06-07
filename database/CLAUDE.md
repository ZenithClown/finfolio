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
9. Migrations live under `database/migrations/` and are managed by **sqitch** (decision Q3). Do not hand-edit applied migrations — add a new one.
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
| Q3 | **sqitch** for migrations. | Plain SQL, PG-native, no JVM. New folder: `database/migrations/`. |
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

### 6.1 P0 — `psql -f initialize.sql` will not succeed today

| ID | File:Line | Bug | Fix |
|----|-----------|-----|-----|
| 🔴 **B1** | `database/schema/private/tables.sql` L62-65 | CHECK references `income_category_head` / `expense_category_head` — actual columns end in `_key`. Also semantically wrong (OR allows both NULL). | After §4.1 refactor, this CHECK moves to `transaction_header` as XOR: `CHECK ((income_category_id IS NULL) <> (expense_category_id IS NULL) OR is_transfer)`. |
| 🔴 **B2** | `database/schema/meta/seed.sql` L11-28 | INSERT lists 4 columns but supplies 7 values per row. | Add `account_subtype_id, account_subtype_name, account_subtype_desc` to the column list. |
| 🔴 **B3** | `database/schema/meta/seed.sql` L67 | Trailing `,;` syntax error after the OTT subscription row. | Remove the stray comma. |
| 🔴 **B4** | `database/schema/private/functions/set_datefields.sql` | Trigger writes to `trx_fiscalyear` / `trx_month` columns that don't exist on `private.user_transaction`. | After §4.1 refactor, make these `GENERATED ALWAYS AS (...) STORED` columns on `transaction_header`; drop the trigger. |
| 🔴 **B5** | `database/schema/public/template/new_ledger.sql` L14-15 | INSERTs into `account_type_id, account_subtype_id` — table actually has `account_type_key`. | Update template to match `public.ledger_account_detail`. |
| 🔴 **B6** | `database/schema/public/template/new_points_account.sql` | INSERTs into non-existent columns `points_account_owner, account_type_id, account_subtype_id`. Also: `points_account_detail` itself has no owner column. | Resolved by §4.3 (drop the table; points become a ledger account). Delete the template after migration. |
| 🔴 **B7** | `database/initialize.sql` | Never `\i database/schema/stocks/initialize.sql` — stocks schema silently absent. | Add the include behind a flag `\set stocks_enabled true`. |
| 🔴 **B9** | `database/initialize.sql` | `pgcrypto` never created — `crypt()`, `gen_salt()`, `gen_random_uuid()` (PG<13) all break. | New first-line migration `0001_extensions.sql`: `CREATE EXTENSION IF NOT EXISTS pgcrypto;` (also `pgjwt`, `pg_trgm`). |
| 🔴 **B10** | `database/schema/meta/functions/root_user_exists.sql` | UPDATE of the existing root user re-fires the `EXISTS` check against itself → exception on every change. | Guard with `TG_OP`: only check on INSERT, or on UPDATE when `OLD.user_role <> 'ROOT'`. |
| 🔴 **B11** | `database/initialize.sql` (whole) | Not idempotent: `CREATE SCHEMA`, `CREATE TYPE`, `CREATE FUNCTION` (no `OR REPLACE`), `CREATE TRIGGER` all fail on re-run. | Add `IF NOT EXISTS` / `OR REPLACE` everywhere; once sqitch is in (Q3), this becomes moot. |

### 6.2 P1 — Security & Correctness

| ID | Source | Issue | Fix |
|----|--------|-------|-----|
| 🟠 **B8**  | `postgrest.conf` L4 | `db-anon-role = "postgres"` → unauthenticated HTTP runs as superuser. | Switch to `web_anon` role (§3.1). |
| 🟠 **B19** | `database/api/security/login.sql` | Returns user JSON not JWT; not `SECURITY DEFINER`; case-sensitive email; no rate-limit. | Rewrite per §3.2 once Q2 is implemented. |
| 🟠 **B15** | `database/api/functions/net_worth.sql` | Self-transfers via `self_account_id` cause one-leg miss in net-worth. | Resolved by §4.1 (every event is balanced lines). |
| 🟡 **B12** | `schema.dbml` vs SQL | DBML drift: `account_type_key char(3)` (real: VARCHAR(7)); category keys `varchar(16)` (real: 65); `updated_at` (real: `updated_on`); missing `points_account_detail`. | Resync DBML in same commit as any DDL change. Long-term: generate one from the other. |
| 🟡 **B13** | `meta.account_type_master.account_type_key VARCHAR(7)` | Tight: a 4-char subtype overflows. | Bump to `VARCHAR(16)` once §4 surrogate keys (E11) land — the natural key becomes display-only. |
| 🟡 **B14** | `database/schema/meta/seed.sql` L73, L77 | Uses `''` instead of `NULL` for missing subcategory; collides with future single-level inserts under unique constraint. | Replace `''` with `NULL` consistently. |
| 🟡 **B16** | `public/tables.sql` L20 | `uq_user_fullname UNIQUE` contradicts the comment ("users can share names"). | Drop UNIQUE; add a non-unique index for search. |
| 🟡 **B17** | `public.fiscalyear` | Result not stored anywhere. | After §4.1 refactor, store as a generated column on `transaction_header`. |
| 🟡 **B18** | Multiple tables | Missing CHECKs: `account_closed_on >= account_opened_on`, `account_marked_inactive_on >= account_opened_on`, `trx_amount > 0`, `opening_balance_recorded_on >= account_opened_on`, `closing_date >= opening_date` and `listing_date >= closing_date` and `ceiling_price >= floor_price` on `historic_public_offering`. | Add in Phase 2. |
| 🟡 **B20** | `public/tables.sql` L29 | Phone regex `'^[0-9+\- ]*$'` allows empty string. | Use `+` quantifier and combine with `phone IS NULL OR phone ~ '^[0-9+\- ]+$'`. |
| 🟡 **B21** | All FK columns | No covering B-tree indexes → slow CASCADE and dashboard joins. | Add indexes per §8.1. |
| 🟡 **B22** | `stocks.historic_public_offering` PK = `isin_code` | One asset cannot have IPO + later FPO. | PK becomes `(isin_code, po_type, opening_date)`. |
| 🟡 **B23** | `stocks.user_transaction.trade_quantity NUMERIC(12,2)` | Mutual fund units have 3-4 decimals. | Change to `NUMERIC(18,6)`. |
| 🟡 **B24** | `stocks.asset_symbol_master` | Missing `UNIQUE (isin_code, stock_exchange)`. | Add the constraint. |
| 🟡 **B25** | `public.user_account_detail`, `public.ledger_account_detail` | No `updated_on` columns; `onupdate()` trigger not bound. | Add columns + bind trigger. |

### 6.3 Quality / Convention

* No `COMMENT ON` annotations → empty Swagger UI. Add to every API-exposed object.
* Functions don't `SET search_path` → CVE-2018-1058 surface. Add `SET search_path = pg_catalog, public` to every `SECURITY DEFINER` function.
* No CI runs `psql -f initialize.sql` against a fresh PG container — would have caught B1-B7 immediately.
* `db-max-rows` not configured in `postgrest.conf`.
* Mixed `updated_on` vs `updated_at` naming (DBML uses `_at`, SQL uses `_on`). Pick `_on`.

---

## 7. Roadmap

### Phase 0 — Stop the Bleeding (≈1 day)
**Goal:** `psql -f database/initialize.sql` returns 0 on a clean DB; `api.login` works.
**Tickets:** B1, B2, B3, B4 (interim: drop the trigger, defer fiscalyear to Phase 3), B5, B6 (delete templates), B7, B9, B10.

### Phase 1 — Security & Hygiene (≈3 days)
B8 (`web_anon`), B11 (idempotency), B19 + Q2 (JWT via `pgjwt`), §3.3 RLS template applied, B25 (audit cols), B12 (DBML resync), Q3 (sqitch bootstrap, all existing files become migration `0001_…`–`0010_…`), `COMMENT ON` pass, `db-max-rows`, `search_path` hardening.

### Phase 2 — Schema Correctness (≈2 days)
B13, B14, B16, B18, B20, B21, B22, B23, B24, E11 (surrogate keys for category masters), E12 (richer `transaction_method` — convert ENUM to lookup table for extensibility).

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
