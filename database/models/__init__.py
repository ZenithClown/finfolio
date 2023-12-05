# -*- encoding: utf-8 -*-

"""
Models Initialization File for pOrgz Application

The initialization method for the `database/models` which stores all
the object-relational mapping of both `ams` and `ums` sub-package. In
addition, the base method and defalt database location is configured
from the initialization module.

@author:  Debmalya Pramanik
@version: v0.0.1
"""

import sqlalchemy as sa
import sqlalchemy.orm as orm

# WARN: DATABASE_URI is hard-coded, will be controlled from external/frontend
DATABASE_URI = "sqlite:///example.db"

# create a sqlalchemy `engine` and `session` object, name is as per convention
engine = sa.create_engine(DATABASE_URI, echo = True)
session = orm.sessionmaker(bind = engine) # read as `with session() as sess:`

# init-time options registrations for model class
