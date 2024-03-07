# -*- encoding: utf-8 -*-

"""
Interface for User Roles and Roles Master

Interface to functions related to `models/roles.py` tables. The set
of queries typically does not require any authentication and is most
of the times called directly from the `application/api` section.
"""

from app.main import db
from app.main.models.roles import * # noqa: F401, F403
from app.main.repository.interface._base_interface import BaseInterface

class RolesMasterInterface(BaseInterface):
    """
    Roles Master Table Interface

    Typically, this table reports set of defined roles
    and only `get` operations are thus defined. Other set of commands
    may be defined as per requirement.
    """

    def __init__(self) -> None:
        super().__init__(RolesMaster)
