# -*- encoding: utf-8 -*-

"""
A Simple SQLite3 Interface to Create & Initialize DB

Create a `finfolio.db` file at `Path()/pOrgz/` directory, and populate
with initial master data. The initial master data is stored in the
[configuration](./config) directory.

@author:  Debmalya Pramanik
@version: v0.0.1
"""

import os

from tqdm import tqdm as TQ
from backend.config import * # noqa: F401, F403
from backend import execute, executescript

readStatement = lambda dir, file : open(os.path.join(dir, file)).read()

if __name__ == "__main__":
    print("Welcome to pOrgz CLI - an AI/ML enabled Utility Tool for Finance Management".center(os.get_terminal_size().columns))
    print("===========================================================================".center(os.get_terminal_size().columns), end = "\n\n")

    print(f"Setting Application Homepath: {APP_HOME}")
    print("Check FOSS Code Documentation: ") # TODO: https://github.com/ZenithClown/finfolio/issues/6

    print("\n") # add blank line, start execution of statements

    # ? create master tables, as defined under `database/models/`
    files = [
        readStatement(DB_MODELS, "ams.accounts.sql")
    ]

    _ = [executescript(statement, engine = APP_ENGINE) for statement in TQ(files, desc = "Initialize DB Models...")]

    print("Starting to Populate Master Data with Preconfigured Keys...")
    for table, file in zip(
        ["ams.mwAccountType", "ams.mwSubAccountType"],
        ["insert_into_ams_mw_account_type.sql", "insert_into_ams_mw_sub_account_type.sql"]
    ):
        statement = readStatement(INTERFACE, file) # dynamic read from `database/interface`
        for record in TQ(MASTER_INIT_DATA["tables"][table], desc = f"PROC({table}) ..."):
            try:
                _ = execute(statement, engine = APP_ENGINE, params = tuple(record))
            except Exception as err:
                print(f"  >> Failed Record: {tuple(record)}.")
                print(f"  >> Error Message: {err}")
