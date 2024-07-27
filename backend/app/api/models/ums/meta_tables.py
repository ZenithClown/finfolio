# -*- encoding: utf-8 -*-

"""User Roles & Privileges Defination"""

from sqlalchemy import Column, VARCHAR, Integer

from backend.app.api.base import BaseModel

class UserRoles(BaseModel):
    """
    Defination of User Roles & Privileges

    On creating the database, the first user is assigned the role of
    `ROOT` while all other users' may operate as an `USER` role.
    However, for more control and elevated access, different levels
    of access may be defined.
    """

    __tablename__ = "ums.META_USER_ROLES"

    # ? autoincrement = True should work for mysql/psql directly
    # https://stackoverflow.com/a/69822361/6623589
    __table_args__ = {"sqlite_autoincrement" : True}

    role_id   = Column(Integer, primary_key = True, autoincrement = True)
    role_name = Column(VARCHAR(4), unique = True, nullable = False)
    role_desc = Column(VARCHAR(64), nullable = False)
