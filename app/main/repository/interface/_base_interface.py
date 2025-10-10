# -*- encoding: utf-8 -*-

"""
An Interface Base Class

Interface of a table typically contains some pre-defined functions
and this base class is thus defined to be imported by any interface
module to fetch data.

? `get_all()` : Typically, this function returns everything.
"""

from app.main import db
from app.main.models import * # noqa: F401, F403

class BaseInterface(object):
    """
    Base Interface Class Defination

    The base class is dynamically defined, and is thus can be
    inherited by any child class to return some certain values.
    """

    def __init__(self, table : object) -> None:
        self.table = table
    

    # * lambda function to fetch all records from a table
    get_all = lambda self : [row.__to_dict__() for row in self.table.query.all()]
