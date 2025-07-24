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
    meta.user_role NOT NULL
);


CREATE TABLE IF NOT EXISTS public.ledger_account_detail (
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
      REFERENCES public.user_account_detail (username)
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
    DEFAULT NULL
    CONSTRAINT fk_ledger_sub_account_type_id
      REFERENCES meta.account_subtype_detail  (account_subtype_id)
      ON DELETE CASCADE
      ON UPDATE CASCADE,

  account_opened_on
    DATE
    NOT NULL,

  account_closed_on
    DATE
    DEFAULT NULL,

  account_marked_inactive_on
    DATE
    DEFAULT NULL,

  opening_balance
    NUMERIC(12, 2)
    NOT NULL
    DEFAULT 0.00,

  opening_balance_recorded_on
    DATE
    NOT NULL -- ? DEFAULT account_opened_on
);
