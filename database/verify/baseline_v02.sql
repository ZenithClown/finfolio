-- Verify finfolio:baseline_v02 on pg
--
-- Sanity-check that the post-Phase-2 baseline is in place. We don't
-- exhaustively assert every object (that's what initialize.sql's own
-- twice-run idempotency proves); we only assert the load-bearing
-- entry points that downstream changes will depend on.

DO $$
DECLARE
  missing TEXT;
BEGIN
  FOR missing IN
    SELECT s FROM unnest(ARRAY['meta','public','private','api','base','stocks']) s
    WHERE NOT EXISTS (SELECT 1 FROM pg_namespace WHERE nspname = s)
  LOOP
    RAISE EXCEPTION 'baseline_v02 verify: schema "%" missing', missing;
  END LOOP;

  IF NOT EXISTS (SELECT 1 FROM pg_tables WHERE schemaname='meta'    AND tablename='account_type_master') THEN
    RAISE EXCEPTION 'baseline_v02 verify: meta.account_type_master missing';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_tables WHERE schemaname='public'  AND tablename='ledger_account_detail') THEN
    RAISE EXCEPTION 'baseline_v02 verify: public.ledger_account_detail missing';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_tables WHERE schemaname='private' AND tablename='user_transaction') THEN
    RAISE EXCEPTION 'baseline_v02 verify: private.user_transaction missing';
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace
                 WHERE n.nspname='api' AND p.proname='login') THEN
    RAISE EXCEPTION 'baseline_v02 verify: api.login() missing';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_proc p JOIN pg_namespace n ON n.oid=p.pronamespace
                 WHERE n.nspname='api' AND p.proname='net_worth') THEN
    RAISE EXCEPTION 'baseline_v02 verify: api.net_worth() missing';
  END IF;

  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE column_name='account_type_key' AND character_maximum_length <> 16
  ) THEN
    RAISE EXCEPTION 'baseline_v02 verify: an account_type_key column is not VARCHAR(16) [B13 missing]';
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname LIKE 'ck_%') THEN
    RAISE EXCEPTION 'baseline_v02 verify: no ck_%% CHECK constraints found [B18 missing]';
  END IF;

  RAISE NOTICE 'baseline_v02 verify: all checks passed';
END $$;
