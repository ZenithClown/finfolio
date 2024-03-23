# -*- encoding: utf-8 -*-

"""
Transactions Table for Account Management System [AMS]

The main/core transactions table that holds all the transactions
information along with certain additional derived features (explained
on each line) is defined.

The transactions are maintained at "account type" level, this makes
it easier to segregate and understand primary, secondary and other
sources of income/expenditure. In addition, it is not practical to
group all transactions in a table as "DEBIT" account transactions are
very different from "DEMAT" account transactions, etc.

Copywright © [2023] pOrgz <https://github.com/pOrgz-dev>
"""

from sqlalchemy import func
from finfolio.main import db

class DBTTransactions(db.Model):
    """A Table to Record all Debit Account Transactions"""
    
    __tablename__ = "ams.DBTTransactions"

    # ? autoincrement = True should work for mysql/psql directly
    # https://stackoverflow.com/a/69822361/6623589
    __table_args__ = {"sqlite_autoincrement" : True}

    _id = db.Column(db.Integer, primary_key = True, autoincrement = True, server_default = db.FetchedValue())
    
    # all debit account transactions are linked to the account,
    # this back-ensures the relationships, account owner and nominee details
    account_id = db.Column(
        db.String(32), db.ForeignKey("ams.mwAccountProperty.account_id"),
        unique = True, nullable = False,
    )

    # ? most of the time transaction record is available at day level
    # each of the transaction has a type, amount and description
    trx_date   = db.Column(db.Date, nullable = False)
    trx_type   = db.Column(db.String(8), nullable = False) # DEPOSIT/WITHDRAW
    trx_amount = db.Column(db.Float(2), nullable = False)

    # ? the passbook provides a transaction description, which is mostly messy
    # to mitigate, and feature enginerring derived description is captured
    trx_desc = db.Column(db.String(512), nullable = False)
    trx_drvd = db.Column(db.String(512)) # allowed null, to handle later

    # ! all the below fields are derived, either by automation/user-defined
    # ? all of the derived column have a leading "_" for identification
    # ? all of the derived fields allow/defaults to NULL, unless explicit:
    # values are null since automation (ai/ml/heuristic) is in development
    _trx_method  = db.Column(db.String(7)) # ? NEFT/RTGS/IMPS/UPI/ATM/MANDATE
    _trx_account = db.Column(db.String(32), db.ForeignKey("ums.UserAccounts.username"))

    # ? all the transactions can be grouped, very useful for generating reports
    # primary:: primary type of transactions - bank/bills/rent/food/etc.
    # secondary:: (optional) additional description - interest from bank/amc/etc.
    _trx_pri_category = db.Column(db.String(16))
    _trx_sec_category = db.Column(db.String(16))

    created_at = db.Column(db.DateTime, nullable = False, server_default = func.current_timestamp())
    updated_on = db.Column(db.DateTime, server_onupdate = func.current_timestamp())
