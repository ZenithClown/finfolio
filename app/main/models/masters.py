# -*- encoding: utf-8 -*-

from .. import db

class emaiTypelMaster(db.Model):
    """Defination of Email Master Table for References"""

    __tablename__ = "emaiTypelMaster"

    typeID = db.Column(db.String(36), primary_key = True)
    acronym = db.Column(db.String(16))
    description = db.Column(db.String(255))

    # unique constraints
    db.UniqueConstraint(typeID, acronym)


class emailMaster(db.Model):
    """Defination of Email Master Table for References"""

    __tablename__ = "emailMaster"

    GUID = db.Column(db.String(36), primary_key = True)
    address = db.Column(db.String(255), nullable = False)

    # foreign key(s)
    typeID = db.Column(db.String(36), db.ForeignKey(emaiTypelMaster.typeID), nullable = False)

    # unique constraints
    db.UniqueConstraint(GUID, address)


class subscribers(db.Model):
    """List of Subscribers for Sending Automated Emails and Notifications"""

    __tablename__ = "subscribers"

    ID = db.Column(db.Integer, primary_key = True, autoincrement = True)
    preferences = db.Column(db.String(255), nullable = False) # CSV for list of subscribed services
    isActive = db.Column(db.Boolean, nullable = False)
    
    # foreign key(s)
    subscriber = db.Column(db.String(36), db.ForeignKey(emailMaster.GUID), nullable = False)


class preferenceMaster(db.Model):
    """List of Subscribers' Preferences"""

    __tablename__ = "preferenceMaster"

    ID = db.Column(db.Integer, primary_key = True, autoincrement = True)
    type = db.Column(db.String(64), nullable = False)
    remarks = db.Column(db.String(255), nullable = True)
    
    # unique constraints
    db.UniqueConstraint(ID, type)
