/********************************************************************
Personal Finance DB (finfolio) Initialization Statement (PostgreSQL)

The initialization statement is to be triggered by a new user to
create necessary structures. The database name defaults to `finfolio`
same as that of the repository name.

Author  : Debmalya Pramanik
Contact : dpramanik.official@gmail.com

Copywright © [2024] Debmalya Pramanik
********************************************************************/

CREATE DATABASE finfolio WITH
  OWNER = postgres
  ENCODING = 'UTF8'
  CONNECTION LIMIT = -1;

-- ? as per documentation, the following schemas are created in db
-- postgres default schema is `public` and usage is still under dev.
CREATE SCHEMA meta; -- schema for configuration values
CREATE SCHEMA private; -- schema to hold user transaction values
