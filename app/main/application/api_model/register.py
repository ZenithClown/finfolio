# -*- encoding: utf-8 -*-

from flask import request
from sqlalchemy.exc import (
        DataError,
        IntegrityError
    )
from werkzeug.exceptions import BadRequest

from .._base_resource import BaseResource
from ...repository import *
# from ...repository.interface import *

class OpenAccount(BaseResource):
    """API Model for Opening a New User Account"""

    def __init__(self):
        super().__init__()

        # self.set_args(
        #         args   = ["username", "FirstName", "MiddleName", "LastName"],
        #         params = {
        #             "MiddleName" : {
        #                 "required" : False
        #             }
        #         }
        #     )

        self.req_parser.add_argument("username", type = str, required = True) # does not work >, help = "username is required")
        self.req_parser.add_argument("FirstName", type = str, required = True) # does not work >, help = "FirstName is required")
        self.req_parser.add_argument("MiddleName", type = str, required = False)
        self.req_parser.add_argument("LastName", type = str, required = True) # does not work >, help = "LastName is required")
        self.req_parser.add_argument("email", type = str, required = True) # does not work >, help = "email is required")
        self.req_parser.add_argument("password", type = str, required = True) # does not work >, help = "password is required")
        # self.req_parser.add_argument("RoleType", type = str, required = True) # does not work >, help = "RoleType is required")
        self.req_parser.add_argument("AccountID", type = str, required = True) # does not work >, help = "AccountID is required")
        self.req_parser.add_argument("IFSCCode", type = str, required = True) # does not work >, help = "IFSCCode is required")
        self.req_parser.add_argument("CIFNumber", type = str, required = True) # does not work >, help = "CIFNumber is required")
        self.req_parser.add_argument("OpenDate", type = str, required = True) # does not work >, help = "OpenDate is required")
        self.req_parser.add_argument("AccountType", type = str, required = True) # does not work >, help = "AccountType is required")


    def post(self):

        if request.endpoint == "NEW_USER_ACCOUNT":
            try:
                newID = OpenAccountRepository().create_user_account(self.args)
                return self.formatter.post(msg = f"User Account ID {newID} Created")
            except BadRequest as err:
                return self.formatter.post(err, 400, "Some Arguments Missing")
            except DataError as err:
                return self.formatter.post(err.orig.args[1], 500, "Creating Account Failed")
            except IntegrityError as err:
                return self.formatter.post(err.orig.args[1], 409, "Creating Account Failed")
            except Exception as err:
                return self.formatter.post(err, 502, "Creating Account Failed")
