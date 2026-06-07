/********************************************************************
Initialization Statement for API Schema Namespace for Project FINFOLIO

The API schema namespace exposes all the RESTful API endoints using
the PostgREST library and thus reduces external module support (like
`prisma` for nodejs or `flask` for python based application) to
develop and maintain ORM for the tables - keeping the code base simple
and easy to manage; given the simple use case.

The API schema will not hold any table by default and all the SQL
based objects (functions, views, etc.) are publically exposed in the
API and the Swagger UI is available at `/swagger` endpoint.

Copywright © [2024] Debmalya Pramanik (ZenithClown)
********************************************************************/

\i database/api/views/meta.sql

-- ..versionadded:: 2026-06-07 [B27] include the RPC layer. Without
-- these, PostgREST would expose only the three master views and none
-- of the documented endpoints would resolve over HTTP.
-- ..versionchanged:: 2026-06-07 [Phase 3] drop old net_worth signatures
-- before the new file recreates them. The return-table types changed
-- from NUMERIC(12, 2) to NUMERIC(18, 2) which Postgres treats as a
-- breaking signature change; CREATE OR REPLACE cannot rewrite it.
DROP FUNCTION IF EXISTS api.net_worth(CHAR(5)[]);
DROP FUNCTION IF EXISTS api.net_value_by_account(CHAR(5)[]);
DROP FUNCTION IF EXISTS api.net_value_by_account_type(VARCHAR(16), VARCHAR(16));

\i database/api/functions/net_worth.sql

-- ..versionadded:: 2026-06-07 [Phase 3 §4.1] UX-friendly write RPC.
\i database/api/functions/post_transaction.sql

-- NOTE: Phase 4 RPCs that depend on the `stocks` schema (fifo_realised_gains,
-- mv_holdings_vw) are intentionally NOT included here. They are wired into
-- database/initialize.sql AFTER stocks/initialize.sql.

\i database/api/security/accounts.sql
\i database/api/security/login.sql

-- ..versionadded:: 2026-06-07 [docs] surface descriptions via OpenAPI.
\i database/api/comments.sql
