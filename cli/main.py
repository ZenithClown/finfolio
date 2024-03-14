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

from new_account import (
    setTDAccount,   # create a new td account // 3
    setDebitAccount # create a new debit account // 1
)

# ! append the path to the root of the file start
sys.path.append(os.path.dirname(os.path.abspath(__file__)))
from backend.config import * # noqa: F401, F403
from backend import execute, executescript

# start the application with a global message, and insert logger information
print("Welcome to pOrgz CLI - an AI/ML enabled Utility Tool for Finance Management".center(os.get_terminal_size().columns))
print("===========================================================================".center(os.get_terminal_size().columns), end = "\n\n")

dyn_fetch_account_sub_type = """
SELECT
    AccountSubTypeID
    , AccountSubTypeName
FROM "ams.mwSubAccountType"
WHERE AccountTypeID = '{type_}'
"""

dyn_fetch_debit_account = """
SELECT * FROM "ams.mwAccountProperty" WHERE AccountTypeID = 'DBT'
"""

readStatement = lambda dir, file : open(os.path.join(dir, file)).read()
fetchSubTypes = lambda type_ : APP_ENGINE.execute(dyn_fetch_account_sub_type.format(type_ = type_)).fetchall()
formatDebitAccounts = lambda : APP_ENGINE.execute(dyn_fetch_debit_account).fetchall()

def mapOperations(operation : int):
    return {
        1 : (setDebitAccount, fetchSubTypes("DBT"), "create_new_ext_dbt_acc_property.sql"),
        3 : (setTDAccount, fetchSubTypes("TDA"), "create_new_ext_td_acc_property.sql")
    }.get(operation, None)


if __name__ == "__main__":
    print("What do you want to do? Select option from below:")
    print("  1. Create a DEBIT Account.")
    print("  2. Create a CREDIT Account.")
    print("  3. Create a TERM/Time Deposit Account.")
    operation = int(input("Enter Option Number: "))

    create_new_acc_property = readStatement(INTERFACE, "create_new_account_property.sql")

    func, sub_types, statement = mapOperations(operation = operation)

    if operation in [1]: # these function can work only with sub-types
        primary_account_property, extended_account_property = func(sub_types)
    elif operation in [3]: # need multiple parameters
        primary_account_property, extended_account_property = func(sub_types, accounts = formatDebitAccounts())

    execute(create_new_acc_property, engine = APP_ENGINE, params = primary_account_property)

    create_ext_acc_property = readStatement(INTERFACE, statement)
    execute(create_ext_acc_property, engine = APP_ENGINE, params = extended_account_property)
