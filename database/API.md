# API Reference — finfolio

PostgREST exposes the `api` schema as a RESTful surface; this document
catalogues every endpoint that the database itself defines. The live
OpenAPI document is always available at `/` once PostgREST is running:
this file is the *narrative* companion.

> **Authentication.** All `api.*` RPCs except `api.login` require the
> JWT minted by `api.login` in an `Authorization: Bearer <jwt>` header.
> All `api_pro.*` RPCs additionally require the corresponding
> `meta.feature_flag` to be enabled. See `database/SECURITY.md`.

> **Conventions.** Money values are returned as `NUMERIC(18, 2)`.
> Dates use ISO-8601 (`YYYY-MM-DD`). UUIDs are RFC-4122 lower-case.
> Where an endpoint accepts an array of account ids, an empty array
> `[]` means "every account the calling user can see".

---

## Free tier (`api.*`)

### `POST /rpc/login`

Authenticate and obtain a JWT.

| Param        | Type      | Notes                              |
| ------------ | --------- | ---------------------------------- |
| `p_username` | `VARCHAR` | required                           |
| `p_password` | `VARCHAR` | required, bcrypt-verified server-side |

**Returns** `{ "token": "<jwt>" }`.

Sets the calling role to either `web_user` (regular login) or
`web_pro` (login by a user whose row has a paid-tier flag — paid-tier
membership lives in the user record, not the JWT).

---

### `POST /rpc/net_worth`

Net worth across one or more accounts.

| Param      | Type        | Notes                                    |
| ---------- | ----------- | ---------------------------------------- |
| (positional)| `CHAR(5)[]`| `[]` = every account; subset filters     |

**Returns** `{ "net_value": NUMERIC(18, 2), "last_updated": DATE }`.

Sums signed amounts from `private.transaction_line`, derives the sign
from the account's natural side (`DBT` = debit-normal, `CDT` =
credit-normal) × the line's `side`, filters out `is_system` contras
(`SYSIN`/`SYSEX`) and soft-deleted rows.

---

### `POST /rpc/net_value_by_account`

Same shape as `net_worth` but returns one row per account.

| Param | Type        | Notes                                 |
| ----- | ----------- | ------------------------------------- |
| (positional) | `CHAR(5)[]` | empty = every account            |

**Returns** rows of `(account_id CHAR(5), net_value NUMERIC(18,2), last_updated DATE)`.

---

### `POST /rpc/net_value_by_account_type`

Aggregate net value by `account_type` × `account_subtype` (e.g. all
savings accounts, all credit cards).

| Param        | Type           | Notes                          |
| ------------ | -------------- | ------------------------------ |
| `p_type`     | `VARCHAR`      | optional filter                |
| `p_subtype`  | `VARCHAR(16)`  | optional filter                |

**Returns** `(account_type, account_subtype, net_value, accounts)`.

---

### `POST /rpc/get_ledger_account_json`

Catalog of ledger accounts the calling user can see.

| Param       | Type           | Notes                           |
| ----------- | -------------- | ------------------------------- |
| `p_type`    | `VARCHAR`      | optional filter                 |
| `p_subtype` | `VARCHAR(16)`  | optional filter                 |

**Returns** an array of `{ account_id, account_name, account_type, ... }`.

---

### `POST /rpc/get_account_count_json`

Counts of accounts grouped by type/subtype — for dashboard tiles.

| Param       | Type           | Notes                           |
| ----------- | -------------- | ------------------------------- |
| `p_type`    | `VARCHAR`      | optional filter                 |
| `p_subtype` | `VARCHAR(16)`  | optional filter                 |

**Returns** `{ "DBT/SVN": 3, "CDT/CC": 1, ... }`.

---

### `POST /rpc/post_transaction`  *(Phase 3 §4.1)*

UX-friendly write endpoint. Synthesises a balanced
`transaction_header` + 2 `transaction_line`s in one call.

| Param                | Type                   | Notes                                              |
| -------------------- | ---------------------- | -------------------------------------------------- |
| `p_account_id`       | `CHAR(5)`              | the user's account                                 |
| `p_amount`           | `NUMERIC`              | always positive; sign derives from `p_trx_type`    |
| `p_trx_type`         | `meta.transaction_type`| `DEPOSIT` / `WITHDRAW` / `TRANSFER`                |
| `p_trx_date`         | `DATE`                 | business date                                      |
| `p_trx_desc`         | `VARCHAR`              | free text                                          |
| `p_method`           | `meta.transaction_method` | optional                                        |
| `p_income_category`  | `VARCHAR`              | optional, mutually exclusive with `p_expense_category` |
| `p_expense_category` | `VARCHAR`              | optional                                           |
| `p_self_account_id`  | `CHAR(5)`              | only for `TRANSFER`; the other leg's account       |
| `p_idempotency_key`  | `VARCHAR(64)`          | optional; same key returns same UUID               |

**Returns** the `UUID` of the created (or pre-existing) header.

Errors with `42501` if the user doesn't own the account; with
`check_violation` if the resulting lines fail to balance.

---

## Paid tier (`api_pro.*`)

All paid endpoints require the corresponding `meta.feature_flag` row
to have `is_enabled = TRUE`. PostgREST only exposes them when the
operator adds `api_pro` to `db-schemas` in `postgrest.conf`.

### `POST /rpc/fifo_realised_gains`  *(Phase 4)*

Per-trade realised P&L using FIFO cost-basis matching.

> Currently lives in `api.*` (not gated) because it ships as part of
> the free tier; the paid-tier wrapper is planned for Phase 4.5.

| Param          | Type        | Notes                              |
| -------------- | ----------- | ---------------------------------- |
| `p_account_id` | `CHAR(5)`   | required                           |
| `p_isin_code`  | `CHAR(12)`  | optional; NULL = every instrument  |

**Returns** rows of `(sell_date, isin_code, exchange_name, quantity_sold, sell_value, cost_basis, realised_gain, holding_days, is_long_term)`.

---

### `GET /mv_holdings_vw`  *(Phase 4)*

Current portfolio per `(account, isin, exchange)`. Materialised view —
refresh with `REFRESH MATERIALIZED VIEW CONCURRENTLY api.mv_holdings_vw;`
after stock trades or NAV ingests.

Columns: `account_id, isin_code, exchange_name, asset_name, asset_class,
quantity, avg_cost, last_nav, last_nav_date, market_value,
unrealised_gain`.

`market_value` and `unrealised_gain` are `NULL` (never `0`) when no
NAV is available for the instrument — so a zero is always a real
zero, never a stale-data artefact.

---

## Discovery endpoints (PostgREST built-ins)

| Path              | Role        | Purpose                                        |
| ----------------- | ----------- | ---------------------------------------------- |
| `GET /`           | `web_anon`  | OpenAPI document (the canonical reference)     |
| `GET /<table>`    | `web_user`  | Read a table (RLS-filtered) — only the lookup views are granted today |
| `POST /rpc/<fn>`  | per-grant   | Invoke an RPC                                  |

---

## Error catalogue

| SQLSTATE | Meaning in finfolio                                |
| -------- | -------------------------------------------------- |
| `42501`  | Permission denied — typically a feature flag is off or the caller doesn't own the account |
| `23514`  | Check-constraint violation — e.g. transaction lines don't balance |
| `23505`  | Unique violation — e.g. duplicate `idempotency_key` on a different payload |
| `42P01`  | Undefined table — usually means the migration hasn't been applied |

---

## Stability guarantees

* **`@v0.4-phase4`** is the first surface stamped as semver-stable.
  Function signatures and column types in `api.*` will only change
  in a future major (`@v1.x`).
* `api_pro.*` follows the same rules but with the caveat that the
  paid-tier surface may grow faster than the free tier.
* `private.*` and `meta.*` are *not* part of the public contract.
  They may be reshaped freely between phases — talk to them through
  `api.*` only.
