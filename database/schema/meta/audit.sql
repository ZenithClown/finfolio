/********************************************************************
Phase 3 §4.7 — Audit Log

-- ..versionadded:: 2026-06-07 [Phase 3] generic row-change audit log
shared by all sensitive tables. One row per (table, pk, op) capturing
the before/after image as JSONB so we never lose history even when
soft-delete fires.

Design notes:
  * Generic, schema-agnostic trigger: `private.audit_row_change()`
    pulls TG_TABLE_SCHEMA / TG_TABLE_NAME / row_to_json(OLD|NEW).
  * Actor is sourced from the PostgREST JWT claim
    `request.jwt.claim.username` (set per-request by PostgREST). For
    direct DB connections we fall back to `current_user`.
  * `audit_log.log_id` is BIGINT IDENTITY; no natural key.
  * We do NOT log SELECTs (too noisy) — only mutating ops.
********************************************************************/

CREATE TABLE IF NOT EXISTS meta.audit_log (
  log_id
    BIGINT GENERATED ALWAYS AS IDENTITY
    CONSTRAINT pk_audit_log PRIMARY KEY,

  logged_at
    TIMESTAMPTZ NOT NULL DEFAULT clock_timestamp(),

  actor_username
    VARCHAR(64) NOT NULL,

  schema_name
    NAME NOT NULL,
  table_name
    NAME NOT NULL,
  op
    CHAR(1) NOT NULL,   -- I / U / D

  -- The PK value as text (composite PKs serialised). For UUID PKs this
  -- is the canonical 36-char form; for SERIAL it's the decimal int.
  pk_value
    TEXT,

  before_row
    JSONB,
  after_row
    JSONB,

  CONSTRAINT ck_audit_op CHECK (op IN ('I', 'U', 'D'))
);

CREATE INDEX IF NOT EXISTS ix_audit_log_table       ON meta.audit_log (schema_name, table_name, logged_at DESC);
CREATE INDEX IF NOT EXISTS ix_audit_log_actor       ON meta.audit_log (actor_username, logged_at DESC);
CREATE INDEX IF NOT EXISTS ix_audit_log_pk_value    ON meta.audit_log (schema_name, table_name, pk_value);

CREATE OR REPLACE FUNCTION private.audit_row_change()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = pg_catalog, public
AS $$
DECLARE
  v_actor    VARCHAR(64);
  v_pk_cols  TEXT[];
  v_pk_value TEXT;
  v_op       CHAR(1);
BEGIN
  -- PostgREST sets request.jwt.claim.username per request via SET LOCAL.
  -- Direct DB sessions fall back to current_user.
  BEGIN
    v_actor := current_setting('request.jwt.claim.username', true);
  EXCEPTION WHEN OTHERS THEN
    v_actor := NULL;
  END;
  IF v_actor IS NULL OR v_actor = '' THEN
    v_actor := SESSION_USER;
  END IF;

  v_op := CASE TG_OP WHEN 'INSERT' THEN 'I' WHEN 'UPDATE' THEN 'U' WHEN 'DELETE' THEN 'D' END;

  -- Best-effort PK extraction: comma-join the PK columns of the new (or old) row.
  SELECT array_agg(a.attname ORDER BY array_position(c.conkey, a.attnum))
    INTO v_pk_cols
    FROM pg_constraint c
    JOIN pg_attribute a
      ON a.attrelid = c.conrelid AND a.attnum = ANY(c.conkey)
   WHERE c.contype = 'p' AND c.conrelid = TG_RELID;

  IF v_pk_cols IS NOT NULL THEN
    IF TG_OP = 'DELETE' THEN
      EXECUTE format('SELECT (%s)::text FROM (SELECT $1.*) s',
                     array_to_string(v_pk_cols, ' || '',''  || '))
              INTO v_pk_value USING OLD;
    ELSE
      EXECUTE format('SELECT (%s)::text FROM (SELECT $1.*) s',
                     array_to_string(v_pk_cols, ' || '',''  || '))
              INTO v_pk_value USING NEW;
    END IF;
  END IF;

  INSERT INTO meta.audit_log (
    actor_username, schema_name, table_name, op, pk_value, before_row, after_row
  ) VALUES (
    v_actor,
    TG_TABLE_SCHEMA,
    TG_TABLE_NAME,
    v_op,
    v_pk_value,
    CASE WHEN TG_OP IN ('UPDATE','DELETE') THEN to_jsonb(OLD) END,
    CASE WHEN TG_OP IN ('INSERT','UPDATE') THEN to_jsonb(NEW) END
  );

  RETURN COALESCE(NEW, OLD);
END
$$;

-- Bind audit triggers to the new double-entry tables and to the
-- ledger_account_detail (where soft-delete also lives). Each is
-- idempotent via DROP+CREATE.
DROP TRIGGER IF EXISTS trg_audit_transaction_header ON private.transaction_header;
CREATE TRIGGER trg_audit_transaction_header
  AFTER INSERT OR UPDATE OR DELETE ON private.transaction_header
  FOR EACH ROW EXECUTE FUNCTION private.audit_row_change();

DROP TRIGGER IF EXISTS trg_audit_transaction_line ON private.transaction_line;
CREATE TRIGGER trg_audit_transaction_line
  AFTER INSERT OR UPDATE OR DELETE ON private.transaction_line
  FOR EACH ROW EXECUTE FUNCTION private.audit_row_change();

DROP TRIGGER IF EXISTS trg_audit_ledger_account_detail ON public.ledger_account_detail;
CREATE TRIGGER trg_audit_ledger_account_detail
  AFTER INSERT OR UPDATE OR DELETE ON public.ledger_account_detail
  FOR EACH ROW EXECUTE FUNCTION private.audit_row_change();
