# `finfolio` database

> Privacy-first, single-tenant personal-finance schema for PostgreSQL 14+, exposed over HTTP via PostgREST. Designed for localhost / family-NAS deployments, with a clean free-tier / paid-tier split.

| | |
|---|---|
| **Engine** | PostgreSQL 14+ (tested on 16-alpine) |
| **API** | PostgREST (read `db-schemas = "api"` and, for premium installs, `api,api_pro`) |
| **Status** | `v1.0.0-rc.1` on `refactor/database` (Phase 0 -> Phase 5 + post-RC1 hotfixes) |
| **Source of truth** | `database/**/*.sql` (init via `database/initialize.sql`) |
| **Schema diagram** | `schema.dbml` -> [dbdocs.io](https://dbdocs.io) |
| **Companion docs** | [`CLAUDE.md`](./CLAUDE.md) - engineering brief & bug ledger -  [`MIGRATION.md`](./MIGRATION.md) - provisioning + upgrades -  [`SECURITY.md`](./SECURITY.md) - role triad, RLS, JWT, audit -  [`API.md`](./API.md) - every `api.*` / `api_pro.*` RPC |

---

## 1. What you get

### 1.1 Schema layout

| Schema | Purpose |
|---|---|
| `meta` | Master data, ENUMs, helper functions, audit log, feature flags. |
| `public` | User accounts, ledger accounts, points wallets (the "directory"). |
| `private` | Transactional core: `transaction_header` + double-entry `transaction_line`, attachments, soft-delete columns. |
| `stocks` | Equity / mutual-fund assets, symbols, transactions, NAV history, corporate actions, dividends, price alerts. |
| `api` | PostgREST surface for the free tier. All RPCs are `SECURITY DEFINER` with locked `search_path`. |
| `api_pro` | PostgREST surface for the paid tier, gated by `meta.feature_flag`. |
| `base` | Internal helpers not exposed to PostgREST. |

### 1.2 Feature highlights (by phase)

- **Phase 0 - Stop-the-bleeding**: every P0 init bug (B1-B7, B9, B10, B26, B27) fixed; `psql -f initialize.sql` runs clean end-to-end on a fresh cluster.
- **Phase 1 - Security & hygiene**:
  - Least-privilege role triad `authenticator` / `web_anon` / `web_user` (+ `web_pro` in Phase 4); `postgrest.conf` switched off the superuser anon role and gets `db-max-rows = 1000`.
  - `pgjwt`-issued JWTs from `api.login`, claims-driven `current_setting('request.jwt.claim.username')` plumbing.
  - Row-Level Security on every owner-scoped table, walked through the `managed_by` graph (family hierarchies).
  - Full FK + hot-path index coverage (B21).
  - `meta.audit_log` with a generic JSONB-diff trigger; `updated_on` everywhere.
- **Phase 2 - Schema correctness**: B13-B18, B20, B22-B24 fixed; surrogate keys for category masters (E11); expanded `transaction_method` lookup table (E12); `points_account_owner` (E5/B6).
- **Phase 3 - Double-entry core**:
  - `private.transaction_header` (1 row per business event) + `private.transaction_line` (n debit/credit legs, sum-to-zero per currency, enforced by deferrable constraint trigger).
  - System contra accounts SYSIN / SYSEX for single-leg income/expense bookings.
  - `api.post_transaction(payload jsonb) RETURNS uuid` - idempotent via JWT-key + client request id; returns the same UUID on retry.
  - `api.net_worth`, `api.net_value_by_account`, `api.net_value_by_account_type` rewritten on top of double-entry lines.
- **Phase 4 - Stocks v2 & paid tier**:
  - `stocks.daily_nav` (PK `(isin_code, exchange_name, nav_date)`), `stocks.corporate_action` (JSONB payload), `stocks.dividend`, `stocks.price_alert`.
  - `api_pro.mv_holdings_vw` materialised view (signed quantities x latest NAV, unrealised gain).
  - `api_pro.fifo_realised_gains(account_id, from_date, to_date)` returning per-lot realised P&L with long-/short-term flag.
  - `private.attachment` table (hash + URI; blob lives outside Postgres) + alerts engine hooks.
  - `meta.feature_flag` registry; every paid feature ships disabled in free installs.
- **Phase 5 - Documentation & RC1**: `MIGRATION.md`, `SECURITY.md`, `API.md`, `CHANGELOG.md`, `VERSION=v1.0.0-rc.1`, sqitch migration tooling (`sqitch.plan` with `baseline_v02 @v0.2-phase2` + `phase4_stocks_paid @v0.4-phase4`).
- **Post-RC1 hotfixes (2026-06-08)**: B28 SYSIN auto-seed via trigger + `meta.ensure_system_accounts()`, B29 `fifo_realised_gains` `STABLE` -> `VOLATILE`, B30 ambiguous `isin_code` aliasing, DBML resync of all six Phase 4 tables.

### 1.3 Free vs Paid

Every paid feature reads from `meta.feature_flag(feature_key, is_enabled)`; free installs ship with every flag = `false`. Paid switches are flipped by an installer running as `web_pro`. The full split is in `CLAUDE.md` §3.D.

---

## 2. Getting started

### 2.1 Prerequisites

- PostgreSQL **14 or later** (16 recommended; tested on `postgres:16-alpine`).
- `psql` client on your `PATH`.
- Optional: Docker / Podman, [`sqitch`](https://sqitch.org) for migration-driven deploys, [PostgREST](https://postgrest.org) for the HTTP layer.

### 2.2 Quick start (one-shot psql, recommended for localhost)

```powershell
# 1. Create a database
createdb finfolio

# 2. From the repo root, run the initializer
psql -d finfolio -v ON_ERROR_STOP=1 -f database/initialize.sql

# 3. (Optional) re-run - everything is idempotent
psql -d finfolio -v ON_ERROR_STOP=1 -f database/initialize.sql
```

`initialize.sql` is path-sensitive: it must be run from the repository root (it uses `\i database/...` includes).

### 2.3 Docker-driven quick start

```powershell
# 1. Start postgres
docker network create finfolio_net
docker run -d --name finfolio_pg --network finfolio_net `
  -e POSTGRES_PASSWORD=postgres -p 55432:5432 postgres:16-alpine

# 2. Wait for ready, then initialize
docker exec -i finfolio_pg sh -c "createdb -U postgres finfolio"
docker run --rm --network finfolio_net -v "${PWD}:/work" -w /work `
  -e PGPASSWORD=postgres postgres:16-alpine `
  psql -h finfolio_pg -U postgres -d finfolio -v ON_ERROR_STOP=1 -f database/initialize.sql
```

### 2.4 Sqitch-driven deploy (preferred for upgrades & CI)

```powershell
cd database

# Deploy to v0.4-phase4 (latest)
docker run --rm --network finfolio_net -v "${PWD}/..:/repo" -w /repo/database `
  sqitch/sqitch:latest deploy db:pg://postgres:postgres@finfolio_pg:5432/finfolio

# Verify
docker run --rm --network finfolio_net -v "${PWD}/..:/repo" -w /repo/database `
  sqitch/sqitch:latest verify db:pg://postgres:postgres@finfolio_pg:5432/finfolio
```

See [`MIGRATION.md`](./MIGRATION.md) for upgrade paths from pre-refactor / `@v0.2-phase2` databases and the full breaking-change catalogue.

### 2.5 Bootstrap the first ROOT user

After init, the schema is empty - no users exist. Create the first ROOT user (this is the **only** ROOT enforced by `trg_assert_only_one_root_user`):

```sql
INSERT INTO public.user_account_detail
  (username, fullname, email, phone, password, user_role)
VALUES
  ('rootu', 'Root User', 'root@finfolio.local', '+919999999999',
   crypt('change-me-now', gen_salt('bf', 12)), 'ROOT');
```

The `AFTER INSERT` trigger `trg_seed_system_accounts` (added in the B28 hotfix) immediately seeds the SYSIN / SYSEX system contra accounts owned by this ROOT user; without them, single-leg income / expense `api.post_transaction` calls would FK-violate.

### 2.6 Run PostgREST

Minimal `postgrest.conf` (already shipped in the repo root):

```ini
db-uri          = "postgres://authenticator:CHANGE-ME@localhost:5432/finfolio"
db-schemas      = "api"
db-anon-role    = "web_anon"
db-max-rows     = 1000
jwt-secret      = "<32+ char secret>"
server-port     = 3100
```

For paid installs, set `db-schemas = "api,api_pro"`. Then:

```powershell
postgrest postgrest.conf
# Browse http://localhost:3100 - PostgREST exposes OpenAPI at the root.
```

A signed JWT is obtained from `api.login(p_login_by, p_password)`; pass it back as `Authorization: Bearer <jwt>` on every subsequent request.

### 2.7 First end-to-end check

```sql
-- Net worth before any activity (= 0)
SELECT api.net_worth('rootu');

-- Post a salary credit (free-tier double-entry RPC)
SELECT api.post_transaction(jsonb_build_object(
  'request_id',     gen_random_uuid()::text,
  'trx_date',       CURRENT_DATE,
  'narration',      'Opening salary credit',
  'lines', jsonb_build_array(
    jsonb_build_object('account_id','<your-ledger-account-id>','amount', 50000),
    jsonb_build_object('account_id','SYSIN',                    'amount', -50000)
  )
));

-- Net worth now reflects the credit
SELECT api.net_worth('rootu');
```

---

## 3. Layout reference

```
database/
  initialize.sql              -- master include, run from repo root
  sqitch.plan / sqitch.conf   -- migration tooling
  deploy/  revert/  verify/   -- sqitch change scripts
  CLAUDE.md                   -- engineering brief & bug ledger
  MIGRATION.md SECURITY.md API.md
  schema/
    meta/      (types, masters, audit_log, feature_flag, functions)
    public/    (user/ledger/points + triggers)
    private/   (transaction_header, transaction_line, system_accounts, attachment, ...)
    stocks/    (assets, symbols, transactions, market_data, alerts)
  api/
    initialize.sql            -- aggregates all of the below
    functions/                -- post_transaction, net_worth, fifo_realised_gains, ...
    views/                    -- mv_holdings_vw + masters
    security/                 -- login, JWT helpers
  api_pro/                    -- paid-tier surface
  security/
    roles.sql                 -- authenticator / web_anon / web_user / web_pro
    grants.sql                -- least-privilege wiring
    rls/                      -- per-table RLS policies
```

---

## 4. Verification & testing

The Phase 5 hotfix run validated, on a fresh `postgres:16-alpine` container:

- `psql -f database/initialize.sql` clean, then re-run clean (idempotent).
- Greenfield trigger: SYSIN/SYSEX absent -> create first ROOT -> SYSIN/SYSEX appear -> `api.post_transaction` works, `api.net_worth('rootu') = 1000`.
- Full smoke pack: `net_worth = 43500` (Phase 0 baseline preserved), idempotent `api.post_transaction` returns same UUID on retry, balance-trigger rejects unbalanced legs, `meta.audit_log` captures 12 rows, `api_pro.mv_holdings_vw` shows 70 units @ avg-cost 53.33 with unrealised gain 1866.67, `api_pro.fifo_realised_gains` returns 80 sold units, cost basis 4000, realised gain 2000, holding 465 days = long-term, all eight feature flags FALSE on default install.
- Sqitch `deploy` + `verify` both green for `baseline_v02 @v0.2-phase2` and `phase4_stocks_paid @v0.4-phase4`.

---

## 5. Next steps

- Wire CI to run `psql -f database/initialize.sql` + the smoke pack against a throwaway `postgres:16-alpine` container on every PR.
- Cut `v1.0.0` once the Next.js dashboard catches up to the Phase 4 RPC surface.
- See `CLAUDE.md` §3 for the open feature backlog (recurring transactions E2, budgets E3, tags E6, splits E7, multi-currency E13).
