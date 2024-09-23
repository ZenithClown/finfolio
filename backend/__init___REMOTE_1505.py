# -*- encoding: utf-8 -*-

"""
The Backend Application Layer for the **`finfolio`** Repository

The backend application layer seperates the application from the
presentation layer (frontend) and helps in maintaining the DRY
strategy. The code is OOP oriented, and uses SQLAlchemy.
"""

import os
import pathlib

APP_ROOT_DIRECTORY = os.path.abspath(os.path.dirname(__file__))
USER_HOME_DIRECTORY = os.path.join(pathlib.Path.home(), ".pOrgz")

# ? the app version is defined and maybe used in the routes
__version__ = open(os.path.join(APP_ROOT_DIRECTORY, "VERSION"), "r").read()
