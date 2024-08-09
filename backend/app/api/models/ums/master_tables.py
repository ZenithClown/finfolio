# -*- encoding: utf-8 -*-

"""Users Metadata & Relationship Informations"""

from sqlalchemy import Column, VARCHAR, Date, ForeignKey

from backend.app.api.base import TimeStampedModel

class UserAccounts(TimeStampedModel):
    """
    Core of User Management System (UMS) - User's Master/Metadata

    The user accounts table holds personal information of all the
    tracking members - be it for the group/family. The table provides
    a bare-bone approach, i.e., only the name and 'username' is
    sufficient to start the application, however other fields are
    good to have and maybe used for managements.
    """

    __tablename__ = "ums.UserAccounts"

    username = Column(VARCHAR(32), primary_key = True)
    fullname = Column(VARCHAR(128), nullable = False) # not unique

    # all other fields are optional, but good to have
    email = Column(VARCHAR(128))
    phone = Column(VARCHAR(16)) # may include country code

    # ? date of birth is useful for calculation/projection in finance
    dob = Column(Date) # allow nulls, todo handle in calculation

    # ! the role of a user is to be controlled by the api
    # be default, the first user is always `ROOT`, all others
    # maybe `USER` - but maybe configured for access information
    user_role = Column(VARCHAR(4), ForeignKey("ums.META_USER_ROLES.role_id", ondelete = "CASCADE"), nullable = False)
