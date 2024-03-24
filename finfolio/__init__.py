# -*- encoding: utf-8 -*-

"""
REST-API Endpoints Initialization & Defination Section

The api endpoints (or routes) are defined at the application level
(i.e., `finfolio/finfolio` directory) enabling the option to use the
instance at both `manage.py` and testing environment.

Currently, this section is in development, and gradual transition in
progress to move/alter all codes from `finfolio/database` to
`finfolio/finfolio`, i.e., at the REST-API level.

@author:  pOrgz-dev, Debmalya Pramanik
@version: v1.0.0
"""


import os

# ? namespace:: import of the flask-#, i.e., extensions
from flask_restful import Api

# ? namespace:: import `create_app()` for application initialization
from finfolio.main import create_app # pyright: ignore[reportMissingImports]

API_ROOT_DIRECTORY = os.path.join(os.path.abspath(os.path.dirname(__file__)))
APP_ROOT_DIRECTORY = os.path.join(API_ROOT_DIRECTORY, "..") # TODO: define `manage.py`

# ? the api version is same as that of the project version
__version__ = open(os.path.join(APP_ROOT_DIRECTORY, "VERSION"), "r").read()

# define project type from `config.py` or `.env` file or `$PATH`
# ! only `dev` environment is now defined, may push for prod on maturity
PROJECT_ENVIRON = os.getenv("PROJECT_ENV_NAME") or "dev"
app = create_app(PROJECT_ENVIRON) # check config.py

# ? create `api` object using `Api` and define all endpoints
prefix = {
    # rest-api endpoint prefix :: locahost:5000/dev/...

    "dev"  : "/dev/",
    "test" : "/testing/"
}.get(PROJECT_ENVIRON, f"/api/{PROJECT_ENVIRON}/{__version__}/")

api = Api(app, prefix = prefix)

### --- List all Resources/Controller --- ###
from finfolio.main.controller import * # noqa: F401, F403 # pyright: ignore[reportMissingImports]

### --- User Management System (UMS) Endpoints/Routes --- ###
api.add_resource(UserManagementSystemController, "ums/users")
