# -*- encoding: utf-8 -*-

"""
Setup Initial Project Skeleton & Database

The project skeleton, including setting up default home directory,
initialization of database with seed values can be triggered from the
`skeleton.py` file, providing dynamic approach.
"""

import os

def setupHome(homepath : str) -> bool:
    """
    Setup Project Directory under User's Home Directory

    The user's home directory is as defined under `backend/__init__.py`
    and is the default location for database file creation.

    :type  homepath: string
    :param homepath: A valid home directory, preferrably absolute
        directory like `pathlib.Path.home()` independent of the system.

    :rtype:   bool
    :returns: True/false based on program's ability to successfully
        create app's home in home path (default).
    """

    os.makedirs(homepath, exist_ok = True)
    return True
