/********************************************************************
PUBLIC Table Schema Structure and Table Create Statement Defination

PostgreSQL's default schema is the "public" schema which is used to
store essential information about the user and their accounts.

Copywright © [2024] Debmalya Pramanik
********************************************************************/

CREATE TABLE IF NOT EXISTS public.user_account_detail (
  username
    VARCHAR(16)
    CONSTRAINT pk_username PRIMARY KEY
    CONSTRAINT ck_username_length CHECK (LENGTH(username) > 3),

  -- ? typically users can share names, but since this is a decentralized
  -- it is highly unlikely; if you need to share names, remove constraint
  fullname
    VARCHAR(128) NOT NULL
    CONSTRAINT uq_user_fullname UNIQUE,

  email
    VARCHAR(128)
    CONSTRAINT uq_user_email_address UNIQUE,

  phone
    VARCHAR(16)
    CONSTRAINT uq_user_phone_number UNIQUE
    CONSTRAINT ck_phone_number CHECK (phone ~ '^[0-9+\- ]*$'),

  date_of_birth
    DATE,

  user_role
    meta.user_role NOT NULL DEFAULT 'USER'
);


CREATE TABLE IF NOT EXISTS public.ledger_account_detail (
  ledger_account_id
    CHAR(5)
    CONSTRAINT pk_ledger_account_id PRIMARY KEY,

  account_name
    VARCHAR(64) NOT NULL
    CONSTRAINT uq_account_name UNIQUE,

  account_owner
    VARCHAR(16) NOT NULL
    CONSTRAINT fk_account_owner
      REFERENCES public.user_account_detail (username)
      ON DELETE CASCADE
      ON UPDATE CASCADE,

  account_type_id
    CHAR(3) NOT NULL
    CONSTRAINT fk_ledger_account_type_id
      REFERENCES meta.account_type_detail  (account_type_id)
      ON DELETE CASCADE
      ON UPDATE CASCADE,

  account_subtype_id
    CHAR(3),

  account_opened_on
    DATE NOT NULL,

  account_closed_on
    DATE,

  account_marked_inactive_on
    DATE,

  opening_balance
    NUMERIC(12, 2) NOT NULL DEFAULT 0.00,

  -- ? field is useful if you do not have complete historical data
  -- default should be `account_opened_on` date
  opening_balance_recorded_on
    DATE NOT NULL,

  CONSTRAINT fk_ledger_sub_account_type_id
    FOREIGN KEY (account_type_id, account_subtype_id)
    REFERENCES meta.account_subtype_detail (account_type_id, account_subtype_id)
      ON DELETE CASCADE
      ON UPDATE CASCADE
);


CREATE TABLE IF NOT EXISTS public.points_account_detail (
  points_account_id
    CHAR(5)
    CONSTRAINT pk_points_account_id PRIMARY KEY,

  points_account_name
    VARCHAR(64) NOT NULL
    CONSTRAINT uq_points_account_name UNIQUE,

  points_account_owner
    VARCHAR(16) NOT NULL
    CONSTRAINT fk_points_account_owner
      REFERENCES public.user_account_detail (username)
      ON DELETE CASCADE
      ON UPDATE CASCADE,

  ledger_account_id
    CHAR(5)
    CONSTRAINT fk_points_ledger_account_id
      REFERENCES public.ledger_account_detail (ledger_account_id)
      ON DELETE CASCADE
      ON UPDATE CASCADE,

  account_type_id
    CHAR(3) NOT NULL
    CONSTRAINT fk_points_account_type_id
      REFERENCES meta.account_type_detail  (account_type_id)
      ON DELETE CASCADE
      ON UPDATE CASCADE,

  account_subtype_id
    CHAR(3),

  conversion_factor
    NUMERIC(9, 5) NOT NULL DEFAULT 1.00000,

  opening_balance
    NUMERIC(12, 2) NOT NULL DEFAULT 0.00,

  -- ? field is useful if you do not have complete historical data
  -- default should be `account_opened_on` date; same like ledger a/c
  opening_balance_recorded_on
    DATE NOT NULL,

  CONSTRAINT fk_points_sub_account_type_id
    FOREIGN KEY (account_type_id, account_subtype_id)
    REFERENCES meta.account_subtype_detail (account_type_id, account_subtype_id)
      ON DELETE CASCADE
      ON UPDATE CASCADE
);
