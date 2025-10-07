CREATE OR REPLACE VIEW api.account_types AS
  SELECT
    act.account_type_id
    , act.account_type_name
    , act.account_type_desc
    , acst.account_subtype_id
    , acst.account_subtype_name
    , acst.account_subtype_desc
  FROM meta.account_type_detail act
  LEFT JOIN meta.account_subtype_detail acst ON
    act.account_type_id = acst.account_type_id
  ORDER BY
    act.account_type_name
    , acst.account_subtype_name;
