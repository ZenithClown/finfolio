CREATE VIEW public.vw_user_account_role AS
  SELECT
    a.fullname
    , a.username
    , b.role_name
    , c.subrole_name
  FROM public.user_account_detail a
  LEFT JOIN meta.user_role b ON
    a.user_role = b.role_id
  LEFT JOIN meta.user_subrole c ON
    a.user_subrole = c.subrole_id
  ORDER BY
    b.role_id
    , a.fullname
