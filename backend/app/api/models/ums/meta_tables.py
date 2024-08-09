# -*- encoding: utf-8 -*-

"""User Roles & Privileges Defination"""

from sqlalchemy import Column, VARCHAR, Integer, ForeignKey, Index

from backend.app.api.base import BaseModel

class META_USER_ROLES(BaseModel):
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


class META_USER_SUBROLES(BaseModel):
    """
    Defination of User's Sub Roles & Defination

    To classify external users (`role_id == 4`) a sub-role table is
    defined to further categorize external users registered.
    """
    __tablename__ = "ums.META_USER_SUBROLES"

    subrole_id = Column(Integer, primary_key = True, autoincrement = True)

    # ? each account sub type is unique 3 digit code, and is linked to a parent type
    role_id = Column(Integer, ForeignKey("ums.META_USER_ROLES.role_id", ondelete = "CASCADE"), nullable = False)

    subrole_name = Column(VARCHAR(7), unique = True, nullable = False)
    subrole_desc = Column(VARCHAR(64), nullable = False)

    __table_args__ = (Index("ix_meta_subrole_role", role_id), )
