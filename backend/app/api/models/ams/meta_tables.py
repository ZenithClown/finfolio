# -*- encoding: utf-8 -*-

"""
METADATA Table Definations for AMS Functionalities

The meta tables are created to efficiently handle the types of
account, grouping/clubbing transactions and inter-linking of details
based on the criteria. Check model definations for more information.
"""

from sqlalchemy.orm import Relationship
from sqlalchemy import Column, VARCHAR, ForeignKey

from backend.app.api.base import BaseModel

class META_ACCOUNT_TYPE(BaseModel):
    __tablename__ = "ams.META_ACCOUNT_TYPE"

    account_type = Column(VARCHAR(3), primary_key = True, nullable = False, autoincrement = False)
    account_type_name = Column(VARCHAR(16), unique = True, nullable = False) # typically, the display name
    account_type_desc = Column(VARCHAR(64), nullable = False) # description of the account type, user aware

    _fkp_acc_type = Relationship("META_SUBACCOUNT_TYPE", back_populates = "ams.META_ACCOUNT_TYPE", passive_deletes = True)

class META_SUBACCOUNT_TYPE(BaseModel):
    __tablename__ = "ams.META_SUBACCOUNT_TYPE"

    account_subtype = Column(VARCHAR(3), primary_key = True, nullable = False, autoincrement = False)

    # ? each account sub type is unique 3 digit code, and is linked to a parent type
    account_type = Column(VARCHAR(3), ForeignKey("ams.META_ACCOUNT_TYPE.account_type", ondelete = "CASCADE"), nullable = False, index = True)
    _fkc_acc_type = Relationship("META_ACCOUNT_TYPE", back_populates = "_fkp_acc_type")

    account_subtype_name = Column(VARCHAR(16), unique = True, nullable = False) # typically, the display name
    account_subtype_desc = Column(VARCHAR(64), nullable = False) # description of the account type, user aware
