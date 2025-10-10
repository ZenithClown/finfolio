# -*- encoding: utf-8 -*-

"""
Application Layer Initialization File

The application layer houses functionalities like the API defination,
database migrations, routes handling, code testing, etc.
"""

import os

from backend import APP_ROOT_DIRECTORY

# define internal directory for code access controls
API_ROOT_DIRECTORY = os.path.join(APP_ROOT_DIRECTORY, "api")
PROJECT_CONFIG_DIRECTORY = os.path.join(APP_ROOT_DIRECTORY, "config")
