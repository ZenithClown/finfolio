# -*- encoding: utf-8 -*-

"""
Interface for `UsersTable` SQL ORM Queries

List of methods available for `users` table under `models/users.py`
that can be accessed by other methods. Typically, this is accessed by
the admin interface section.
"""

from app.main import db
from app.main.models import * # noqa: F401, F403


class UsersTableInterface:
    # ! this code is currently not optimized
    # all the interfaces are added into one function
    get_all = lambda self : [row.__to_dict__() for row in UsersTable.query.all()]
