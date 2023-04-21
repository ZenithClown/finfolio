# -*- encoding: utf-8 -*-

"""
ORM Structure for Security/Authentication Information

The following defined tables are for users' authentication and
verification services. The `authentication` table stores information
like verified email, etc. while `history` table stores users'
historical information.
"""

import datetime as dt
import sqlalchemy as sa

from app.main import db

class UserAuthentication(db.Model):
    __tablename__ = "authentication"

    id_ = db.Column(sa.Integer, primary_key = True, auto_increment = True)
    username = db.Column(sa.String(25), db.ForeignKey('users.username', ondelete = "CASCADE"), nullable = False)

    # check details for `email_address`
    email_id_verified = db.Column(sa.BOOLEAN, default = False)
    email_id_verified_on = db.Column(sa.DateTime, nullable = True)

    # check details for `mobile_number`
    mobile_number_verified = db.Column(sa.BOOLEAN, default = False)
    mobile_number_verified_on = db.Column(sa.DateTime, nullable = True)

    # this stores the record datetime information
    # * since the record is created at the time of user registration, `created_at` is ignored
    updated_at = db.Column(sa.DateTime, onupdate = dt.datetime.now())


class LastPassword(db.Model):
    __tablename__ = "last_password"

    id_ = db.Column(sa.Integer, primary_key = True, auto_increment = True)
    username = db.Column(sa.String(25), db.ForeignKey('users.username', ondelete = "CASCADE"), nullable = False)

    # last password hash is stored, such that user does not repeat last password
    last_password_hash = db.Column(sa.String(1024))
    last_password_changed = db.Column(sa.DateTime, onupdate = dt.datetime.now())
