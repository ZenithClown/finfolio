# -*- encoding: utf-8 -*-

"""
A Simple SQLite3 Interface to Create & Initialize DB

Create a `finfolio.db` file at `Path()/pOrgz/` directory, and populate
with initial master data. The initial master data is stored in the
[configuration](./config) directory.

@author:  Debmalya Pramanik
@version: v0.0.1
"""

import os

from backend import execute
from backend.config import * # noqa: F401, F403

if __name__ == "__main__":
    print("Welcome to pOrgz CLI - an AI/ML enabled Utility Tool for Finance Management".center(os.get_terminal_size().columns))
    print("===========================================================================".center(os.get_terminal_size().columns), end = "\n\n")

    print(f"Setting Application Homepath: {APP_HOME}")
    print("Check FOSS Code Documentation: ") # TODO: https://github.com/ZenithClown/finfolio/issues/6
