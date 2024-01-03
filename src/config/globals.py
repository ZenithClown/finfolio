# -*- encoding: utf-8 -*-

"""
Global Configurations, Variables and Module Setup

The module is configured for both CLI/APP purpose using some global
configurations or variables, which are directly imported.
"""

import os
import datetime as dt

from skeleton import setupHome, setupLogging, getOrFetchDB

APP_HOME = setupHome() # ! home directory, should be parameterized
APP_DATA, _ = getOrFetchDB(dbFile = os.path.join(APP_HOME, "pOrgz.db"))

# ? setup a logger object to log during cli events
# typically, this logger file is dynamically created by date
logger_ = setupLogging(logFile = os.path.join(APP_HOME, f"[{dt.datetime.now().date()}] APPLOG Developer Console.log"))
