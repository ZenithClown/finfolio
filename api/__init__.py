# -*- encoding: utf-8 -*-

"""
A REST-API Model for the FinFolio-DB Usages

The REST-API is developed using `sqlalchemy.orm` concepts and is
currently under development.

WARN:: The `database` directory currently holds all the SQL statement
however, gradual transition is in progress for an API.
"""

import os

# ? necessary imports for a flask-api
from flask import Flask
from flask_bcrypt import Bcrypt # hasing algorithms
from flask_sqlalchemy import SQLAlchemy

# ? namespace:: internal module imports


API_ROOT_DIRECTORY = os.path.join(os.path.abspath(os.path.dirname(__file__)))
APP_ROOT_DIRECTORY = os.path.join(API_ROOT_DIRECTORY, "..") # TODO: define `manage.py`

# ? the api version is same as that of the project version
__version__ = open(os.path.join(APP_ROOT_DIRECTORY, "VERSION"), "r").read()
