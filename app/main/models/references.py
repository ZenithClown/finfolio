# -*- encoding: utf-8 -*-

from .. import db
from ._base_model import ModelSchema

class RolesType(db.Model):
    """Use the Model to Establish a Connection to DB"""

    __tablename__ = "RolesType"

    RoleID   = db.Column(db.String(64), primary_key = True, nullable = False)
    RoleName = db.Column(db.String(16), nullable = False)


    # def __init__(self):
    #     ModelSchema().__init__()

    # def __to_dict__(self):
    #     # method can be used to automatically parse data into key-value pairs
    #     # without the use of any lambda functionalities or marshalling
    #     return { c.key : getattr(self, c.key) for c in self.__table__.columns }


class AccountType(db.Model):
    """Use the Model to Establish a Connection to DB"""

    __tablename__ = "AccountType"

    ACTypeID   = db.Column(db.String(64), primary_key = True, nullable = False)
    ACTypeName = db.Column(db.String(16), nullable = False)


    # def __init__(self):
    #     ModelSchema().__init__()

    # def __to_dict__(self):
    #     # method can be used to automatically parse data into key-value pairs
    #     # without the use of any lambda functionalities or marshalling
    #     return { c.key : getattr(self, c.key) for c in self.__table__.columns }
