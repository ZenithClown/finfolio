# -*- encoding: utf-8 -*-

"""
ENUM Defination of Account Types

Account types are static, and keeps track of the number of types of
account that can be created and tracked via this application.
"""

from app.main.models.static._base_enum import ExtendedEnum

class TransactionTypes(ExtendedEnum):
    D = "Amount Deposited"
    W = "Amount Withdrawn"
