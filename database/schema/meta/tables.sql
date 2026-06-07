/********************************************************************
META Table Schema Structure and Table Create Statement Defination

The metadata table namespace holds special configurations (which in
this case is mostly the master tables) for finance management. The
tables are designed to be simple and uses composite foreign key to
map any transaction tables with one single source of truth.

Copywright © [2024] Debmalya Pramanik
********************************************************************/

CREATE TABLE IF NOT EXISTS meta.account_type_master (
  -- ..versionchanged:: 2026-06-07 [B13] widen account_type_key from
  -- VARCHAR(7) to VARCHAR(16). The natural-key encoding is
  -- "TYPE/SUBTYPE" where SUBTYPE is up to 4 chars today (RDS, SAV, ...)
  -- but new categories (e.g. brokerage-style "BRK/EQTY", crypto
  -- "CRY/STBL") would silently overflow 7. 16 leaves headroom without
  -- changing the conceptual key. Composite uniqueness on
  -- (type_id, subtype_id) still encoded as the natural PK below.
  account_type_key
    VARCHAR(16)
    CONSTRAINT pk_account_type_key PRIMARY KEY,

  account_type_id
    CHAR(3) NOT NULL,

  account_type_name
    VARCHAR(32) NOT NULL,

  account_type_desc
    VARCHAR(128) NOT NULL,

  account_subtype_id
    CHAR(3),

  account_subtype_name
    VARCHAR(34),

  account_subtype_desc
    VARCHAR(64),

  CONSTRAINT uq_account_type UNIQUE (
    account_type_id
    , account_subtype_id
  ),

  CONSTRAINT uq_account_type_name UNIQUE(
    account_type_name
    , account_subtype_name
  ),

  CONSTRAINT uq_account_type_desc UNIQUE(
    account_type_desc
    , account_subtype_desc
  )
);


CREATE TABLE IF NOT EXISTS meta.expense_category_master (
  expense_category_key
    VARCHAR(65)
    CONSTRAINT pk_expense_category_key PRIMARY KEY,

  expense_category_name
    VARCHAR(16) NOT NULL,

  expense_category_desc
    VARCHAR(72) NOT NULL,

  expense_subcategory_name
    VARCHAR(48),

  expense_subcategory_desc
    VARCHAR(96),

  CONSTRAINT uq_expense_category UNIQUE(
    expense_category_name
    , expense_subcategory_name
  ),

  CONSTRAINT uq_expense_category_desc UNIQUE(
    expense_category_desc
    , expense_subcategory_desc
  )
);


CREATE TABLE IF NOT EXISTS meta.income_category_master (
  income_category_key
    VARCHAR(65)
    CONSTRAINT pk_income_category_key PRIMARY KEY,

  income_category_name
    VARCHAR(16) NOT NULL,

  income_category_desc
    VARCHAR(72) NOT NULL,

  income_subcategory_name
    VARCHAR(48),

  income_subcategory_desc
    VARCHAR(96),

  CONSTRAINT uq_income_category UNIQUE(
    income_category_name
    , income_subcategory_name
  ),

  CONSTRAINT uq_income_category_desc UNIQUE(
    income_category_desc
    , income_subcategory_desc
  )
);
