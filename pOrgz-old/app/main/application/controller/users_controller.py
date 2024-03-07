# -*- encoding: utf-8 -*-

from flask import request

from .._base_resource import BaseResource
from ...repository import *
from ...repository.interface import *

class UserMasterController(BaseResource):
    """Master Controller for UserMaster"""

    def __init__(self):
        super().__init__()

        self.req_parser.add_argument("UUID", type = str, required = False)
        self.req_parser.add_argument("email", type = str, required = False)
        self.req_parser.add_argument("username", type = str, required = False)
        self.req_parser.add_argument("RoleID", type = str, required = False)

        # repository controller objects
        self.user_master_repository = UserMasterRepository()


    def get(self):
        try:
            if self.args["UUID"]:
                records = self.user_master_repository.get_by_id(UUID = UUID)
            elif self.args["email"]:
                records = self.user_master_repository.get_by_email(email = email)
            elif self.args["username"]:
                records = self.user_master_repository.get_by_uname(username = username)
            else:
                records = self.user_master_repository.get_all()

            return self.formatter.get(records)
        except AttributeError as err:
            return self.formatter.get([], err, 204, "Value not Present")
