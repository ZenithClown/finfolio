# -*- encoding: utf-8 -*-

"""
Global Configurations, Variables and Module Setup

The module is configured for both CLI/APP purpose using some global
configurations or variables, which are directly imported.
"""

import os

from config.skeleton import setupHome, getOrFetchDB

APP_HOME = setupHome() # ! home directory, should be parameterized
APP_ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..")

# all application data is stored in serverless, sqlite3 database
# todo: enable encryption logic on db file with hashing algorithm
APP_DATA, DB_CURSOR = getOrFetchDB(dbFile = os.path.join(APP_HOME, "pOrgz.db"))

# using parameterized raw-sql for db communication
DB_STRUCT = os.path.join(APP_ROOT, "db")

DB_VIEWS = os.path.join(DB_STRUCT, "views")
DB_MODELS = os.path.join(DB_STRUCT, "models")
DB_QUERIES = os.path.join(DB_STRUCT, "queries", "statements")
