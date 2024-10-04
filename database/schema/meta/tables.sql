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
    VARCHAR(4)
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
    VARCHAR(4)
    CONSTRAINT uq_subrole_name UNIQUE
    NOT NULL,

  subrole_desc
    VARCHAR(64)
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
    CONSTRAINT fk_user_role_id
      REFERENCES meta.user_subrole (subrole_id)
      ON DELETE CASCADE
      ON UPDATE CASCADE
);

CREATE TABLE IF NOT EXISTS meta.account_type_detail (
  account_type_id
    VARCHAR(3)
    CONSTRAINT pk_account_type_id PRIMARY KEY,

  account_type_name
    VARCHAR(16)
    CONSTRAINT uq_account_type_name UNIQUE
    NOT NULL,

  account_type_desc
    VARCHAR(64)
    CONSTRAINT uq_account_type_desc UNIQUE
    NOT NULL
);

CREATE TABLE IF NOT EXISTS meta.account_subtype_detail (
  account_subtype_id
    VARCHAR(3)
    CONSTRAINT pk_sub_account_type_id PRIMARY KEY,

  account_type_id
    VARCHAR(3)
    NOT NULL
    CONSTRAINT fk_account_type_id
      REFERENCES meta.account_type_detail (account_type_id)
      ON DELETE CASCADE
      ON UPDATE CASCADE,

  account_subtype_name
    VARCHAR(16)
    UNIQUE NOT NULL,

  account_subtype_desc
    VARCHAR(64)
    UNIQUE NOT NULL
);

CREATE TABLE IF NOT EXISTS meta.ledger_account_detail (
  ledger_account_id
    CHAR(5)
    CONSTRAINT pk_ledger_account_id PRIMARY KEY,

  account_name
    VARCHAR(64)
    UNIQUE NOT NULL,

  account_owner
    VARCHAR(16)
    NOT NULL
    CONSTRAINT fk_account_owner FOREIGN KEY
      REFERENCES meta.user_account_detail (username)
      ON DELETE CASCADE
      ON UPDATE CASCADE,

  account_type_id
    VARCHAR(3)
    NOT NULL
    CONSTRAINT fk_ledger_account_type_id FOREIGN KEY
      REFERENCES meta.account_type_detail  (account_type_id)
      ON DELETE CASCADE
      ON UPDATE CASCADE,

  account_subtype_id
    VARCHAR(3)
    CONSTRAINT fk_ledger_sub_account_type_id FOREIGN KEY
      REFERENCES meta.account_subtype_detail  (account_subtype_id)
      ON DELETE CASCADE
      ON UPDATE CASCADE
);
