# -*- encoding: utf-8 -*-

"""
Defination of Master Table(s) for Account Management System (AMS)

The account management system constitues of the following primary
and/or master tables to efficiently manage maximum possible
attributes of an individual/family.

Copywright © [2023] pOrgz <https://github.com/pOrgz-dev>
"""

import datetime as dt

from finfolio.main import db


class MWAccountType(db.Model):
    """
    Account Types Master Table, Sub-Catorized in MWSubAccountType

    The application has the capability of storing information of
    various types of accounts, like DEBIT/CREDIT/DEMAT/etc. and each
    type of account has seperate attributes associated. To facilitate
    this, the master tables provide a master key to map different
    available attributes of an account with any of the different
    attributes.
    """

    __tablename__ = "ams.mwAccountType"

    account_type_id   = db.Column(db.String(3), primary_key = True)
    account_type_name = db.Column(db.String(32), unique = True, nullable = False)
    account_type_desc = db.Column(db.String(64)) # ? optional/long, descriptive information

    subtypes = db.relationship("MWSubAccountType", backref = "primary")
    accounts = db.relationship("MWAccountProperty", backref = "accounts")


class MWSubAccountType(db.Model):
    """
    A Primary Account Type is Sub-Classified into One/More Sub-Types

    To distinguish between various types of account (for example, a
    term/time deposit can be fixed or recurring) a sub-account table
    is defined that can be used to track the sub-account types. The
    same is mapped in the account property table.
    """
    
    __tablename__ = "ams.mwSubAccountType"

    account_subtype_id   = db.Column(db.String(3), primary_key = True)
    account_type_id      = db.Column(db.String(3), db.ForeignKey("ams.mwAccountType.account_type_id"), nullable = False)
    account_subtype_name = db.Column(db.String(32), unique = True, nullable = False)

    subaccounts = db.relationship("MWAccountProperty", backref = "subaccounts")


class MWAccountProperty(db.Model):
    """
    Master Table that holds all the Basic Information for any Account

    Any of the defined account type has certain attributes associated
    with it, for example account number, name etc. being the basic
    required information. In addition, certain special attributes
    like "IFSC", "POINT_CONVERSION" etc. can be associated with
    account types.
    
    The extended table information are stored under `ext_accounts.py`
    informations. The following extended tables are added for
    capturing all the attributes related to an account holder:

        * extDebitAccount : Holds information related to a debit
            account, typically savings bank branch details, nominee
            details etc.
        * extCreditAccount : Holds credit account details like
            payment cycles, credit limits etc.
        * extTermDepositAccount : Term/Time deposit account typically
            are created for a time and is linked to a "DEBIT" type of
            account and the deposit/withdrawal are associated in the
            parent account. This table holds information like the
            linked debit account, interest percentage, scheme details
            among various other features.
    """
    
    __tablename__ = "ams.mwAccountProperty"

    account_id     = db.Column(db.String(32), primary_key = True) # UUID()
    account_number = db.Column(db.Integer, unique = True, nullable = False)
    account_name   = db.Column(db.String(64), unique = True, nullable = False)
    account_owner  = db.Column(db.String(32), db.ForeignKey("ums.UserAccounts.username"), nullable = False)

    # ? refer and collate account and sub-types from master table, like:
    account_type_id = db.Column(db.String(3), db.ForeignKey("ams.mwAccountType.account_type_id"), nullable = False)
    account_subtype_id = db.Column(db.String(3), db.ForeignKey("ams.mwSubAccountType.account_subtype_id"))

    # ? account opening and closing date informations
    account_opened_on = db.Column(db.Date, nullable = False)
    account_closed_on = db.Column(db.Date) # ? if null, account is active/operational

    # ? we may not have all the transactions, thus we can set an opening balance
    account_openeing_balance  = db.Column(db.Float(2), default = 0, nullable = False)
    openeing_balance_recorded = db.Column(db.Date, default = account_opened_on, nullable = False)

    # ? we may add created and updated on information, for underatanding
    # ! not to confuse with account opening date, but this is when the record created
    created_at = db.Column(db.DateTime, nullable = False, default = str(dt.datetime.now()))
    updated_on = db.Column(db.DateTime, onupdate = str(dt.datetime.now()))
