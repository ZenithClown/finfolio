/********************************************************************
META Table Schema Structure and Table Create Statement Defination

The metadata table namespace holds special configurations (which in
this case is mostly the master tables) for finance management. The
tables are designed to be simple and uses composite foreign key to
map any transaction tables with one single source of truth.

Copywright © [2024] Debmalya Pramanik
********************************************************************/

CREATE TABLE IF NOT EXISTS meta.account_type_master (
  account_type_key
    VARCHAR(7)
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

  CONSTRAINT cpk_account_type UNIQUE (
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


CREATE TABLE IF NOT EXISTS meta.expense_category (
  expense_category_name
    VARCHAR(16)
    CONSTRAINT pk_expense_category_name PRIMARY KEY,

  expense_category_desc
    VARCHAR(72) NOT NULL
    CONSTRAINT uq_expense_category_desc UNIQUE
);


CREATE TABLE IF NOT EXISTS meta.expense_subcategory (
  expense_subcategory_name
    VARCHAR(48)
    CONSTRAINT pk_expense_subcategory_name PRIMARY KEY,

  primary_expense_category
    VARCHAR(16) NOT NULL
    CONSTRAINT fk_primary_expense_category
      REFERENCES meta.expense_category  (expense_category_name)
      ON DELETE CASCADE
      ON UPDATE CASCADE,

  expense_subcategory_desc
    VARCHAR(96) NOT NULL
    CONSTRAINT uq_expense_subcategory_desc UNIQUE,

  CONSTRAINT uq_expense_category_subcategory UNIQUE (
    primary_expense_category, expense_subcategory_name
  )
);


CREATE TABLE IF NOT EXISTS meta.income_category (
  income_category_name
    VARCHAR(16)
    CONSTRAINT pk_income_category_name PRIMARY KEY,

  income_category_desc
    VARCHAR(72) NOT NULL
    CONSTRAINT uq_income_category_desc UNIQUE
);


CREATE TABLE IF NOT EXISTS meta.income_subcategory (
  income_subcategory_name
    VARCHAR(48)
    CONSTRAINT pk_income_subcategory_name PRIMARY KEY,

  primary_income_category
    VARCHAR(16) NOT NULL
    CONSTRAINT fk_primary_income_category
      REFERENCES meta.income_category  (income_category_name)
      ON DELETE CASCADE
      ON UPDATE CASCADE,

  income_subcategory_desc
    VARCHAR(96) NOT NULL
    CONSTRAINT uq_income_subcategory_desc UNIQUE,

  CONSTRAINT uq_income_category_subcategory UNIQUE (
    primary_income_category, income_subcategory_name
  )
);
