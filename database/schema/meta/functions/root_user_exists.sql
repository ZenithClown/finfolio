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
