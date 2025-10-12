CREATE OR REPLACE FUNCTION api.login(
  p_login_by VARCHAR(256)
  , p_password TEXT
)
RETURNS JSON AS $$
BEGIN
  RETURN (
    SELECT ROW_TO_JSON(t) FROM
    (
      SELECT
        username
        , fullname
        , email
        , phone
        , date_of_birth
        , user_role
      FROM public.user_account_detail
      WHERE
        (email = p_login_by OR username = p_login_by)
        AND password = CRYPT(p_password, password)
    ) t
  );
END
$$ LANGUAGE plpgsql;
