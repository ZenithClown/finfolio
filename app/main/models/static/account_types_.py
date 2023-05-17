# -*- encoding: utf-8 -*-

"""
ENUM Defination of Account Types

Account types are static, and keeps track of the number of types of
account that can be created and tracked via this application.
"""

import enum

class AccountTypes(enum.Enum):
    SAVINGS_ACCOUNT = "Savings/DEBIT Cards Account"
    CREDIT_ACCOUNT = "CREDIT Cards Account"
