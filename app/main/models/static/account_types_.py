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
    DEPOSIT = "Any Other Type of Money Deposit Account"
    EPFO = "Employee's Provident Fund Organization"
    FD = "Fixed Deposit Account"
    L = "Loan (Personal, Home, etc.) Accounts"
    MF = "Mutual Funds/SIP"
    MIS = "Monhly Income Scheme"
    NPS = "National Pension Scheme"
    PPF = "Personal Providend Fund"
    RD = "Recurring Deposit Account"
    SA = "Savings/DEBIT/ATM Cards Account"
    VPF = "Voluntary Provident Fund"
    W = "Wallet Accounts"
