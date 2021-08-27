# -*- encoding: utf-8 -*-

from .. import db
from ._base_model import ModelSchema

class RolesType(db.Model, ModelSchema):
    """Use the Model to Establish a Connection to DB"""

    __tablename__ = "RolesType"

    RoleID   = db.Column(db.String(64), primary_key = True, nullable = False)
    RoleName = db.Column(db.String(16), nullable = False)


    def __init__(self):
        ModelSchema().__init__()


class AccountType(db.Model, ModelSchema):
    """Use the Model to Establish a Connection to DB"""

    __tablename__ = "AccountType"

    ACTypeID   = db.Column(db.String(64), primary_key = True, nullable = False)
    ACTypeName = db.Column(db.String(16), nullable = False)


    def __init__(self):
        ModelSchema().__init__()
