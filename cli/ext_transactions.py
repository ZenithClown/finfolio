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

statement = """
INSERT INTO "ams.extTransactions" (refTrxID, srcAccountID, dstAccountID, _trxType)
    VALUES (?, ?, ?, ?);
"""

def mapFDAccount(srcAccountID : str, dstAccountID : str) -> bool:
    deposit_trx_id = int(input("  >> Deposit Transaction ID    : "))
    withdraw_trx_id = int(input("  >> Withdrawal Transaction ID : "))

    print("\nTrying to Insert Record into DB:")
    for _id, _type in zip([deposit_trx_id, withdraw_trx_id], ["_deposit", "_withdraw"]):
        try:
            _ = execute(statement, engine = APP_ENGINE, params = (_id, srcAccountID, dstAccountID, _type))
        except Exception as err:
            print(f"Failed for Record `{(_id, srcAccountID, dstAccountID, _type)}`")
            print(f"  >> ERROR: {err}")

    print("  >> Completed Data Insert.")
    return True


def mapRDAccount(srcAccountID : str, dstAccountID : str) -> bool:
    _buf = int(input("  >> Start Index of Installment ID [1]   : ") or "0")
    _ids = input("  >> Installment Transaction ID(s) [csv] : ").split(",")

    installment_trx_ids = list(map(int, _ids))
    withdraw_trx_id = input("  >> Withdrawal Transaction ID           : ")

    print("\nTrying to Insert Record into DB:")
    for idx, installement_id in enumerate(installment_trx_ids):
        _type = f"_installment_{idx + _buf + 1}"

        try:
            _ = execute(statement, engine = APP_ENGINE, params = (installement_id, srcAccountID, dstAccountID, _type))
        except Exception as err:
            print(f"Failed for Record `{(installement_id, srcAccountID, dstAccountID, _type)}`")
            print(f"  >> ERROR: {err}")

    _type = "_withdraw"
    try:
        _ = execute(statement, engine = APP_ENGINE, params = (withdraw_trx_id, srcAccountID, dstAccountID, _type))
    except Exception as err:
        print(f"Failed for Record `{(installement_id, srcAccountID, dstAccountID, _type)}`")
        print(f"  >> ERROR: {err}")

    print("  >> Completed Data Insert.")
    return True
