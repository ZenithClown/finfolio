# -*- encoding: utf-8 -*-

# test model should always be isolated from main environment
# hence both `app` and `api` model is redefined in the test directory
# ADVANTAGES :
#   - considering `test-db` from `onfig.py` the database can be deleted/recreated as per will
#   - after each test, `tearDown()` should be called - thus any uniqueness is preserved everytime
#   - only the required controller can be redefined here for testing
# DISADVANTAGE :
#   - `api.add_resource()` has to be defined twice (from `manage.py` and during test-environment)

from flask_restful import Api
from ..main import create_app

# redefine app for testing
app = create_app(config_name = "test") # check config.py

# the main endpoints are defined without `prefix`
# thus, the testing environment is understood better with prefix
api = Api(app, prefix = "/testing")

# import all controller and api endpoints
from app.main.application import *

# redefine all resources for testing, as per requirement, as below
api.add_resource(HelloWorld, "/") # hello-world endpoint
