# Security Model — finfolio

A condensed reference of every line of defence between an unauthenticated
HTTP request and the rows in `private.*`.

---

## 1. Trust boundary

finfolio is a *self-hosted* personal-finance application. The trust
boundary is the PostgREST front door — every request below is treated
as untrusted until JWT verification succeeds. The database is the
single source of truth for both data and authorisation; there is no
application-layer authorisation that the database itself cannot
re-derive.

This matters because operators routinely run finfolio with PostgREST
on `0.0.0.0` for LAN access (for the dashboard on a phone). The threat
model assumes *anyone* on the LAN can hit the API, and that the only
thing keeping their hands off your money is the row-level policies +
JWT signature check documented below.

---

## 2. The three roles

| Role        | Login? | Granted to                       | Used by                                   |
| ----------- | ------ | -------------------------------- | ----------------------------------------- |
| `web_anon`  | NO     | nothing except `api.login`       | Pre-authentication PostgREST requests     |
| `web_user`  | NO     | RPCs + masters (read-only views) | Authenticated users post-login            |
| `web_pro`   | NO     | `web_user` ⊕ `api_pro.*`         | Paid-tier subscribers post feature-flag   |

PostgREST runs as a *single* authenticator user (configured via
`postgrest.conf`'s `db-uri`) that has no privileges of its own but can
`SET ROLE` to one of the three based on the verified JWT `role`
claim. No application code holds long-lived superuser credentials.

---

## 3. JWT lifecycle

1. Client `POST /rpc/login` with `{ "p_username": ..., "p_password": ... }`.
2. `api.login` (SECURITY DEFINER) bcrypt-compares the supplied password
   against `public.user_account_detail.password` (which stores
   `crypt(plain, gen_salt('bf', 12))`).
3. On success it calls `base.jwt_sign(...)` to mint a JWT signed with
   HS256 using the shared secret from `meta.config`.
4. The client returns that JWT in every subsequent
   `Authorization: Bearer ...` header. PostgREST verifies the signature,
   reads the `role` claim, and switches into that database role for the
   request.

> **Direct quote — `database/security/jwt.sql`:** the secret lives in
> `meta.config` so a deployment can rotate it without redeploying the
> binary; rotate by updating the row and forcing every active user to
> re-authenticate.

---

## 4. Row-level security (`database/security/rls.sql`)

RLS is enabled on every table that holds per-user data:

* `public.ledger_account_detail`
* `public.user_account_detail`
* `private.user_transaction` (legacy)
* `private.transaction_header` + `private.transaction_line` (Phase 3)
* `private.attachment` (Phase 4)

The canonical policy uses `base.get_managed_users(current_setting('request.jwt.claim.username'))`
which returns the set of usernames the calling user is allowed to see
(themselves + any "managed" users they own). Reads, writes, and deletes
all flow through this single helper so there is exactly one place to
audit access decisions.

The `private.*` tables ship with **no** GRANTs to `web_user`. Reads
happen only via the `api.*` RPCs (`SECURITY DEFINER`, owned by the DB
owner, marked `STABLE`/`VOLATILE` as appropriate). This keeps the
RLS surface narrow — RPCs are the only path that ever reads a private
row, and each RPC re-checks ownership via `base.get_managed_users`.

---

## 5. Audit log (`meta.audit_log`, Phase 3 §4.7)

Every `INSERT`/`UPDATE`/`DELETE` on the protected tables fires the
generic `private.audit_row_change()` `SECURITY DEFINER` trigger, which
writes one row to `meta.audit_log` containing:

* Table name + primary-key value (extracted dynamically from
  `TG_ARGV` so the trigger is reusable).
* Operation (`INSERT`/`UPDATE`/`DELETE`).
* Actor — pulled from `current_setting('request.jwt.claim.username', true)`
  so PostgREST requests carry the username verbatim and direct psql
  edits fall back to `session_user`.
* Full before/after `JSONB` snapshots.
* Timestamp + transaction xid.

> **Retention.** `meta.audit_log` is monotonic. §8.2 of CLAUDE.md
> documents the planned monthly partitioning + 7-fiscal-year retention
> drop once row counts make it worthwhile.

Currently audited tables:

* `private.transaction_header`
* `private.transaction_line`
* `public.ledger_account_detail`

Phase 4.5 will extend the trigger to `private.attachment` and the
soft-delete operations themselves (so an undelete is auditable).

---

## 6. Soft-delete (`deleted_on` / `deleted_by`)

Tables that carry money or money-adjacent metadata use a paired
`deleted_on TIMESTAMPTZ` + `deleted_by VARCHAR(16)` column with a
`CHECK` that either both are NULL or both are set. Read RPCs all
filter `WHERE deleted_on IS NULL`. The row stays on disk so audit
replay and accidental-delete recovery both work without restoring
from backup.

Currently soft-deletable:

* `private.transaction_header` (Phase 3)
* `public.ledger_account_detail` (Phase 3)
* `private.attachment` (Phase 4)

---

## 7. Idempotency

`private.transaction_header.idempotency_key VARCHAR(64) UNIQUE`
collapses retried writes from the dashboard to a single row.
`api.post_transaction` short-circuits and returns the existing UUID
when the same key is replayed, so an offline client can safely retry
without double-posting a transaction.

---

## 8. Paid-tier gating (`meta.feature_flag`, Phase 4)

Every paid-tier `api_pro.*` RPC begins with:

```sql
IF NOT meta.is_feature_enabled('<flag>') THEN
    RAISE EXCEPTION USING ERRCODE = '42501',
        MESSAGE = 'feature <flag> is not enabled on this tenant';
END IF;
```

The flag check is `STABLE`, so the planner caches it per statement. A
flag flip takes effect immediately (no PostgREST schema reload
required) but does *not* retroactively grant access to data computed
under a different flag state — every RPC re-checks on every call.

---

## 9. What's still out of scope

* No 2FA. The login flow is bcrypt + JWT only. A future Phase 5+
  may add TOTP via `pgcrypto`.
* No rate limiting at the database tier. Rely on a reverse proxy
  (nginx, Caddy, Cloudflare) in front of PostgREST.
* No at-rest column encryption. Use Postgres-level TDE
  (`pgcrypto` columnar or a filesystem layer) for sensitive
  deployments.

---

## 10. Pen-test crib sheet

If you are reviewing finfolio for security, the highest-leverage files
are:

1. `database/security/jwt.sql` — JWT signing key handling.
2. `database/security/rls.sql` — the RLS policies. Verify every
   private table has at least `enable_row_level_security` set.
3. `database/base/get_managed_users.sql` — the access-control oracle.
4. `database/api/security/login.sql` — bcrypt comparison + JWT mint.
5. `database/security/grants.sql` — the explicit grant catalog.
   Anything missing here is implicitly DENIED.
6. `database/schema/meta/audit.sql` — actor extraction.
