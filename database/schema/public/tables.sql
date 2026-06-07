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

  -- ..versionchanged:: 2026-06-07 [B16] families with same fullname are valid
  -- (a parent and child can both be "Pramanik"); drop UNIQUE. A non-unique
  -- index on lower(fullname) supports dashboard search; defined below.
  fullname
    VARCHAR(128) NOT NULL,

  email
    VARCHAR(128)
    CONSTRAINT uq_user_email_address UNIQUE,

  -- ..versionchanged:: 2026-06-07 [B20] phone regex required at least one
  -- character (was `*` which accepted '' as valid, bypassing NULL semantics)
  phone
    VARCHAR(16)
    CONSTRAINT uq_user_phone_number UNIQUE
    CONSTRAINT ck_phone_number CHECK (phone IS NULL OR phone ~ '^[0-9+\- ]+$'),

  date_of_birth
    DATE,

  user_role
    meta.user_role NOT NULL DEFAULT 'USER',

  -- ..versionadded:: 2025-10-12 added managed by user to set relation
  -- this can return the list of users who can manage this user and
  -- thus establish a relationship - self table foreign key is used
  -- ! if none, then user with the root privilege is assigned - and
  -- one table can have only one root user; others can be sudo (*nix)
  managed_by
    VARCHAR(16)
    CONSTRAINT fk_self_managed_by_user REFERENCES
      public.user_account_detail (username)
      ON DELETE SET NULL
      ON UPDATE SET NULL,

  -- ..versionadded:: 2025-10-12 added password field for user login
  -- ! Uses PgCrypto Extension to stored hased salted password (default)
  -- ? INSERT ... VALUES (..., CRYPT('password', GEN_SALT('bf', 12)));
  -- ? SELECT ... WHERE ..., password = CRYPT('password', password);
  password
    TEXT NOT NULL,

  -- ..versionadded:: 2026-06-07 [B25] audit columns. `created_on` is
  -- immutable insertion timestamp; `updated_on` is maintained by the
  -- public.onupdate() BEFORE UPDATE trigger (bound in
  -- public/triggers/user_account_detail.sql).
  created_on
    TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_on
    TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);


-- ..versionadded:: 2026-06-07 [B25] idempotent ALTER for clusters
-- created before audit columns existed. Re-running initialize.sql on
-- an existing DB without these guards would still leave old tables
-- column-less because CREATE TABLE IF NOT EXISTS is a no-op.
ALTER TABLE public.user_account_detail
  ADD COLUMN IF NOT EXISTS created_on TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP;
ALTER TABLE public.user_account_detail
  ADD COLUMN IF NOT EXISTS updated_on TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP;

-- ..versionadded:: 2026-06-07 [B16] for upgrades from clusters that already
-- carried the legacy UNIQUE constraint on fullname.
ALTER TABLE public.user_account_detail
  DROP CONSTRAINT IF EXISTS uq_user_fullname;

-- ..versionadded:: 2026-06-07 [B16] case-insensitive search index on
-- fullname for the user-picker dropdown in the dashboard.
CREATE INDEX IF NOT EXISTS ix_user_account_detail_fullname_lower
  ON public.user_account_detail (lower(fullname));

-- ..versionadded:: 2026-06-07 [B20] reinstate the strengthened phone check
-- on upgrade paths (the constraint name is reused so DROP+ADD is safe).
ALTER TABLE public.user_account_detail
  DROP CONSTRAINT IF EXISTS ck_phone_number;
ALTER TABLE public.user_account_detail
  ADD  CONSTRAINT ck_phone_number CHECK (phone IS NULL OR phone ~ '^[0-9+\- ]+$');


CREATE TABLE IF NOT EXISTS public.ledger_account_detail (
  ledger_account_id
    CHAR(5) DEFAULT LEFT(UPPER(GEN_RANDOM_UUID()::VARCHAR(36)), 5)
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

  account_type_key
    VARCHAR(7) NOT NULL
    CONSTRAINT fk_ledger_account_type_key
      REFERENCES meta.account_type_master  (account_type_key)
      ON DELETE CASCADE
      ON UPDATE CASCADE,

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

  -- ..versionadded:: 2026-06-07 [B25] audit columns for ledger accounts
  created_on
    TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_on
    TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

ALTER TABLE public.ledger_account_detail
  ADD COLUMN IF NOT EXISTS created_on TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP;
ALTER TABLE public.ledger_account_detail
  ADD COLUMN IF NOT EXISTS updated_on TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP;


CREATE TABLE IF NOT EXISTS public.points_account_detail (
  points_account_id
    CHAR(5)
    CONSTRAINT pk_points_account_id PRIMARY KEY,

  points_account_name
    VARCHAR(64) NOT NULL
    CONSTRAINT uq_points_account_name UNIQUE,

  ledger_account_id
    CHAR(5)
    CONSTRAINT fk_points_ledger_account_id
      REFERENCES public.ledger_account_detail (ledger_account_id)
      ON DELETE CASCADE
      ON UPDATE CASCADE,

  account_type_key
    VARCHAR(7) NOT NULL
    CONSTRAINT fk_ledger_account_type_key
      REFERENCES meta.account_type_master  (account_type_key)
      ON DELETE CASCADE
      ON UPDATE CASCADE,

  conversion_factor
    NUMERIC(9, 5) NOT NULL DEFAULT 1.00000,

  opening_balance
    NUMERIC(12, 2) NOT NULL DEFAULT 0.00,

  -- ? field is useful if you do not have complete historical data
  -- default should be `account_opened_on` date; same like ledger a/c
  opening_balance_recorded_on
    DATE NOT NULL
);
