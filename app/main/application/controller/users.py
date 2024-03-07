# -*- encoding: utf-8 -*-

"""
TODO Documentation
"""

from flask import request
from flask import redirect

from app.main.repository.interface.users import UsersTableInterface

from app.main.application._base_resource import BaseResource

class UsersTableController(BaseResource):
    def __init__(self):
        super().__init__()

        self.req_parser.add_argument(
            "username",
            type = str, required = True, location = "form",
            help = "An unique username is required for user registration."
        )

        # get params to filter values on
        self.req_parser.add_argument("params", type = str, required = False, location = "form")

        # database access repository/interfaces modules
        self.users_tbl_interface = UsersTableInterface()


    def __parse_params__(self) -> bool:
        params = self.args.get("params") or "all"
        params = params.split() # split by spaces

        if len(params) == 1:
            # only one parameter is received
            params = params[0]

        return params

    
    def get(self):
        if request.endpoint == "users/all":
            # ! should be called by `admin` only
            # * admin authentication is done via admin controller
            data, error = self.users_tbl_interface.get_all(), None
        else:
            # * get details of users based on username or fields
            data, error = self.users_tbl_interface.get_param_by_username(
                username = self.args["username"],
                param = self.__parse_params__()
            )
        
        # TODO format error, provide message description
        return self.formatter.get(data, err = error)
