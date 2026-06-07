# Sqitch Migrations for finfolio

This directory documents the [Sqitch](https://sqitch.org) migration
harness wired into `database/`. Sqitch tracks schema state in a
`sqitch` schema in the target database and lets us deploy / revert /
verify changes deterministically.

## Why sqitch (vs `psql -f initialize.sql`)

`initialize.sql` is **idempotent** — that's its job, and it's enough
for a fresh-clone bootstrap. Once the schema starts evolving across
multiple deployments (and especially once real user data exists), we
need:

* **Forward-only versioning** — every change is named, ordered, and
  hashed; you can't accidentally apply v0.5 before v0.4.
* **Reverts** — every deploy ships with a tested revert script.
* **Verifies** — every deploy ships with a smoke test that fails loud
  if the change didn't take effect.
* **State tracking** — `sqitch status` answers "is prod up to date?"
  in one command.

`initialize.sql` stays as the bootstrap path for fresh dev clones; on
top of that, sqitch is the system of record for schema evolution.

## Running sqitch (Docker, no host install required)

We use the official `sqitch/sqitch:latest` image so contributors don't
need a Perl + DBD::Pg toolchain on their machines.

### One-time: spin up Postgres + a docker network

```powershell
docker network create finfolio_net 2>$null

docker run -d --name finfolio_pg `
  --network finfolio_net `
  -e POSTGRES_PASSWORD=postgres `
  -p 55432:5432 `
  postgres:16-alpine

Start-Sleep -Seconds 5
docker exec -e PGPASSWORD=postgres finfolio_pg `
  psql -U postgres -c "CREATE DATABASE finfolio;"
```

### Deploy the baseline

```powershell
docker run --rm `
  --network finfolio_net `
  -v "${PWD}:/repo" `
  -w /repo/database `
  sqitch/sqitch:latest `
  deploy db:pg://postgres:postgres@finfolio_pg:5432/finfolio
```

Note `-v "${PWD}:/repo"` mounts the repo root and `-w /repo/database`
sets sqitch's working directory to `database/` so the relative `\i
database/initialize.sql` inside `deploy/baseline_v02.sql` resolves
against the repo root.

### Status / log / revert

```powershell
docker run --rm --network finfolio_net -v "${PWD}:/repo" -w /repo/database `
  sqitch/sqitch:latest status db:pg://postgres:postgres@finfolio_pg:5432/finfolio

docker run --rm --network finfolio_net -v "${PWD}:/repo" -w /repo/database `
  sqitch/sqitch:latest revert -y db:pg://postgres:postgres@finfolio_pg:5432/finfolio
```

## Adding a new change

```powershell
docker run --rm -v "${PWD}:/repo" -w /repo/database `
  sqitch/sqitch:latest add my_change -n "Short description"
```

### House rules

1. **One feature per change.** Sqitch's smallest revert unit is a change.
2. **Always write a verify script.** `[deploy] verify=true` runs it
   automatically when present.
3. **Always write a revert script.** Even for backfills, document
   irreversibility with `RAISE EXCEPTION 'irreversible'`.
4. **Tag at every release.** `sqitch tag v0.3 -n "..."` after a phase.
5. **Pre-sqitch history is collapsed.** `baseline_v02` represents
   Phase 0 + Phase 1 + Phase 2 as a single change. From here forward,
   every change is its own row in `sqitch.plan`.
