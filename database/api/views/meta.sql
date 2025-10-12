/********************************************************************
Create & Return JSON Views for Meta Table for PostgREST API

The automatic RESTful API call from the underlying views that returns
meta table information in a JSON format for easy parse and rendering.

Copyright © [2025] Debmalya Pramanik (ZenithClown)
********************************************************************/

CREATE VIEW api.account_type_master_json AS (
  SELECT ROW_TO_JSON(t) FROM (
    SELECT * FROM meta.account_type_master
    ORDER BY account_type_id, account_subtype_id
  ) t
);


CREATE VIEW api.expense_category_master_json AS (
  SELECT ROW_TO_JSON(t) FROM (
    SELECT * FROM meta.expense_category_master
    ORDER BY expense_category_name, expense_subcategory_name
  ) t
);


CREATE VIEW api.income_category_master_json AS (
  SELECT ROW_TO_JSON(t) FROM (
    SELECT * FROM meta.income_category_master
    ORDER BY income_category_name, income_subcategory_name
  ) t
);
