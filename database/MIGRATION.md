# Migration Guide — finfolio

This guide explains how to bring a finfolio database up to a target
version, and how to migrate an existing install across the refactor
breakpoints introduced during Phases 0 – 4.

> **Audience.** Self-hosting users running PostgreSQL 14+ with a
> PostgREST front door, plus operators packaging finfolio for paid-tier
> distribution.

---

## 1. Two ways to provision the schema

finfolio ships with two equivalent provisioning paths. Both produce a
byte-identical schema; pick the one that matches your operational
style.

### 1.1 One-shot psql

```bash
createdb finfolio
psql -U postgres -d finfolio -v ON_ERROR_STOP=1 -f database/initialize.sql
```

`database/initialize.sql` is **idempotent end-to-end** — every
`CREATE TABLE` is wrapped in `IF NOT EXISTS`, every `ALTER` is
guarded by a `DO $$` precondition check, and every seed insert is
`ON CONFLICT DO NOTHING`. Running it twice on the same database is a
no-op.

### 1.2 Sqitch (recommended for upgrades)

```bash
cd database
sqitch deploy db:pg://postgres:postgres@localhost:5432/finfolio
sqitch verify db:pg://postgres:postgres@localhost:5432/finfolio
sqitch status db:pg://postgres:postgres@localhost:5432/finfolio
```

A Docker-only path (no host Perl install) is documented in
`database/sqitch/README.md`.

The `sqitch.plan` currently contains:

| Change                 | Tag             | Brings the DB to                              |
| ---------------------- | --------------- | --------------------------------------------- |
| `baseline_v02`         | `@v0.2-phase2`  | End-of-Phase-2 baseline (security, CHECK, FK indexes, stocks fixes) |
| `phase4_stocks_paid`   | `@v0.4-phase4`  | End-of-Phase-4 schema (stocks v2, api_pro, feature_flag, attachments, FIFO, mv_holdings_vw) |

Phase 3 (double-entry) is *not* a separate sqitch change because it
landed inside the same `baseline_v02` deploy script — `\i
database/initialize.sql` pulls it in transitively.

---

## 2. Migrating an existing install

### 2.1 From an `0.0.1-dev` / pre-refactor database

You have a database that was provisioned before the `refactor/database`
work and still has the old single-row-per-event
`private.user_transaction` table populated.

1. **Back up.** `pg_dump -Fc finfolio > finfolio.pre-refactor.dump`.
2. **Run the new initializer.** `psql -f database/initialize.sql`.
   * The new schema objects (`transaction_header`, `transaction_line`,
     `meta.audit_log`, the SYS contras, every Phase 4 table, etc.) are
     created.
   * `database/schema/private/transaction_backfill.sql` walks every
     row in `private.user_transaction` and writes a balanced
     `transaction_header` + 2-line pair using a *deterministic UUID*
     derived from the legacy `transaction_idkey`. This makes the
     backfill safe to re-run.
3. **Verify the net-worth invariant.** Compute net worth in the legacy
   model (sum of signed `trx_amount` for each account) and in the new
   model (`api.net_worth(ARRAY[]::CHAR(5)[])`). They must match to the
   rupee.
4. **Stop writing to `private.user_transaction`.** All new writes go
   through `api.post_transaction(...)`. The legacy table stays on disk
   for historical reads and is slated for `DROP` in Phase 5+.

### 2.2 From an end-of-Phase-2 database (`@v0.2-phase2`)

```bash
cd database
sqitch deploy db:pg://… --to @v0.4-phase4
```

Or apply the changes manually with `psql -f` against
`database/deploy/phase4_stocks_paid.sql`.

### 2.3 Forward-only

finfolio currently treats schema migrations as forward-only. A
`sqitch revert` is provided per change for *development* convenience
(re-running the deploy after a tweak), but is **not a production
recovery path**. Restore from `pg_dump` if a deployed change must be
undone.

---

## 3. Breaking changes by version

### `@v0.4-phase4`

* `stocks.user_transaction.trade_quantity` is now `NUMERIC(18, 6)`
  (was `NUMERIC(12, 2)` in pre-B23 installs). The ALTER is guarded:
  it skips on databases where the column is already wide enough,
  which is required because `api.mv_holdings_vw` (also new in Phase
  4) references the column and would otherwise block the ALTER on
  second init.
* `api.net_worth*` now return `NUMERIC(18, 2)` (was `(12, 2)`). The
  initializer drops the old signatures before recreating them — any
  external code that introspects the function signature must be
  refreshed.

### `@v0.2-phase2`

* `account_type_key` widened to `VARCHAR(16)` (was `VARCHAR(7)`) to
  accommodate sub-types longer than `XXX/XXX`. Adjust any external
  consumer that hard-coded the narrow width.
* IPO master PK changed from `(isin_code)` to
  `(isin_code, po_type, opening_date)` so a single ISIN may carry
  both an IPO and one or more later FPOs.

---

## 4. Verifying a successful migration

Run all of these against the target database; each must succeed:

```sql
-- Phase 2 invariants
SELECT 1 FROM information_schema.check_constraints WHERE constraint_name = 'ck_amount_positive';
SELECT 1 FROM pg_indexes WHERE indexname = 'ix_user_managed_by';

-- Phase 3 invariants
SELECT count(*) > 0 FROM private.transaction_header;
SELECT count(*) > 0 FROM meta.audit_log;
SELECT * FROM api.net_worth(ARRAY[]::CHAR(5)[]);

-- Phase 4 invariants
SELECT count(*) FROM meta.feature_flag;            -- should be >= 8
SELECT 'api_pro' IN (SELECT nspname FROM pg_namespace);
SELECT count(*) FROM api.mv_holdings_vw;           -- 0 until trades exist
SELECT api.fifo_realised_gains('AAA01'::CHAR(5), NULL);
```

The dedicated sqitch verify scripts (`database/verify/*.sql`)
encapsulate the same checks and exit non-zero on failure.

---

## 5. Operational gotchas

* **`api.mv_holdings_vw` is not auto-refreshed.** Trigger a refresh
  after stock trades or NAV ingests with
  `REFRESH MATERIALIZED VIEW CONCURRENTLY api.mv_holdings_vw;`.
* **Paid-tier flags ship disabled.** Every row in `meta.feature_flag`
  has `is_enabled = FALSE` on a fresh install. Toggle the relevant
  rows from your installer to switch on paid functionality.
* **PostgREST role triad.** `web_anon` (anonymous), `web_user`
  (logged-in), and `web_pro` (paid) must all exist before the first
  PostgREST request hits the database. `database/security/roles.sql`
  creates the first two; `database/schema/api_pro/initialize.sql`
  creates `web_pro`.
