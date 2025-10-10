# -*- encoding: utf-8 -*-

"""
CLI Interface for pOrgz-API

Initialization values that are required by the CLI interface to
operate properly.
"""

import os

__version__ = "CLI:" + \
    open(os.path.join(os.path.dirname(os.path.abspath(__file__)), "VERSION"), "r").read()
