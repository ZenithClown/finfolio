# -*- encoding: utf-8 -*-

"""
ORM Defination for User Accounts

A user can have multiple accounts, while multiple users can use the
same database file to track their expenses. The accounts table gives
one unique identity (`account_id`) based on each username, account
combination which may be referenced in any transactional tables.

TODO: join account, other types of account, one time account etc.
"""

import sqlalchemy as sa
from uuid import uuid4 as UUID

from app.main import db
from app.main.models.static import AccountTypes

class AccountsTable(db.Model):
    __tablename__ = "accounts"

    # ! https://stackoverflow.com/a/49398042/6623589 don't call the function itself
    account_id = db.Column(sa.UUID(as_uuid = True), default = UUID, primary_key = True)
    account_number = db.Column(sa.Integer, nullable = False, unique = True)
    username = db.Column(sa.String(25), db.ForeignKey('users.username'), unique = False, nullable = False)
    account_type = db.Column(sa.Enum(AccountTypes), nullable = False)

    # each account has an opening and closing date
    opening_date = db.Column(sa.Date, nullable = False)
    closing_date = db.Column(sa.Date, nullable = True)
