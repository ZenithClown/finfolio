/********************************************************************
A PostgreSQL Query to Details of Managed User by the Session User

During a run session, for a given username the function returns the
list of usernames and their full names that are directly managed by
the session user or returns all the username if ROOT user ordered by
the full name of the users.

Copyright © [2025] Debmalya Pramanik (ZenithClown)
********************************************************************/

CREATE OR REPLACE FUNCTION base.get_managed_users (
  p_username VARCHAR(16)
)
RETURNS TABLE (
  managed_username VARCHAR(16)
  , managed_fullname VARCHAR(128)
) AS $$
BEGIN RETURN QUERY
  WITH user_role_cte AS (
    SELECT user_role FROM public.user_account_detail
    WHERE username = p_username
  )

  SELECT DISTINCT
    username AS managed_username
    , fullname AS managed_fullname
  FROM public.user_account_detail
  WHERE
    (SELECT user_role FROM user_role_cte) = 'ROOT'
    OR username = p_username
    OR managed_by = p_username
  ORDER BY fullname;
END
$$ LANGUAGE plpgsql;
