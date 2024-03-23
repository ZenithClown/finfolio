# -*- encoding: utf-8 -*-

"""User Roles & Privileges Defination"""

from finfolio.main import db

class UserRoles(db.Model):
    """
    Defination of User Roles & Privileges

    On creating the database, the first user is assigned the role of
    `ROOT` while all other users' may operate as an `USER` role.
    However, for more control and elevated access, different levels
    of access may be defined.
    """

    __tablename__ = "ums.UserRoles"

    role_id   = db.Column(db.Integer, primary_key = True, autoincrement = True)
    role_name = db.Column(db.String(4), unique = True, nullable = False)
    role_desc = db.Column(db.String(64)) # optional description column

    # ? maintain a one-to-many relationship with the users table
    privileges = db.relationship("UserAccounts", backref = "owner")
