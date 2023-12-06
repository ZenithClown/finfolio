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
import time
import tqdm
import sqlite3

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..")
DB_PATH = "E:\\database\\pOrgz.db" # ! STATIC path is provided

DB_MODELS = os.path.join(ROOT, "database", "models")
DB_VIEWS = os.path.join(DB_MODELS, "views") # part of the `models`
DB_QUERIES = os.path.join(ROOT, "database", "queries")

if __name__ == "__main__":
    con = sqlite3.connect(DB_PATH)

    print("Welcome to pOrgz CLI - an AI/ML enabled Utility Tool for Finance Management".center(os.get_terminal_size().columns))
    print("===========================================================================".center(os.get_terminal_size().columns), end = "\n\n")

    # for first time, create all tables in database
    # also populate static pre-defined master values (from file)
    for file in tqdm.tqdm([
        os.path.join(DB_MODELS, "ams.mwAccountType.sql"),
        os.path.join(DB_MODELS, "ams.mwAccountProperty.sql")
    ], desc = f"{time.ctime()} | Executing Table Create Statements at {DB_PATH}"):
        try:
            con.executescript(open(file).read())
        except sqlite3.IntegrityError as err:
            print(f" >> Failed for File: {file} > {err}")

    con.commit()
    con.close()
