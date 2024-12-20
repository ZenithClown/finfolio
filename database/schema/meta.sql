/********************************************************************
META Table Schema Structure and Table Create Statement Defination

The metadata table namespace holds special configurations (which in
this case is mostly the master tables) for finance management.

Copywright © [2024] Debmalya Pramanik
********************************************************************/

CREATE TABLE IF NOT EXISTS meta.user_role (
  role_id
    SERIAL
    CONSTRAINT pk_role_id PRIMARY KEY,

  role_name
    CHAR(4)
    CONSTRAINT uq_role_name UNIQUE
    NOT NULL,

  role_desc
    VARCHAR(64)
    CONSTRAINT uq_role_description UNIQUE
    NOT NULL
);

CREATE TABLE IF NOT EXISTS meta.user_subrole (
  subrole_id
    SERIAL
    CONSTRAINT pk_subrole_id PRIMARY KEY,

  role_id
    INTEGER
    NOT NULL
    CONSTRAINT fk_parent_role_id
      REFERENCES meta.user_role (role_id)
      ON DELETE CASCADE
      ON UPDATE CASCADE
    CONSTRAINT ck_role_id_valid
      CHECK (role_id IN (4, 5)),

  subrole_name
    VARCHAR(32)
    CONSTRAINT uq_subrole_name UNIQUE
    NOT NULL,

  subrole_desc
    VARCHAR(128)
    CONSTRAINT uq_subrole_description UNIQUE
    NOT NULL
);

CREATE TABLE IF NOT EXISTS meta.account_type_detail (
  account_type_id
    CHAR(3)
    CONSTRAINT pk_account_type_id PRIMARY KEY,

  account_type_name
    VARCHAR(32)
    CONSTRAINT uq_account_type_name UNIQUE
    NOT NULL,

  account_type_desc
    VARCHAR(128)
    CONSTRAINT uq_account_type_desc UNIQUE
    NOT NULL
);

CREATE TABLE IF NOT EXISTS meta.account_subtype_detail (
  account_subtype_id
    CHAR(3)
    CONSTRAINT pk_sub_account_type_id PRIMARY KEY,

  account_type_id
    CHAR(3)
    NOT NULL
    CONSTRAINT fk_account_type_id
      REFERENCES meta.account_type_detail (account_type_id)
      ON DELETE CASCADE
      ON UPDATE CASCADE,

  account_subtype_name
    VARCHAR(34)
    CONSTRAINT uq_account_subtype_name UNIQUE
    NOT NULL,

  account_subtype_desc
    VARCHAR(64)
    CONSTRAINT uq_account_subtype_desc UNIQUE
);

CREATE TABLE IF NOT EXISTS meta.transaction_type (
  type_id
    CHAR(1)
    CONSTRAINT pk_trx_type_id PRIMARY KEY,

  trx_type_detail
    VARCHAR(64)
    CONSTRAINT uq_trx_type_detail UNIQUE
    NOT NULL
);

CREATE TABLE IF NOT EXISTS meta.transaction_method (
  method_name
    VARCHAR(7)
    CONSTRAINT pk_trx_method_name PRIMARY KEY,

  method_desc
    VARCHAR(64)
    CONSTRAINT uq_trx_method_desc UNIQUE
    NOT NULL
);

CREATE TABLE IF NOT EXISTS meta.expense_category (
  expense_category_name
    VARCHAR(16)
    CONSTRAINT pk_expense_category_name PRIMARY KEY,

  expense_category_desc
    VARCHAR(72)
    CONSTRAINT uq_expense_category_desc UNIQUE
    NOT NULL
);

CREATE TABLE IF NOT EXISTS meta.expense_subcategory (
  expense_subcategory_name
    VARCHAR(48)
    CONSTRAINT pk_expense_subcategory_name PRIMARY KEY,

  primary_expense_category
    VARCHAR(16)
    CONSTRAINT fk_primary_expense_category
      REFERENCES meta.expense_category  (expense_category_name)
      ON DELETE CASCADE
      ON UPDATE CASCADE,

  expense_subcategory_desc
    VARCHAR(96)
    CONSTRAINT uq_expense_subcategory_desc UNIQUE
    NOT NULL
);
