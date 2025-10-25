/********************************************************************
Create & Return Metadata Table Views for API Schema

The metadata tables can be directly returned as a view to the RESTful
API endpoints for the client-side application. The view definitions
are based on the SQL based metadata tables, which are defined in this
section. All the tables can be publically exposed in the API.

-- ..versionchanged:: 2025-10-25 Use native view than JSON return
During development, we'd used PostgreSQL Native JSON functions to
render and return data, however this is not required as the PostgREST
does the same thing under the hood.

-- ..versionchanged:: 2025-10-25 All the previous views are removed
All the previous *_json views are removed, and now using *_vw as
suffix to identify the table views.

Copyright © [2025] Debmalya Pramanik (ZenithClown)
********************************************************************/

CREATE VIEW api.account_type_master_vw AS (
  SELECT * FROM meta.account_type_master
  ORDER BY account_type_id, account_subtype_id
);


CREATE VIEW api.expense_category_master_vw AS (
  SELECT * FROM meta.expense_category_master
  ORDER BY expense_category_name, expense_subcategory_name
);


CREATE VIEW api.income_category_master_vw AS (
  SELECT * FROM meta.income_category_master
  ORDER BY income_category_name, income_subcategory_name
);
