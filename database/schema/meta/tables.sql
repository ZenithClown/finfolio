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
      ON UPDATE CASCADE,

  subrole_name
    VARCHAR(32)
    CONSTRAINT uq_subrole_name UNIQUE
    NOT NULL,

  subrole_desc
    VARCHAR(128)
    CONSTRAINT uq_subrole_description UNIQUE
    NOT NULL
);

CREATE TABLE IF NOT EXISTS meta.user_account_detail (
  username
    VARCHAR(16)
    CONSTRAINT pk_username PRIMARY KEY,

  fullname
    VARCHAR(64)
    CONSTRAINT uq_user_fullname UNIQUE
    NOT NULL,

  email
    VARCHAR(128)
    CONSTRAINT uq_user_email_address UNIQUE,

  phone
    VARCHAR(16)
    CONSTRAINT uq_user_phone_number UNIQUE,

  date_of_birth
    DATE,

  user_role
    INTEGER
    NOT NULL
    CONSTRAINT fk_user_role_id
      REFERENCES meta.user_role (role_id)
      ON DELETE CASCADE
      ON UPDATE CASCADE,

  user_subrole
    INTEGER
    CONSTRAINT fk_user_subrole_id
      REFERENCES meta.user_subrole (subrole_id)
      ON DELETE CASCADE
      ON UPDATE CASCADE
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

CREATE TABLE IF NOT EXISTS meta.ledger_account_detail (
  ledger_account_id
    CHAR(5)
    CONSTRAINT pk_ledger_account_id PRIMARY KEY,

  account_name
    VARCHAR(64)
    CONSTRAINT uq_account_name UNIQUE
    NOT NULL,

  account_owner
    VARCHAR(16)
    NOT NULL
    CONSTRAINT fk_account_owner
      REFERENCES meta.user_account_detail (username)
      ON DELETE CASCADE
      ON UPDATE CASCADE,

  account_type_id
    CHAR(3)
    NOT NULL
    CONSTRAINT fk_ledger_account_type_id
      REFERENCES meta.account_type_detail  (account_type_id)
      ON DELETE CASCADE
      ON UPDATE CASCADE,

  account_subtype_id
    CHAR(3)
    CONSTRAINT fk_ledger_sub_account_type_id
      REFERENCES meta.account_subtype_detail  (account_subtype_id)
      ON DELETE CASCADE
      ON UPDATE CASCADE,

  account_opened_on
    DATE
    NOT NULL,

  account_closed_on
    DATE,

  account_marked_inactive_on
    DATE,

  opening_balance
    NUMERIC(19, 2)
    NOT NULL
    DEFAULT 0.00,

  opening_balance_recorded_on
    DATE
    NOT NULL -- ? DEFAULT account_opened_on
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
