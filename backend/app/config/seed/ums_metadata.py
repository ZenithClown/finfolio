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
    Initial Data for `ums.META_USER_ROLES` Table
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


def user_rubroles() -> list:
    """
    Initial Data for `ums.META_USER_SUBROLES` Table
    """

    data = {
        "COMPANY" : dict(subrole_desc = "An organization where a user has typically worked."),
        "FRIENDS" : dict(subrole_desc = "A friend of a user."),
        "RELATIVES" : dict(subrole_desc = "A relative of a user, whose account is typically not tracked."),
        "OTHERS" : dict(subrole_desc = "An other type of external user whose relation does not fall into any other defined sub-category."),
        "ENTITY" : dict(subrole_desc = "An organization who typically has a transactional relationship with the user.")
    }

    return [
        META_USER_SUBROLES(
            role_id = 4, # constant to external user; have not decided for a different subroles
            subrole_name = key,
            subrole_desc = data[key]["subrole_desc"]
        ) for key in data.keys()
    ]
