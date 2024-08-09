# -*- encoding: utf-8 -*-

"""
Initial Seed Data for UMS METADATA Tables

The seed data is defined under a general function and can be
executed from the management file on initialization.
"""

# from backend.app.api.base import model
from backend.app.api.models import * # noqa: F401, F403 # pyright: ignore[reportMissingImports]

def user_roles() -> list:
    """
    Initial Data for `ams.META_ACCOUNT_TYPE` Table
    """

    data = {
        "ROOT" : dict(desc = "Root/Super Admin User."),
        "SUDO" : dict(desc = "A Privileged User who was Granted Access by ROOT."),
        "USER" : dict(desc = "A Normal User to Track Accounts."),
        "EXT+" : dict(desc = "An External User, typically has a Transactional Relationship.")
    }
    
    return [
        META_USER_ROLES(
            role_name = key,
            role_desc = data[key]["desc"]
        ) for key in data.keys()
    ]
