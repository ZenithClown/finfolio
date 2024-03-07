# -*- encoding: utf-8 -*-

"""
Interface for `UsersTable` SQL ORM Queries

List of methods available for `users` table under `models/users.py`
that can be accessed by other methods. Typically, this is accessed by
the admin interface section.
"""

import datetime as dt

from app.main import db
from app.main.models.accounts import AccountsTable


class AccountsTableInterface:
    def create_new_account(
            self,
            account_number : int,
            username : str,
            
            # accept the name of the user as in database
            account_type : str,
            account_name : str,
            opening_date : dt.date,
            closing_date : dt.date = None
    ):
        """
        Function to Register a New User into System

        A typical function for users' registration and signup system.
        The function accepts all the arguments/keyword arguments and
        create a new user under `users` table.
        """

        record = AccountsTable(
            account_number = account_number,
            username = username,
            account_type = account_type,
            account_name = account_name,
            opening_date = opening_date,
            closing_date = closing_date
        )

        try:
            db.session.add(record)
            db.session.commit()
            return None, None, True # error, message, success
        except Exception as err:
            return err, "Failed to Create a New User", False
