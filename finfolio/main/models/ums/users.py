# -*- encoding: utf-8 -*-

"""Users Metadata & Relationship Informations"""

from sqlalchemy import func
from finfolio.main import db

class UserAccounts(db.Model):
    """
    Core of User Management System (UMS) - User's Master/Metadata

    The user accounts table holds personal information of all the
    tracking members - be it for the group/family. The table provides
    a bare-bone approach, i.e., only the name and 'username' is
    sufficient to start the application, however other fields are
    good to have and maybe used for managements.
    """

    __tablename__ = "ums.UserAccounts"

    username = db.Column(db.String(32), primary_key = True)
    fullname = db.Column(db.String(128), nullable = False) # not unique

    # all other fields are optional, but good to have
    email = db.Column(db.String(128))
    phone = db.Column(db.String(16)) # may include country code

    # ? date of birth is useful for calculation/projection in finance
    dob = db.Column(db.Date) # allow nulls, todo handle in calculation

    # ! the role of a user is to be controlled by the api
    # be default, the first user is always `ROOT`, all others
    # maybe `USER` - but maybe configured for access information
    roles = db.Column(db.String(4), db.ForeignKey("ums.UserRoles.role_id"), nullable = False)

    # ? we may add created and updated on information, for underatanding
    created_at = db.Column(db.DateTime, nullable = False, server_default = func.current_timestamp())
    updated_on = db.Column(db.DateTime, server_onupdate = func.current_timestamp())

    accounts = db.relationship("MWAccountProperty", backref = "owner")


    def __to_dict__(self):
        records = super().__to_dict__()
        columns = ["username", "fullname", "email", "phone", "dob", "roles"]

        # ! type-casting is required for data-types not serializable
        records["dob"] = str(records["dob"])

        return { k : v for k, v in records.items() if k in columns }
