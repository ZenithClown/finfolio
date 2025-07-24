/********************************************************************
META Table Schema Structure and Table Create Statement Defination

The metadata table namespace holds special configurations (which in
this case is mostly the master tables) for finance management.

Copywright © [2024] Debmalya Pramanik
********************************************************************/

CREATE TABLE IF NOT EXISTS meta.account_type_detail (
  account_type_id
    CHAR(3)
    CONSTRAINT pk_account_type_id PRIMARY KEY,

  account_type_name
    VARCHAR(32) NOT NULL
    CONSTRAINT uq_account_type_name UNIQUE,

  account_type_desc
    VARCHAR(128) NOT NULL
    CONSTRAINT uq_account_type_desc UNIQUE
);


CREATE TABLE IF NOT EXISTS meta.account_subtype_detail (
  account_subtype_id
    CHAR(3)
    CONSTRAINT pk_sub_account_type_id PRIMARY KEY,

  account_type_id
    CHAR(3) NOT NULL
    CONSTRAINT fk_account_type_id
      REFERENCES meta.account_type_detail (account_type_id)
      ON DELETE CASCADE
      ON UPDATE CASCADE,

  account_subtype_name
    VARCHAR(34) NOT NULL
    CONSTRAINT uq_account_subtype_name UNIQUE,

  account_subtype_desc
    VARCHAR(64)
    CONSTRAINT uq_account_subtype_desc UNIQUE
);


CREATE TABLE IF NOT EXISTS meta.transaction_method (
  method_name
    VARCHAR(7)
    CONSTRAINT pk_trx_method_name PRIMARY KEY,

  method_desc
    VARCHAR(64) NOT NULL
    CONSTRAINT uq_trx_method_desc UNIQUE
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
    CONSTRAINT uq_expense_subcategory_desc UNIQUE
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
    CONSTRAINT uq_income_subcategory_desc UNIQUE
);
