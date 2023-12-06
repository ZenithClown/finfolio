# -*- encoding: utf-8 -*-

"""
Command Line Interface (CLI) for DB Interaction

Created a command line interface module for db interaction, since the
frontend application is yet not developed. The `main.py` holds the
configuration keys and informations.

@author:  Debmalya Pramanik
@copywright: pOrgz <https://github.com/pOrgz-dev>
"""

import os
import sqlite3

ROOT = os.path.join(os.path.abspath(__file__), "..")
DB_PATH = "E:\\database\\pOrgz.db" # ! STATIC path is provided

DB_MODELS = os.path.join(ROOT, "database", "models")
DB_VIEWS = os.path.join(DB_MODELS, "views") # part of the `models`
DB_QUERIES = os.path.join(ROOT, "database", "queries")

if __name__ == "__main__":
    con = sqlite3.connect(DB_PATH)

    # for first time, create all tables in database
    # also populate static pre-defined master values (from file)
    con.execute(open(os.path.join(DB_MODELS, "ams.mwAccountType.sql")).read())
    con.execute(open(os.path.join(DB_MODELS, "ams.mwAccountProperty.sql")).read())
