# -*- encoding: utf-8 -*-

"""
User Management System (UMS) Master Inteface

The master interface for all communications, intercations for the
UMS module. The ums module provides all details related to the users
and accounts, with roles privileges.

Copywright © [2023] pOrgz <https://github.com/pOrgz-dev>
"""

from finfolio.main.models.ums import * # noqa: F401, F403 # pyright: ignore[reportMissingImports]

class UMSInterface:

    get_all  = lambda self : [row.__to_dict__() for row in UserAccounts.query.order_by(UserAccounts.username.asc()).all()]
    get_root = lambda self : UserAccounts.query.filter(UserAccounts.roles == 1).first().__to_dict__() # get root user details
