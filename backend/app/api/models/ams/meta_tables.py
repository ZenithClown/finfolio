# -*- encoding: utf-8 -*-

"""
METADATA Table Definations for AMS Functionalities

The meta tables are created to efficiently handle the types of
account, grouping/clubbing transactions and inter-linking of details
based on the criteria. Check model definations for more information.
"""

from sqlalchemy import Column, VARCHAR, ForeignKey, Index

from backend.app.api.base import BaseModel

class META_ACCOUNT_TYPE(BaseModel):
    __tablename__ = "ams.META_ACCOUNT_TYPE"

    account_type = Column(VARCHAR(3), primary_key = True, nullable = False, autoincrement = False)
    account_type_name = Column(VARCHAR(16), unique = True, nullable = False) # typically, the display name
    account_type_desc = Column(VARCHAR(64), nullable = False) # description of the account type, user aware

class META_SUBACCOUNT_TYPE(BaseModel):
    __tablename__ = "ams.META_SUBACCOUNT_TYPE"

    account_subtype = Column(VARCHAR(3), primary_key = True, nullable = False, autoincrement = False)

    # ? each account sub type is unique 3 digit code, and is linked to a parent type
    account_type = Column(VARCHAR(3), ForeignKey("ams.META_ACCOUNT_TYPE.account_type", ondelete = "CASCADE"), nullable = False)

    account_subtype_name = Column(VARCHAR(16), unique = True, nullable = False) # typically, the display name
    account_subtype_desc = Column(VARCHAR(64), nullable = True) # description of the account type, for user aware

    __table_args__ = (Index("ix_meta_subaccount_type_account_type", account_type), )
