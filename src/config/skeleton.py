# -*- encoding: utf-8 -*-

"""
The Skeleton File can Serve as a Starting Point for CLI Application

The skeleton file can serve as a backend for any debugging during the
development purpose. Later, this file can be safely removed, moved or
renamed based on the requirement.
"""

import os
import sqlite3

from pathlib import Path

def setupHome(homepath : str = os.path.join(Path.home(), "pOrgz")):
    """
    Set Home Directory under a Custom Directory

    The home directory is typically User's Path `~/pOrgz` in *nix or
    `${HOME}/pOrgz` in Windows, however based on user preference this
    can be selected as any directory. The function creates the
    directory if does not exists already.
    """

    os.makedirs(homepath, exist_ok = True)
    return homepath


def getOrFetchDB(dbFile : str):
    con = sqlite3.connect(dbFile)
    return con, con.cursor()
