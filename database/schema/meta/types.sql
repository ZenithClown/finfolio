/********************************************************************
ENUM Data Types for Static Small Data Types - Self Explanatory

The enum data type is handy to define a small set of static data which
is unlikely to change and the values are finite. The enum provides
data integrity and readibility and the name(s) defined are self
explanatory and are index friendly.

Copywright © [2024] Debmalya Pramanik
********************************************************************/

CREATE TYPE meta.user_role AS ENUM ('ROOT', 'SUDO', 'USER');
CREATE TYPE meta.transaction_type AS ENUM ('DEPOSIT', 'WITHDRAW');
CREATE TYPE meta.points_transaction_type AS ENUM ('EARNED', 'SPENT', 'ADJUSTED', 'LAPSED');
