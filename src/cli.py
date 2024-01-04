# -*- encoding: utf-8 -*-

"""
Command Line Interface (CLI) for DB Interaction

Created a command line interface module for db interaction, since the
frontend application is yet not developed. The `main.py` is developed
for streamlit application, while the `cli.py` can be used to start
the pOrgz application is CLI mode.

!! Set `logger_ = (*, appType = "cli")` in `config/globals.py`

@author:  Debmalya Pramanik
@copywright: pOrgz <https://github.com/pOrgz-dev>
"""

import os

from config import * # noqa: F401, F403

# start the application with a global message, and insert logger information
print("Welcome to pOrgz CLI - an AI/ML enabled Utility Tool for Finance Management".center(os.get_terminal_size().columns))
print("===========================================================================".center(os.get_terminal_size().columns), end = "\n\n")

if __name__ == "__main__":
    pass
