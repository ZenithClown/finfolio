# -*- encoding: utf-8 -*-

from .. import db

class RolesType(db.Model):
    """Use the Model to Establish a Connection to DB"""

    __tablename__ = "RolesType"

    RoleID   = db.Column(db.String(64), primary_key = True, nullable = False)
    RoleName = db.Column(db.String(16), nullable = False)


class AccountType(db.Model):
    """Use the Model to Establish a Connection to DB"""

    __tablename__ = "AccountType"

    ACTypeID   = db.Column(db.String(64), primary_key = True, nullable = False)
    ACTypeName = db.Column(db.String(16), nullable = False)
