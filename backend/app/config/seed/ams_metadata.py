# -*- encoding: utf-8 -*-

"""
Initial Seed Data for AMS METADATA Tables

The seed data is defined under a general function and can be
executed from the management file on initialization.
"""

# from backend.app.api.base import model
from backend.app.api.models import * # noqa: F401, F403 # pyright: ignore[reportMissingImports]

def account_types() -> list:
    """
    Initial Data for `ams.META_ACCOUNT_TYPE` Table
    """

    data = {
        "DBT" : dict(name = "DEBIT", desc = "Use this to store transactions from savings/current account."),
        "CDT" : dict(name = "CREDIT", desc = "Use this to store transactions related to loans, credit cards, etc."),
        "WLT" : dict(name = "WALLET", desc = "A type of account for storing gift cards, points, cashbacks, rewards etc. informations."),
        "DMT" : dict(name = "DEMAT", desc = "A typical table for holding information related to share market, populate equity, f&o transactions."),
        "RET" : dict(name = "RETIREMENT", desc = "An account dedicated for savings for retirements, like PPF, VPF, NPS, etc."),
        "INS" : dict(name = "INSURANCE", desc = "Use this to track investments/redemptions into insurance."),
        "MFA" : dict(name = "MUTUALFUND", desc = "A typical account for management of mutual funds and SIP/STP informations."),
        "TDA" : dict(name = "TDACCOUNT", desc = "Term deposit accounts like FD/RD/etc. can be tracked here.")
    }
    
    return [
        META_ACCOUNT_TYPE(
            account_type = key,
            account_type_name = data[key]["name"],
            account_type_desc = data[key]["desc"]
        ) for key in data.keys()
    ]


def account_subtypes() -> list:
    """
    Initial Data for `ams.META_SUBACCOUNT_TYPE` Table
    """

    data = {
        "FDS" : dict(acc_type = "TDA", name = "Fixed Deposit Account", desc = None),
        "RDS" : dict(acc_type = "TDA", name = "Recurring Deposit Account", desc = None),
        "SVN" : dict(acc_type = "DBT", name = "Saving Account", desc = None),
        "SAL" : dict(acc_type = "DBT", name = "Salary Account", desc = None),
        "CUR" : dict(acc_type = "DBT", name = "Current Account", desc = None),
        "PPF" : dict(acc_type = "RET", name = "Personal Providend Funds Account", desc = None),
        "VPF" : dict(acc_type = "RET", name = "Voluntary Providend Funds Account", desc = None),
        "NPS" : dict(acc_type = "RET", name = "National Pension Schemes Account", desc = None),
        "LND" : dict(acc_type = "CDT", name = "Personal Lending Account", desc = "Amount lended to a person based on terms and conditions."),
        "BRW" : dict(acc_type = "CDT", name = "Personal Borrowed Account", desc = "Amount borrwed from a person based on terms and conditions.")
    }
    
    return [
        META_SUBACCOUNT_TYPE(
            account_subtype = key,
            account_type = data[key]["acc_type"],
            account_subtype_name = data[key]["name"],
            account_subtype_desc = data[key]["desc"]
        ) for key in data.keys()
    ]
