# -*- encoding: utf-8 -*-

"""
API Model Base File and Configuration of Session Parameter

The base model follows the `sqlalchemy.orm.declarative_base` format,
and the abstract model can be inherited by relevant models.
"""

import datetime as dt

from sqlalchemy import Column, DateTime
from sqlalchemy.orm import declarative_base

from backend import USER_HOME_DIRECTORY
from backend.main import session

# ! defination of abstract model object
model = declarative_base()

class BaseModel(model):
    """
    Base Model to Handle & Encapsulate Requests with Authentication

    The base model integrates security and defines basic functions 
    abstraction methods. The constructor functions can be overriden.
    """

    __abstract__ = True

    def __repr__(self) -> str:
        return f"{self.__class__.__name__}, path = {USER_HOME_DIRECTORY}"


class TimeStampedModel(BaseModel):
    """
    Extends the `BaseModel` the `TimeStampedModel` for Transactions

    The `TimeStampedModel` can be used to define any transactional
    tables which includes the created/updated on timestamp for records.
    """

    __abstract__ = True

    created_at = Column(DateTime, nullable = False, default = dt.datetime.now(dt.timezone.utc))
    updated_on = Column(DateTime, nullable = True, default = None, onupdate = dt.datetime.now(dt.timezone.utc))
