INSERT INTO public.points_account_detail (
  points_account_id
  , points_account_name
  , points_account_owner
  , ledger_account_id
  , account_type_id
  , account_subtype_id
  , conversion_factor
) VALUES
  (LEFT(UPPER(GEN_RANDOM_UUID()::VARCHAR(36)), 5), ?, ?, ?, ?, ?, ?);
