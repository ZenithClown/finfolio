-- Deploy finfolio:baseline_v02 to pg
--
-- Wraps the existing idempotent initialize.sql as a single sqitch
-- baseline change. Future schema work should ship as smaller,
-- focused sqitch changes (one feature per change), but pre-sqitch
-- history is collapsed here because it has already been verified
-- to be idempotent and reversible by hand (see CLAUDE.md §5/§6).

BEGIN;

-- initialize.sql lives in this same directory (database/) and uses
-- its own \i directives with `database/...` prefixes. Sqitch invokes
-- psql with CWD = sqitch's top_dir (i.e. database/), so we cd up one
-- level to the repo root before \i so initialize.sql's nested
-- `\i database/...` paths still resolve.
\cd ..
\i database/initialize.sql

COMMIT;
