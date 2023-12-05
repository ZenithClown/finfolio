# -*- encoding: utf-8 -*-

"""
Base Model Class for pOrgz Application

SQL-Alchemy provides functionality to define a base model class which
can be inherited for model development. The defined base class can be configured
to work as a fallback for class methods like `__repr__()` and `__str__()`, in
addition default data conversions and methods.

@author:  Debmalya Pramanik
@version: v0.0.1
"""

import sqlalchemy as sa

from sqlalchemy.orm import declared_attr
from sqlalchemy.orm import declarative_base

class ModelClass(object):
    _id = sa.Column(sa.Integer, primary_key = True, autoincrement = True)

base = declarative_base(cls = ModelClass) # inherit base as `class MyClass(base)`

if __name__ == "__main__":
    from . import engine

    print("Creating Database ...")
    base.metadata.create_all(engine)
    print("  >> Database created successfully.")
