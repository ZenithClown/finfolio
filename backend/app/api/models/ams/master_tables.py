# -*- encoding: utf-8 -*-

"""Account Management System Master Tables"""

from sqlalchemy import Column, VARCHAR, Date, ForeignKey, Index, Float

from backend.app.api.base import TimeStampedModel

class AccountPrimaryDetails(TimeStampedModel):
    """
    The Master Table to Hold Primary Details for an Account

    The primary details are must and is applicable for any generally
    define account/sub-account types defined. The details are
    extended based on requirements on the `AccountExtendedDetails`
    table for easier maintenance and following NORM-1 convention.
    """

    __tablename__ = "ams.AccountPrimaryDetails"

    account_id     = Column(VARCHAR(32), primary_key = True) # UUID()
    account_number = Column(VARCHAR(32), unique = True, nullable = False)
    account_name   = Column(VARCHAR(64), unique = True, nullable = False)
    account_owner  = Column(VARCHAR(32), ForeignKey("ums.UserAccounts.username", ondelete = "CASCADE"), nullable = False)

    # ? refer and collate account and sub-types from master table, like:
    account_type_id = Column(VARCHAR(3), ForeignKey("ams.META_ACCOUNT_TYPE.account_type", ondelete = "CASCADE"), nullable = False)
    account_subtype_id = Column(VARCHAR(3), ForeignKey("ams.META_SUBACCOUNT_TYPE.account_subtype", ondelete = "CASCADE"), default = None)

    # ? account opening and closing date informations
    account_opened_on = Column(Date, nullable = False)
    account_closed_on = Column(Date) # ? if null, account is active/operational

    # ? we may not have all the transactions, thus we can set an opening balance
    account_openeing_balance = Column(Float(2), default = 0, nullable = False)
    opening_balance_recorded_on = Column(Date, default = account_opened_on, nullable = False)
    account_marked_as_inactive_on = Column(Date, default = None) # ? maybe active, but decided not to be used by user

    __table_args__ = (Index("ix_mw_account_owner", account_owner), Index("ix_mw_account_type", account_type_id), Index("ix_mw_account_subtype", account_subtype_id), )
