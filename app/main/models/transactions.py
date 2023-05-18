# -*- encoding: utf-8 -*-

"""
ORM Definations for Transactions

List of all transactions are defined here. Since a transactional
table, this table may require indexing in future for optimization.

TODO: optimize table, data indexing
"""

import datetime as dt
import sqlalchemy as sa

from app.main import db
from app.main.models.static import TransactionTypes

class TransactionsTable(db.Model):
    __tablename__ = "transactions"

    _id = db.Column(sa.Integer, autoincrement = True, primary_key = True)
    account_id = db.Column(sa.UUID(as_uuid = True), db.ForeignKey('accounts.account_id'), nullable = False)

    transaction_type = db.Column(sa.Enum(TransactionTypes), nullable = False)
    transaction_amount = db.Column(sa.Float(precision = 2), nullable = False)

    # this stores the record datetime information
    created_at = db.Column(sa.DateTime, default = dt.datetime.now())
    updated_at = db.Column(sa.DateTime, onupdate = dt.datetime.now())
