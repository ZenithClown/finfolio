# -*- encoding: utf-8 -*-

from .. import db
from .masters import emailMaster

class history(db.Model):
    """Defination of Table for Storing Historical Email Alert Services"""

    __tablename__ = "history"

    ID = db.Column(db.Integer, primary_key = True, autoincrement = True)
    eventTime = db.Column(db.DateTime, nullable = False)
    remarks = db.Column(db.String(255))
    
    # foreign key(s)
    sender = db.Column(db.String(36), db.ForeignKey(emailMaster.GUID), nullable = False)
    receiver = db.Column(db.String(36), db.ForeignKey(emailMaster.GUID), nullable = False)
