# -*- encoding: utf-8 -*-

"""
The Models (M) Directory in Compliance with the MVC Architecture

The models directory is seperated into the following sub-directory
to seperate the `ams` (account management system) from the `ums`
(user management system) project. The table name follows the following
convention:
    * `ams.*` - represents the table is associated with account
        management system.
    * `ums.*` - represents the table is associated with user's
        management system.

In addition, the table with an leading `*.mw*` represents master table,
`*.META_*` represents meta management files, and `*.trx*` represents
transational tables in database.
"""

from backend.app.api.models.ams import * # noqa: F401, F403 # pyright: ignore[reportMissingImports]
from backend.app.api.models.ums import * # noqa: F401, F403 # pyright: ignore[reportMissingImports]
