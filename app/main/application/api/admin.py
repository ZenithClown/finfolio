# -*- encoding: utf-8 -*-

"""
A Set of Administration APIs for UMS

A user may have some "ADMIN" rights, and thus they have higher
privileges to query the database - like getting the number of total
users in the database, or getting details of a user based on
username.
"""

from app.main.application._base_resource import BaseResource
from app.main.repository.interface import * # noqa: F401, F403

class AdminAPI(BaseResource):
    """
    A List of ADMIN API for Controlling & Development

    A set of functionalities only available to ADMIN level users.
    The roles category is not yet planned for initial release,
    however the APIs are exposed to provide high-level information
    and testing purposes.

    ? signup/registration request is also handled using this api
    TODO break functionalities into differnt controllers
    """

    def __init__(self):
        super().__init__()

        # ! `AdminAPI` always accepts `username` and `password` for authentication
        self.req_parser.add_argument("username", type = str, required = True)
        self.req_parser.add_argument("password", type = str, required = True)

        # additionally, aacept different arguments for users management
        self.req_parser.add_argument("first_name", type = str, required = False)
        self.req_parser.add_argument("middle_name", type = str, required = False)
        self.req_parser.add_argument("family_name", type = str, required = False)
        self.req_parser.add_argument("email_id", type = str, required = False)
        self.req_parser.add_argument("mobile_number", type = int, required = False)

        # database access repository/interfaces modules
        self.users_tbl_interface = UsersTableInterface()

    def get(self):
        return self.formatter.get(self.users_tbl_interface.get_all(), code = 200)
