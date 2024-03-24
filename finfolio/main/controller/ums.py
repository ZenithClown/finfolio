# -*- encoding: utf-8 -*-

"""
Controller for User Management System (UMS) Module

The user management system is totally controlled using this controller
file, from GET/POST/UPDATE/DELETE operations.

Copywright © [2023] pOrgz <https://github.com/pOrgz-dev>
"""

from flask import request
from flask import redirect

from finfolio.main.config import BaseResource
from finfolio.main.interface import UMSInterface

class UserManagementSystemController(BaseResource):
    """UMS Master Controller"""

    def __init__(self) -> None:
        super().__init__()

        self.ums_interface = UMSInterface()
    

    def get(self):
        """GET Request for UMS Module"""

        data = None # no response, safe-keeping

        if request.endpoint == "ums/root-user":
            data = self.ums_interface.get_root()
        elif request.endpoint == "ums/default":
            data = self.ums_interface.get_all()

        return self.formatter.get(data)
