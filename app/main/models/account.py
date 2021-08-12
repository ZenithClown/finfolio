# -*- encoding: utf-8 -*-

from .. import db

class AccountDetails(db.Model):
    """Holds Details of User Accounts"""

    __tablename__ = "AccountDetails"

    AccountNumber     = db.Column(db.BigInteger, primary_key = True, nullable = False)
    AccountHolderName = db.Column(db.String(45), nullable = False)
    AccountType       = db.Column(db.String(45), nullable = False)
    IFSCode           = db.Column(db.String(45), nullable = False)
    CIF_Number        = db.Column(db.String(45), nullable = False)
    Account_OpenDate  = db.Column(db.Date, nullable = False)
    Account_CloseData = db.Column(db.Date, nullable = True)
    Email_ID          = db.Column(db.String(45), nullable = True)
    MobileNumber      = db.Column(db.BigInteger, nullable = False)
