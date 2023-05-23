# -*- encoding: utf-8 -*-

"""
ENUM Defination of Account Types

Account types are static, and keeps track of the number of types of
account that can be created and tracked via this application.
"""

from app.main.models.static._base_enum import ExtendedEnum

class AccountTypes(ExtendedEnum):
    C = "Cash in Hand"
    CA = "CREDIT Cards Account"
    DEMAT = "Cash in DEMAT Account excluding MF/SIP"
    EPFO = "Employee's Provident Fund Organization"
    FD = "Fixed Deposit Account"
    L = "Loan (Personal, Home, etc.) Accounts"
    MF = "Mutual Funds/SIP"
    PPF = "Personal Providend Fund"
    RD = "Recurring Deposit Account"
    SA = "Savings/DEBIT/ATM Cards Account"
    VPF = "Voluntary Provident Fund"
    W = "Wallet Accounts"
