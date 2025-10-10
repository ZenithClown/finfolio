# -*- encoding: utf-8 -*-

"""
PostgreSQL Setup for Personal Finance Portifolio DB

The setup script is intended to be used as a one-shot tool to create,
and initialize finfolio database with tables and seed values. This is
a temporary file and maybe replaced with ORM based approach when the
REST API services for the database is developed.

@author:  Debmalya Pramanik
@version: v0.0.1
"""

import os
import psycopg

import sqlparser

def conninfo():
    host = os.getenv("FINFOLIO_DB_HOST", "localhost")
    port = os.getenv("FINFOLIO_DB_PORT", 5432)
    dbname = os.getenv("FINFOLIO_DB_NAME", "finfolio")
    username = os.getenv("FINFOLIO_DB_USERNAME", "postgres")
    password = os.getenv("FINFOLIO_DB_PASSWORD", "password")

    return f"host={host} port={port} dbname={dbname} user={username} password={password}"

if __name__ == "__main__":
    print("Setting up FINFOLIO DB...")

    ROOT = os.path.abspath(os.path.dirname(__file__))
    DATABASE = os.path.join(ROOT, "database")

    with psycopg.connect(conninfo()) as conn:
        # open a cursor to perform database operations
        with conn.cursor() as cur:
            # initially create the required schema, and then create tables
            statements = sqlparser.readStatement(os.path.join(DATABASE, "schema", "init.sql"))

            for statement in statements:
                # create schema in a for loop, and finally commit
                try:
                    cur.execute(statement)
                except Exception as err:
                    print(f"Skipping Execution of Statement: `{statement}`. Error Message: {err}")

        # make the changes in the database persistent
        conn.commit()

        # create all the tables in the database, and populate with initial seed values
        with conn.cursor() as cur:
            for file in ["meta.sql", "public.sql", "private.sql"]:
                statements = sqlparser.readStatement(os.path.join(DATABASE, "schema", file))

                for statement in statements:
                    # execute each statement, else fail with full statement output
                    try:
                        cur.execute(statement)
                        conn.commit()
                    except Exception as err:
                        print("FAILED:: Execution of the statement failed. Statement:")
                        print(statement)
                        print(f"ERROR Message: {err}")

            for file in ["user_role_subrole.sql", "transaction_type_method.sql", "expense_category_subcategory.sql", "account_type_subtype.sql"]:
                statements = sqlparser.readStatement(os.path.join(DATABASE, "seed", file))

                for statement in statements:
                    # execute each statement, else fail with full statement output
                    try:
                        cur.execute(statement)
                        conn.commit()
                    except Exception as err:
                        print("FAILED:: Execution of the statement failed. Statement:")
                        print(statement)
                        print(f"ERROR Message: {err}")
