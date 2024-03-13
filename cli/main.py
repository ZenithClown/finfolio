# -*- encoding: utf-8 -*-

"""
Command Line Interface (CLI) for DB Interaction

Created a command line interface module for db interaction, since the
frontend application is yet not developed. The `main.py` is developed
for streamlit application, while the `cli.py` can be used to start
the pOrgz application is CLI mode.

!! Set `logger_ = (*, appType = "cli")` in `config/globals.py`

@author:  Debmalya Pramanik
@copywright: pOrgz <https://github.com/pOrgz-dev>
"""

import os
import sys

from config import * # noqa: F401, F403

# start the application with a global message, and insert logger information
print("Welcome to pOrgz CLI - an AI/ML enabled Utility Tool for Finance Management".center(os.get_terminal_size().columns))
print("===========================================================================".center(os.get_terminal_size().columns), end = "\n\n")

sys.path.append(os.path.join(APP_ROOT, "db", "queries"))

from create import createDebitAccount # pyright: ignore[reportMissingImports]

def mapOperations(operation : int):
    return {
        1 : (createDebitAccount, "create_debit_accounts.sql")
    }.get(operation, None)


if __name__ == "__main__":
    print("What do you want to do? Select option from below:")
    print("  1. Create a DEBIT Account.")
    print("  2. Create a CREDIT Account.")
    operation = int(input("Enter Option Number: "))

    func, statement = mapOperations(operation = operation)
    func(statement = os.path.join(DB_QUERIES, statement), con = APP_DATA) # execute operations
