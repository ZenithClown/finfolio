# -*- encoding: utf-8 -*-

from flask import request

from .._base_resource import BaseResource
from ...repository import *
from ...repository.interface import *

class OpenAccount(BaseResource):
    """API Model for Opening a New User Account"""

    def __init__(self):
        super().__init__()

        self.req_parser.add_argument("username", type = str, required = True, help = "username is required")
        self.req_parser.add_argument("FirstName", type = str, required = True, help = "FirstName is required")
        self.req_parser.add_argument("MiddleName", type = str, required = False)
        self.req_parser.add_argument("LastName", type = str, required = True, help = "LastName is required")
        self.req_parser.add_argument("email", type = str, required = True, help = "email is required")
        self.req_parser.add_argument("password", type = str, required = True, help = "password is required")
        # self.req_parser.add_argument("RoleType", type = str, required = True, help = "RoleType is required")
        self.req_parser.add_argument("AccountID", type = str, required = True, help = "AccountID is required")
        self.req_parser.add_argument("IFSCCode", type = str, required = True, help = "IFSCCode is required")
        self.req_parser.add_argument("OpenDate", type = str, required = True, help = "OpenDate is required")
        self.req_parser.add_argument("AccountType", type = str, required = True, help = "AccountType is required")
