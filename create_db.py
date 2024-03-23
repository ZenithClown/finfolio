# -*- encoding: utf-8 -*-

"""Create and/or Migrations Statement"""

from finfolio import app

from finfolio.main import (
    db, # instance of the database object
    create_app # initialize app statement
)

# ? import all model definations, let flask handle the rest
from finfolio.main.models import * # noqa: F401, F403 # pyright: ignore[reportMissingImports]

# app = create_app("dev") # create the app in dev-environment

with app.app_context():
    # db.init_app(app)
    db.create_all() # create all tables

# ! Addind Seed/Initial Data into Tables ! #
root = UserRoles(role_id = 1, role_name = "ROOT", role_desc = "Root/Super Admin User")
user = UserRoles(role_id = 2, role_name = "USER", role_desc = "A Normal User to Track Accounts")

with app.app_context():
    db.session.add_all([root, user])
    db.session.commit()
