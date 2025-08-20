CREATE FUNCTION private.set_datefields()
  RETURNS TRIGGER AS $$
  BEGIN
    NEW.trx_fiscalyear := public.fiscalyear(NEW.trx_date);
    NEW.trx_month := TO_CHAR(NEW.trx_date, 'YYYY-MM');
    RETURN NEW;
  END;
$$ LANGUAGE plpgsql;
