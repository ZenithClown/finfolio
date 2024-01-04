# -*- encoding: utf-8 -*-

"""
Global Configurations, Variables and Module Setup

The module is configured for both CLI/APP purpose using some global
configurations or variables, which are directly imported.
"""

import os
import sys
import datetime as dt

from .skeleton import setupHome, setupLogging, getOrFetchDB

APP_HOME = setupHome() # ! home directory, should be parameterized
APP_ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..")

# ? setup a logger object to log during cli events
# typically, this logger file is dynamically created by date
logger_ = setupLogging(logFile = os.path.join(APP_HOME, f"[{dt.datetime.now().date()}] APPLOG Developer Console.log"))

# log directory information, and append path variable during code runtime
logger_.info(f"APP_ROOT::{APP_ROOT} || APP_HOME::{APP_HOME}")

# all application data is stored in serverless, sqlite3 database
# todo: enable encryption logic on db file with hashing algorithm

dbFile = "pOrgz.db"
logger_.info(f"Connecting to `{dbFile}`...")

try:
    APP_DATA, _ = getOrFetchDB(dbFile = os.path.join(APP_HOME, dbFile))
except Exception as err:
    APP_DATA = None # todo: fail the application when not load
    logger_.error(f"Failed to Connect to DB: {err}")
else:
    logger_.info("no-console. Connected to database file.")

# using parameterized raw-sql for db communication
DB_QUERIES = os.path.join(APP_ROOT, "db")

DB_VIEWS = os.path.join(DB_QUERIES, "views")
DB_MODELS = os.path.join(DB_QUERIES, "models")
