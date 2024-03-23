# -*- encoding: utf-8 -*-

"""Extended Account Informations"""

from finfolio.main import db

class DBTAccount(db.Model):
    """Debit Account(s) Extended Information"""
    
    __tablename__ = "ams.extDBTAccount"

    _id = db.Column(db.Integer, primary_key = True, autoincrement = True)

    # ? the account id is referenced and is a foreign key
    # ? not maintaining a primary key relationship for easier join
    account_id = db.Column(
        db.String(32), db.ForeignKey("ams.mwAccountProperty.account_id"),
        unique = True, nullable = False,
    )

    cif  = db.Column(db.String(64)) # customer identification file number
    ifsc = db.Column(db.String(64)) # related to a savings/current account

    # additionally, a debit account can have multiple owner this
    # is addressed by keeping a field for "secondary holder" while
    # in case of more than 2 holders, holders can be added into
    # the "tertiary and others" holder field, csv expected
    secondary_holder     = db.Column(db.String(32)) # ? get from `ums.?` username
    tertiary_plus_holder = db.Column(db.String(256)) # ! csv values expected, `.split()`

    # optionally add/maintain nominee informations
    nominee_name = db.Column(db.String(32)) # ? can we maintain this from the `ums.?`\


class CDTAccount(db.Model):
    """Credit Account(s) Extended Information"""
    
    __tablename__ = "ams.extCDTAccount"

    _id = db.Column(db.Integer, primary_key = True, autoincrement = True)

    # ? the account id is referenced and is a foreign key
    # ? not maintaining a primary key relationship for easier join
    account_id = db.Column(
        db.String(32), db.ForeignKey("ams.mwAccountProperty.account_id"),
        unique = True, nullable = False,
    )

    # typically a credit card has the following additional attributes
    # TODO: have the provision to record credit/cash revision dates
    cash_limit   = db.Column(db.Integer, nullable = False)
    credit_limit = db.Column(db.Integer, nullable = False)
    
    # ? statement is generated on a date, and due date is calculated
    statement_day  = db.Column(db.Integer) # CHECK(statement_day <= 31)
    statement_due_ = db.Column(db.Integer) # no. of days to clear dues


class TDAAccount(db.Model):
    """Credit Account(s) Extended Information"""
    
    __tablename__ = "ams.extTDAAccount"

    _id = db.Column(db.Integer, primary_key = True, autoincrement = True)

    # ? the account id is referenced and is a foreign key
    # ? not maintaining a primary key relationship for easier join
    account_id = db.Column(
        db.String(32), db.ForeignKey("ams.mwAccountProperty.account_id"),
        unique = True, nullable = False,
    )

    # ? term accounts are genrally associated with a debit account
    # this field can be used internally to auto-map in ext-transactions
    debit_account = db.Column(
        db.String(32), db.ForeignKey("ams.mwAccountProperty.account_id"),
        nullable = False,
    )

    # interest rate mentioned at the time of opening the account
    # difference with actual may be useful on premature/auto-renewal
    interest_rate = db.Column(db.Float(5)) # CHECK(interest_rate BETWEEN 0 AND 1),

    # optional:: this are for future/admin references and validations
    operation_mode = db.Column(db.String(32)) # ? single/recurring/others
    scheme_details = db.Column(db.String(32)) # ? can be name/references for admin

    # optional:: maturity instructions are maintained, but no master table
    # only for admin/owner view or understanding, may add additional functionalities
    maturity_details = db.Column(db.String(32)) # ? repay principal and interest/etc.

    # admin:: remarks is created/updated by admin, can be used as goal settings
    td_remarks = db.Column(db.String(32)) # example: my-super computer
