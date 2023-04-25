# -*- encoding: utf-8 -*-

"""
Interface for "authentication" SQL ORM Queries

List of methods available for authentication(s) table under
`models/authentication.py` that can be accessed by other methods.
"""

import datetime as dt

from app.main import db
from app.main.models.authentication import * # noqa: F401, F403

class UserAuthenticationInterface:
    def post_record(
            self,
            username : str,

            # get verification details
            email_id_verified : bool = False,
            mobile_number_verified : bool = False
    ):
        """
        POST a Record in `authentication` Table
        """

        email_id_verified_on = dt.datetime.now() if email_id_verified else None
        mobile_number_verified_on = dt.datetime.now() if mobile_number_verified else None

        record = UserAuthentication(
            username = username,
            email_id_verified = email_id_verified,
            email_id_verified_on = email_id_verified_on,
            mobile_number_verified = mobile_number_verified,
            mobile_number_verified_on = mobile_number_verified_on
        )

        try:
            db.session.add(record)
            db.session.commit()
            return None, None, True # error, message, success
        except Exception as err:
            return err, "Failed to Create a New User", False


class LastPasswordInterface:
    def post_record(self, username : str, last_password_hash : str = None):
        """
        POST a Record in `last_password` Table
        """

        record = LastPassword(username = username, last_password_hash = last_password_hash)

        try:
            db.session.add(record)
            db.session.commit()
            return None, None, True # error, message, success
        except Exception as err:
            return err, "Failed to Create a New User", False
