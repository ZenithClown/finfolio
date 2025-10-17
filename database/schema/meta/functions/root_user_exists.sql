/********************************************************************
Check if ROOT Users Exists, Fail "On Exists" Allow Otherwise

A database can have only one super administrator (i.e., a root user,
like in *nix based system) and the function is created to raise an
exception if a new user with root role is being assigned. By database
design, a root user is the owner of the database while a sudo user is
like a family head or a manager who can oversee and check the total
expense and other details for an user.

The trigger function is enabled on ``public.user_account_detail``
with a clause on both insert and update as - (I) we do not allow to
create more than one root user, and (II) we do not accidentaly want to
assign ROOT role to a database where a super administrator already
exists - check trigger on table for more details

Copyright © [2025] Debmalya Pramanik (ZenithClown)
********************************************************************/

CREATE FUNCTION meta.root_user_exists() RETURNS TRIGGER
LANGUAGE plpgsql AS
$$
BEGIN
  IF NEW.user_role = 'ROOT' THEN
    IF EXISTS (SELECT 1 FROM public.user_account_detail WHERE user_role = 'ROOT') THEN
      RAISE EXCEPTION 'Root User Already Exists';
    END IF;
  END IF;
  RETURN NEW;
END;
$$;
