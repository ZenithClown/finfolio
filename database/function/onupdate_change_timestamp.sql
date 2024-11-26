/********************************************************************
Change Time Stamp of Rows on Update using Trigger & Function

MySQL offers in-built syntax to create and use a trigger to set value
to a column on update, however the same has to be manually developed
in PostgreSQL using the sime function and triggers.

Copywright © [2024] Debmalya Pramanik
********************************************************************/

CREATE FUNCTION onupdate_change_timestamp()
RETURNS TRIGGER AS $$
BEGIN
  NEW.UTCTimeStamp = timezone('utc', now());
  RETURN NEW;
END;
$$ language 'plpgsql';
