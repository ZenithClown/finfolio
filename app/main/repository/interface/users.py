# -*- encoding: utf-8 -*-

"""
Interface for `UsersTable` SQL ORM Queries

List of methods available for `users` table under `models/users.py`
that can be accessed by other methods. Typically, this is accessed by
the admin interface section.
"""

from app.main import db
from app.main.models.users import UsersTable


class UsersTableInterface:
    def post_user(
            self,
            username : str,
            password : str,
            
            # accept the name of the user as in database
            first_name : str,
            family_name : str,

            # accept email/mobile
            email_id : str,
            mobile_number : int,

            # additional arguments with their defaults
            middle_name : str = None
    ):
        """
        Function to Register a New User into System

        A typical function for users' registration and signup system.
        The function accepts all the arguments/keyword arguments and
        create a new user under `users` table.
        """

        record = UsersTable(
            username = username,
            password = password,
            first_name = first_name,
            middle_name = middle_name,
            family_name = family_name,
            email_id = email_id,
            mobile_number = mobile_number
        )

        try:
            db.session.add(record)
            db.session.commit()
            return None, None, True # error, message, success
        except Exception as err:
            return err, "Failed to Create a New User", False
