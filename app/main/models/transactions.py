# -*- encoding: utf-8 -*-

from .. import db
from ._base_model import ModelSchema
from .users import AccountDetails

class UserTransactions(db.Model, ModelSchema):
    """Use the Model to Establish a Connection to DB"""

    __tablename__ = "UserTransactions"

    ID = db.Column(db.Integer, primary_key = True, autoincrement = True, nullable = False)
    TransactionDate  = db.Column(db.DateTime, nullable = False)
    TransactionDetails = db.Column(db.String(1024), nullable = False)
    TransactionType = db.Column(db.String(8), nullable = False)
    TransactionAmount = db.Column(db.Float(precision = 2), nullable = False)

    # foreign key(s)
    AccountID = db.Column(db.Integer, db.ForeignKey(AccountDetails.AccountID), nullable = False)


    # def __init__(self):
    #     ModelSchema().__init__()
