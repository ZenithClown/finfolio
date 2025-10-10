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

from tabulate import tabulate

from new_account import (
    setTDAccount,       # create a new td account // 3
    setDebitAccount,    # create a new debit account // 1
    setAccountProperty  # currently using for all others
)

from ext_transactions import (
    mapFDAccount, # register/map for fixed deposits
    mapRDAccount  # register/map for recurring deposits
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

dyn_fetch_tdaccount_ext_transactions = """
SELECT * FROM "ams.extTransactions" WHERE dstAccountID = '{dst_account_id}'
"""

dyn_fetch_td_ext_account_details = """
SELECT * FROM "ams.extTermDepositAccount" WHERE AccountID = '{account_id}'
"""

readStatement = lambda dir, file : open(os.path.join(dir, file)).read()
fetchSubTypes = lambda type_ : APP_ENGINE.execute(dyn_fetch_account_sub_type.format(type_ = type_)).fetchall()
formatDebitAccounts = lambda : APP_ENGINE.execute(dyn_fetch_debit_account).fetchall()
fetchExistingExtTrx = lambda dst_account_id : APP_ENGINE.execute(dyn_fetch_tdaccount_ext_transactions.format(dst_account_id = dst_account_id)).fetchall()
fetchTDExtAccDetail = lambda account_id : APP_ENGINE.execute(dyn_fetch_td_ext_account_details.format(account_id = account_id)).fetchone()

def mapOperations(operation : int):
    return {
        1 : (setDebitAccount, fetchSubTypes("DBT"), "create_new_ext_dbt_acc_property.sql"),
        3 : (setTDAccount, fetchSubTypes("TDA"), "create_new_ext_td_acc_property.sql"),
        4 : (setAccountProperty, [], None)
    }.get(operation, None)


def printTable(items : list, headers : list) -> None:
    print(tabulate(items, headers = headers, tablefmt = "psql"))


if __name__ == "__main__":
    print("What do you want to do? Select option from below:")
    print("  1. Create a DEBIT Account.")
    print("  2. Create a CREDIT Account.")
    print("  3. Create a TERM/Time Deposit Account.")
    print("  4. Create a DEMAT Account.")
    print("  5. Register/Map TD Account Transaction to DEBIT Account.")
    operation = int(input("Enter Option Number: "))

    if operation <= 4:
        # new_account.py :: operation associated with creating a new account
        create_new_acc_property = readStatement(INTERFACE, "create_new_account_property.sql")

        func, sub_types, statement = mapOperations(operation = operation)

        if operation in [1]: # these function can work only with sub-types
            primary_account_property, extended_account_property = func(sub_types)
        elif operation in [3]: # need multiple parameters
            primary_account_property, extended_account_property = func(sub_types, accounts = formatDebitAccounts())
        elif operation in [4]: # these account does not have an extended property
            AccountTypeID = "DMT"
            AccountID, AccountNumber, AccountName, AccountSubTypeID, AccountOpenDate, AccountCloseDate = func(sub_types)
            primary_account_property = (AccountID, AccountNumber, AccountName, AccountTypeID, AccountSubTypeID, AccountOpenDate, AccountCloseDate)
        else:
            raise NotImplementedError("Please Wait for a Future Release!")

        execute(create_new_acc_property, engine = APP_ENGINE, params = primary_account_property)

        if statement:
            create_ext_acc_property = readStatement(INTERFACE, statement)
            execute(create_ext_acc_property, engine = APP_ENGINE, params = extended_account_property)

    elif operation == 5:
        # map td account transaction with/to debit account
        account_sub_type = fetchSubTypes("TDA")

        print("\nType of TERM/Time Deposit Account to Register/Map/Insert: ")
        for idx, subtype in enumerate(account_sub_type):
            subtype = f"{subtype[0]} ({subtype[1]})"
            print(f"  >> {idx + 1} : {subtype}")

        choice_ = int(input("Enter Sub-Type Number: "))
        account_sub_type = account_sub_type[choice_ - 1][0]

        accounts = [account for account in formatDebitAccounts() if account[4] == account_sub_type]
        print(f"\nSelect Account ID (for Account Sub-Type == `{account_sub_type}`): ")
        for idx, account in enumerate(accounts):
            account = f"{account[2]} ({account[1]})"
            print(f"  >> {idx + 1} : {account}")
        choice_ = int(input("Enter Account Choice Number: "))
        dst_account_id = accounts[choice_ - 1][0] # ! destination account id
        src_account_id = fetchTDExtAccDetail(dst_account_id)[2]
        print(f"Mapped Source A/C ID: `{src_account_id}`")

        print(f"\nAll Available/Mapped Records for Account ID: `{dst_account_id}`")
        printTable(fetchExistingExtTrx(dst_account_id), headers = ["_id", "refTrxID", "srcAccountID", "dstAccountID", "_trxType"])

        print("\nInput Value from Terminal:")
        if account_sub_type == "FDS":
            _ = mapFDAccount(src_account_id, dst_account_id)
        elif account_sub_type == "RDS":
            _ = mapRDAccount(src_account_id, dst_account_id)
        else:
            raise NotImplementedError
