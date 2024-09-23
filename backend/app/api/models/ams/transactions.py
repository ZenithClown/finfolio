# -*- encoding: utf-8 -*-

"""
The Core Defination & Table Schema for Transations

All the transactions related to an user's accounts are stored in a
transaction table. The table structure, constraints and indexations
are as defined in the table.
"""

from sqlalchemy import Column, Integer, VARCHAR, ForeignKey, Date, Float

from backend.app.api.base import TimeStampedModel

class AccountTransactions(TimeStampedModel):
    """
    The Base Class of Account Transactions

    The class holds informations which are similar across all the
    types of transaction tables. Primarilly, the transactions tables
    are:
        - debit type account's transactions table,
        - credit type account's transactions table, and
        - depositories type (example demat account) account's details

    Each record is mapped to an user's account which is the default
    foreign key and is indexed for faster table scan.
    """

    __abstract__ = True

    # all the transactions table has a primary key `_id` which
    # does not have any physical significance, but can be referenced
    _id = Column(Integer, primary_key = True, autoincrement = True)

    # ? the primary foreign key and indexation of the data on account
    account_id = Column(VARCHAR(32), ForeignKey("ams.AccountPrimaryDetails.account_id", ondelete = "CASCADE"), nullable = False)

    # ? transactions are generally on a date level, and
    # ? transactions have a type (credit/debit) based on account type
    trx_date = Column(Date, nullable = False)
    trx_type = Column(VARCHAR(7), nullable = False)

    # ? the transactions amount is default to all accounts
    # based on type of account this value is either added/subtracted
    ammount = Column(Float(2), nullable = False)

    # the bank statement always has a transaction description
    # however, due to uncleaned nature of the same two fields are created
    orig_description = Column(VARCHAR(max), nullable = False)
    drvd_description = Column(VARCHAR(max), nullable = False)

    # ! all the below fields are derieved fields by automation/user-defined
    # ? all of the derived column have a leading "_" and are nullable by default
    _trx_method = Column(VARCHAR(7)) # method of transaction - cash/card/etc.
    
    # the dual nature of any transaction is recorded by the debitor/creditor
    # this is tracked using the 
    