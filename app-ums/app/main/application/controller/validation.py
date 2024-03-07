# -*- encoding: utf-8 -*-

"""
Validate Users/Admins based on their Credentials

Queries like password update, certain value get commands are secured
using `request.authorization.*` commands. The authorization parameter
can be send additionally (from postman) under the "Authorization"
menu.

! DISCLAIMER: Currently "Basic Auth" is set for authentication.
However, advanced can be setup using the same structure. More details
at: https://go.pstmn.io/docs-auth (postman documentations).
"""

from flask import request
from flask import redirect

from app.utils import validate_password

class ValidationController(object):
    """
    Validation Controller for Authentication Controlling

    The class is defined which takes in additional arguments, and
    thus exposes additional functionalities to child classes.
    """

    def __init__(self) -> None:
        self.__auth_username__ = request.authorization.username
        self.__auth_password__ = request.authorization.password
    

    def validate(self):
        # get current password for `__auth_username__`
        _current_password = None
        _is_valid_password = validate_password(self.__auth_password__, _current_password)

        return redirect("/401") if not _is_valid_password else _is_valid_password
