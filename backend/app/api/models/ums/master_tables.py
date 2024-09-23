# -*- encoding: utf-8 -*-

"""Users Metadata & Relationship Informations"""

from sqlalchemy import Column, VARCHAR, Date, ForeignKey, Integer, Index, CheckConstraint, VARBINARY, BOOLEAN

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
    fullname = Column(VARCHAR(128), unique = True, nullable = False) # not unique

    # ? the password is available for only users who has login access, thus nullable
    # todo use cryptography.fernet / gh#1 https://github.com/ZenithClown/finfolio/issues/1
    password = Column(VARBINARY(256), nullable = True, default = None)

    # all other fields are optional, but good to have
    email = Column(VARCHAR(128))
    phone = Column(VARCHAR(16)) # may include country code

    # ? date of birth is useful for calculation/projection in finance
    dob = Column(Date) # allow nulls, todo handle in calculation

    # ! the role of a user is to be controlled by the api
    # be default, the first user is always `ROOT`, all others
    # maybe `USER` - but maybe configured for access information
    user_role = Column(Integer, ForeignKey("ums.META_USER_ROLES.role_id", ondelete = "CASCADE"), nullable = False)
    user_subrole = Column(Integer, ForeignKey("ums.META_USER_SUBROLES.subrole_id", ondelete = "CASCADE"), nullable = True, default = None)

    # internal accounts identified by the pre-defined flag `INT+` has a linked self account
    linked_account = Column(VARCHAR(32), ForeignKey("ams.AccountPrimaryDetails.account_id", ondelete = "CASCADE"), default = None)

    # ..versionadded:: using a text field "login" that can be used on frontend
    # users who are typically external do not have a login credentials to the application
    login = Column(BOOLEAN, nullable = False, default = 1)

    __table_args__ = (
        Index("ix_mw_user_role", user_role),
        Index("ix_mw_user_subrole", user_subrole),
        CheckConstraint("login IN (0, 1)", "login_flag"), # ? boolean is not available, thus check constraint
    )
