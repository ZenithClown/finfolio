# -*- encoding: utf-8 -*-

from .. import db

from .references import (
        RolesType,
        AccountType
    )

class UserMaster(db.Model):
    """Use the Model to Establish a Connection to DB"""

    __tablename__ = "UserMaster"

    UUID       = db.Column(db.String(64), primary_key = True, nullable = False)
    username   = db.Column(db.String(64), unique = True, nullable = False)
    FirstName  = db.Column(db.String(64), nullable = False)
    MiddleName = db.Column(db.String(64), nullable = True)
    LastName   = db.Column(db.String(64), nullable = False)
    email      = db.Column(db.String(256), unique = True, nullable = True)
    password   = db.Column(db.String(1024), nullable = False)
    mobile     = db.Column(db.String(16), nullable = True)

    # foreign key(s)
    RoleID = db.Column(db.String(64), db.ForeignKey(RolesType.RoleID), nullable = False)


class AccountDetails(db.Model):
    """Use the Model to Establish a Connection to DB"""

    __tablename__ = "AccountDetails"

    AccountID = db.Column(db.BigInteger, primary_key = True, nullable = False)
    IFSCCode  = db.Column(db.String(16), nullable = True)
    CIFNumber = db.Column(db.String(16), nullable = True)
    OpenDate  = db.Column(db.Date, nullable = False)
    CloseDate = db.Column(db.Date, nullable = True)

    # foreign key(s)
    UUID    = db.Column(db.String(64), db.ForeignKey(UserMaster.UUID), nullable = False)
    ACTypeID = db.Column(db.String(64), db.ForeignKey(AccountType.ACTypeID), nullable = False)
