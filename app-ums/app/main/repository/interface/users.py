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
    # ! this code is currently not optimized
    # all the interfaces are added into one function
    get_all = lambda self : [row.__to_dict__() for row in UsersTable.query.all()]

    def get_param_by_username(self, username : str, param : str or list = "all") -> dict:
        """
        GET a Parameter or All Attributes based on Username

        A query is defined to get a single attribute like "password"
        from the `users` tables based on `username`. However, all the
        parameters can be obtained using `param == all` keyword.
        """

        error_ = dict()
        try:
            result = UsersTable.query.filter_by(username = username).first().__to_dict__()
            error_["GET.USERNAME"] = {"status" : "passed", "message" : None}
        except AttributeError:
            result = None
            error_["GET.USERNAME"] = {"status" : "failed", "message" : "username does not exists"}

        if type(param) == str:
            if param != "all":
                param = ["username", param] 
            else:
                pass # return all
        else:
            # list of parameters is required
            param =  list(set(["username"] + list(param)))

        try:
            result = {k : result[k] for k in param}
            error_["GET.PARAMETERS"] = {"status" : "passed", "message" : None}
        except Exception as e:
            result = dict()
            error_["GET.PARAMETERS"] = {"status" : "failed", "message" : str(e)}

        return result, error_

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
