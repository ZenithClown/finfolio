/********************************************************************
ENUM Data Types for Static Small Data Types - Self Explanatory

The enum data type is handy to define a small set of static data which
is unlikely to change and the values are finite. The enum provides
data integrity and readibility and the name(s) defined are self
explanatory and are index friendly.

Copywright © [2024] Debmalya Pramanik
********************************************************************/

-- ? User Role:: Table for User Access Controls
CREATE TYPE meta.user_role AS ENUM ('ROOT', 'SUDO', 'USER');

-- ? Transaction Types:: Deposit or Withdraw
CREATE TYPE meta.transaction_type AS ENUM ('DEPOSIT', 'WITHDRAW');

-- ? Points Transaction Types:: Points Earned, Spent, or. etc.
CREATE TYPE meta.points_transaction_type AS ENUM (
  'EARNED', 'SPENT', 'ADJUSTED', 'LAPSED'
);

-- ? Transaction Method:: Cash, Card, Online, etc.
CREATE TYPE meta.transaction_method AS ENUM (
  'NEFT', 'IMPS', 'RTGS', 'UPI', 'MANDATE', 'CASH', 'CREDIT', 'NACH'
);
