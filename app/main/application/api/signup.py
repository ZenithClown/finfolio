# -*- encoding: utf-8 -*-

"""
An API Endpoint for Users Registration/SignUp

An important role in user management system is to add a new user into
the database. The API is thus defined to create a new user.
"""

from app.main.application._base_resource import BaseResource
from app.main.repository.interface.users import UsersTableInterface

class SignUp(BaseResource):
    """
    SignUp/Registration Request Handler for UMS Application

    A list of endpoints is available for a new user registrations.
    Currently, the system does not consider an user role, however
    with a later release this functionality may be added.
    """

    def __init__(self):
        super().__init__()

        # ! `required = <bool>` directly correlates with the database model
        # ! have to additionally send `location = "form"` to parse incoming arguments
        self.req_parser.add_argument(
            "username",
            type = str, required = True, location = "form",
            help = "An unique username is required for user registration."
        )
        self.req_parser.add_argument(
            "password",
            type = str, required = True, location = "form",
            help = "A password is required for registration. TODO implement password rules."
        )

        # TODO write additional help documentation for the below attributes
        self.req_parser.add_argument("first_name", type = str, required = True, location = "form")
        self.req_parser.add_argument("middle_name", type = str, required = False, location = "form")
        self.req_parser.add_argument("family_name", type = str, required = True, location = "form")
        self.req_parser.add_argument("email_id", type = str, required = True, location = "form")
        self.req_parser.add_argument("mobile_number", type = int, required = True, location = "form")

        # database access repository/interfaces modules
        self.users_tbl_interface = UsersTableInterface()

    
    def post(self):
        err, msg_desc, success = self.users_tbl_interface.post_user(**self.args)
        return self.formatter.post(code = 200 if success else 404, err = err, msg_desc = msg_desc)
