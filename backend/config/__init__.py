# -*- encoding: utf-8 -*-

"""
Global Configurations, Variables and Module Setup

The module is configured for both CLI/APP purpose using some global
configurations or variables, which are directly imported.
"""

import os
import sys
import json

__THIS_FILE_DIR__ = os.path.dirname(os.path.abspath(__file__))
sys.path.append(__THIS_FILE_DIR__)

# import the skeleton for config
# ! may delete on configurations
# ? using relative import in file
import skeleton as skl

APP_HOME = skl.setupHome() # ! home directory, should be parameterized
APP_ROOT = os.path.join(__THIS_FILE_DIR__, "..", "..")

# all application data is stored in serverless, sqlite3 database
# todo: enable encryption logic on db file with hashing algorithm
APP_ENGINE, DB_CURSOR = skl.getOrFetchDB(dbFile = os.path.join(APP_HOME, "finfolio.db"))

# using parameterized raw-sql for db communication
DB_STRUCT = os.path.join(APP_ROOT, "database")

DB_VIEWS  = os.path.join(DB_STRUCT, "views")
DB_MODELS = os.path.join(DB_STRUCT, "models")
INTERFACE = os.path.join(DB_STRUCT, "interface")

# ..versionadded:: initial master data is added from `master-data.json` instead from file
_master_data_config = os.path.join(__THIS_FILE_DIR__, "master-data.json")
MASTER_INIT_DATA = json.load(open(_master_data_config, "r"))
