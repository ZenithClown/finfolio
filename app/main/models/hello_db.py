# -*- encoding: utf-8 -*-

from .. import db
from ._base_model import ModelSchema

class HelloDB(db.Model, ModelSchema):
    """Use the Model to Establish a Connection to DB"""

    __tablename__ = "HelloDB"

    id    = db.Column(db.Integer, primary_key = True, autoincrement = True, nullable = False)
    field = db.Column(db.String(255), nullable = False)


    def __init__(self):
        ModelSchema().__init__()
