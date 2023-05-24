# -*- encoding: utf-8 -*-

"""
An API Endpoint for Users Registration/SignUp

An important role in user management system is to add a new user into
the database. The API is thus defined to create a new user.
"""

import datetime as dt

from app.main.application._base_resource import BaseResource
from app.main.repository.interface.accounts import AccountsTableInterface


class NewAccount(BaseResource):
    def __init__(self):
        super().__init__()

        # ! `required = <bool>` directly correlates with the database model
        # ! have to additionally send `location = "form"` to parse incoming arguments
        self.req_parser.add_argument(
            "account_number",
            type = int, required = True, location = "form",
            help = "Unique account number, typically provided by the bank/financial institute."
        )
        self.req_parser.add_argument(
            "username",
            type = str, required = True, location = "form",
            help = "Username against which the account is to be mapped."
        )

        # TODO write additional help documentation for the below attributes
        self.req_parser.add_argument("account_type", type = str, required = True, location = "form")
        self.req_parser.add_argument("account_name", type = str, required = False, location = "form")
        self.req_parser.add_argument("opening_date", type = lambda x : dt.datetime.strptime(x, "%d-%m-%Y").date(), required = True, location = "form")
        self.req_parser.add_argument("closing_date", type = lambda x : dt.datetime.strptime(x, "%d-%m-%Y").date(), required = False, location = "form")

        # database access repository/interfaces modules
        self.accounts_tbl_interface = AccountsTableInterface()
    

    def post(self):
        # ! WRONG IMPLEMENTATION - same variable is overwritten
        # TODO Fix the same variable name, and possibly create a loop to parse data
        err, msg_desc, success = self.accounts_tbl_interface.create_new_account(**self.args)

        return self.formatter.post(code = 200 if success else 404, err = err, msg_desc = msg_desc)
