/********************************************************************
A Function to Calculate Fiscal Year from a Date

The function takes a date or a date time as an input and returns the
fiscal year for that date. The function provides flexibility to handle
the start of the fiscal year, as this may vary from country to country.

Copyright © [2025] Debmalya Pramanik (ZenithClown)
********************************************************************/

CREATE OR REPLACE FUNCTION public.fiscalyear(
  p_date TIMESTAMPTZ
  , p_start_month INT DEFAULT 4
  , p_char_prefix VARCHAR(16) DEFAULT 'F.Y. '
  , p_retvalue_sep VARCHAR(4) DEFAULT '-'
) RETURNS VARCHAR(48)
LANGUAGE plpgsql AS
$$

DECLARE
  fy_st_year   INT;
  fy_ed_year   INT;
  p_input_date DATE;

BEGIN
  p_input_date := p_date::DATE;

  IF EXTRACT(MONTH FROM p_input_date) >= p_start_month THEN
    fy_st_year := EXTRACT(YEAR FROM p_input_date);
  ELSE
    fy_st_year := EXTRACT(YEAR FROM p_input_date) - 1;
  END IF;

  fy_ed_year := fy_st_year + 1;

  RETURN p_char_prefix || fy_st_year || p_retvalue_sep || fy_ed_year;
END;
$$
