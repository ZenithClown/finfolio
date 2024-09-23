/********************************************************************
META Table Schema Structure and Table Create Statement Defination

The metadata table namespace holds special configurations (which in
this case is mostly the master tables) for finance management.

Copywright © [2024] Debmalya Pramanik
********************************************************************/

CREATE TABLE IF NOT EXISTS meta.user_account_detail (
  username
    VARCHAR(16)
    CONSTRAINT pk_username PRIMARY KEY,

  fullname
    VARCHAR(64)
    UNIQUE NOT NULL
);

CREATE TABLE IF NOT EXISTS meta.account_type_detail (
  account_type_id
    VARCHAR(3)
    CONSTRAINT pk_account_type_id PRIMARY KEY,

  account_type_name
    VARCHAR(16)
    UNIQUE NOT NULL,

  account_type_desc
    VARCHAR(64)
    UNIQUE NOT NULL
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
