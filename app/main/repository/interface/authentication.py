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
    def get_by_username(self, username : str):
        """
        GET Authentication and Verification Status for Username

        Provided a username, the interface function queries database
        to fetch data and provide output.
        """

        error_ = None
        try:
            result = UserAuthentication.query.filter_by(username = username).first().__to_dict__()
        except AttributeError as err:
            result = None
            error_ = str(err)

        return result, error_

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
    def get_by_username(self, username : str):
        """
        GET Last Password Details based on Username

        Provided a username, the interface function queries database
        to fetch data and provide output.
        """

        error_ = None
        try:
            result = LastPassword.query.filter_by(username = username).first().__to_dict__()
        except AttributeError as err:
            result = None
            error_ = str(err)

        return result, error_


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
