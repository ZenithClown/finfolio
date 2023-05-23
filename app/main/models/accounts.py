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

    # ! https://stackoverflow.com/q/183042/6623589 using UUID as default in different databases
    account_id = db.Column(sa.String(36), default = lambda : str(UUID()).upper(), primary_key = True)
    account_number = db.Column(sa.BigInteger, nullable = False, unique = True)
    username = db.Column(sa.String(25), db.ForeignKey('users.username'), unique = False, nullable = False)
    account_type = db.Column(sa.Enum(AccountTypes), nullable = False)
    account_name = db.Column(sa.String(36), nullable = True)

    # each account has an opening and closing date
    opening_date = db.Column(sa.Date, nullable = False)
    closing_date = db.Column(sa.Date, nullable = True)
