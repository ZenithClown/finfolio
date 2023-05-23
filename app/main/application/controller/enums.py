# -*- encoding: utf-8 -*-

"""
A Controller for Providing Static Informations

The API is configured with certain static values, specifically values
like `enum` for account types, and transaction types. All these are
available for data input/control for other api endpoints.
"""

from flask import request
from flask import redirect

from app.main.application._base_resource import BaseResource
from app.main.models.static import (
    AccountTypes,
    TransactionTypes
)


class AccountController(BaseResource):

    def __init__(self):
        super().__init__()


    def get(self):
        if request.endpoint == "accounts/names":
            data = AccountTypes.names()
        elif request.endpoint == "accounts/values":
            data = AccountTypes.values()
        elif request.endpoint == "accounts/default":
            data = AccountTypes.dict()
        else:
            return redirect("/404")

        return self.formatter.get(data)


class TransactionController(BaseResource):

    def __init__(self):
        super().__init__()


    def get(self):
        if request.endpoint == "transactions/names":
            data = TransactionTypes.names()
        elif request.endpoint == "transactions/values":
            data = TransactionTypes.values()
        elif request.endpoint == "transactions/default":
            data = TransactionTypes.dict()
        else:
            return redirect("/404")

        return self.formatter.get(data)
