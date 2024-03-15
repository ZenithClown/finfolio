# -*- encoding: utf-8 -*-

"""
A Set of CLI based Functions for Extended Transactions Table

The extended transactions table is defined to register/map operations
to the linked primary account (typically a DEBIT account).

@author:  Debmalya Pramanik
@version: v0.0.1
"""

import os
import sys

# ! append the path to the root of the file start
sys.path.append(os.path.dirname(os.path.abspath(__file__)))
from backend.config import * # noqa: F401, F403
from backend import execute, executescript

def mapFDAccount(srcAccountID : str, dstAccountID : str) -> bool:
    deposit_trx_id = int(input("  >> Deposit Transaction ID    : "))
    withdraw_trx_id = int(input("  >> Withdrawal Transaction ID : "))

    statement = """
    INSERT INTO "ams.extTransactions" (refTrxID, srcAccountID, dstAccountID, _trxType)
        VALUES (?, ?, ?, ?);
    """

    print("\nTrying to Insert Record into DB:")
    for _id, _type in zip([deposit_trx_id, withdraw_trx_id], ["_deposit", "_withdraw"]):
        try:
            _ = execute(statement, engine = APP_ENGINE, params = (_id, srcAccountID, dstAccountID, _type))
        except Exception as err:
            print(f"Failed for Record `{(_id, srcAccountID, dstAccountID, _type)}`")
            print(f"  >> ERROR: {err}")

    print("  >> Completed Data Insert.")
    return True
