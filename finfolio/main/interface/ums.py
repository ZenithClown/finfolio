# -*- encoding: utf-8 -*-

"""
User Management System (UMS) Master Inteface

The master interface for all communications, intercations for the
UMS module. The ums module provides all details related to the users
and accounts, with roles privileges.

Copywright © [2023] pOrgz <https://github.com/pOrgz-dev>
"""

from finfolio.main.config import BaseInterface
from finfolio.main.models.ums import * # noqa: F401, F403 # pyright: ignore[reportMissingImports]

class UMSInterface(BaseInterface):

    get_all  = lambda self : [row.__to_dict__() for row in UserAccounts.query.order_by(UserAccounts.username.asc()).all()]
    get_root = lambda self : UserAccounts.query.filter(UserAccounts.roles == 1).first().__to_dict__() # get root user details

    def get_user(self, username : str) -> dict:
        """
        Get Details of a User by Primary Key Field

        The primary key is maintained as `username` while most of the
        other fields are nullable, or for internal developer use-cases.

        :type  username: str
        :param username: Username, which is the primary key in the
            database, and returns only one single record.
        """

        content = UserAccounts.query.filter(UserAccounts.username == username).first()

        if content:
            try:
                content = content.__to_dict__()
            except Exception as err:
                content = None
                self.error = err
                self.message = "InternalError: Something Went Wrong!"
        else:
            self.error = 204
            self.message = f"{username} is not available."

        return content, self.error, self.message
