# -*- encoding: utf-8 -*-

"""Create and/or Migrations Statement"""

from finfolio import app

from finfolio.main import (
    db, # instance of the database object
    create_app # initialize app statement
)

# ? import all model definations, let flask handle the rest
from finfolio.main.models import * # noqa: F401, F403 # pyright: ignore[reportMissingImports]

# app = create_app("dev") # create the app in dev-environment

with app.app_context():
    # db.init_app(app)
    db.create_all() # create all tables

# ! Addind Seed/Initial Data into Tables ! #
root = UserRoles(role_id = 1, role_name = "ROOT", role_desc = "Root/Super Admin User")
user = UserRoles(role_id = 2, role_name = "USER", role_desc = "A Normal User to Track Accounts")

dbt = MWAccountType(account_type_id = "DBT", account_type_name = "DEBIT", account_type_desc = "Use this to store transactions from savings/current account.")
cdt = MWAccountType(account_type_id = "CDT", account_type_name = "CREDIT", account_type_desc = "Use this to store transactions related to loans, credit cards, etc.")
wlt = MWAccountType(account_type_id = "WLT", account_type_name = "WALLET", account_type_desc = "A type of account for storing gift cards, points, cashbacks, rewards etc. informations.")
dmt = MWAccountType(account_type_id = "DMT", account_type_name = "DEMAT", account_type_desc = "A typical table for holding information related to share market, populate equity, f&o transactions.")
ret = MWAccountType(account_type_id = "RET", account_type_name = "RETIREMENT", account_type_desc = "An account dedicated for savings for retirements, like PPF, VPF, NPS, etc.")
ins = MWAccountType(account_type_id = "INS", account_type_name = "INSURANCE", account_type_desc = "Use this to track investments/redemptions into insurance.")
mfa = MWAccountType(account_type_id = "MFA", account_type_name = "MUTUALFUND", account_type_desc = "A typical account for management of mutual funds and SIP/STP informations.")
tda = MWAccountType(account_type_id = "TDA", account_type_name = "TDACCOUNT", account_type_desc = "Term deposit accounts like FD/RD/etc. can be tracked here.")

fds = MWSubAccountType(account_subtype_id = "FDS", account_type_id = "TDA", account_subtype_name = "Fixed Deposit Account")
rds = MWSubAccountType(account_subtype_id = "RDS", account_type_id = "TDA", account_subtype_name = "Recurring Deposit Account")
svn = MWSubAccountType(account_subtype_id = "SVN", account_type_id = "DBT", account_subtype_name = "Saving Account")
sal = MWSubAccountType(account_subtype_id = "SAL", account_type_id = "DBT", account_subtype_name = "Salary Account")
cur = MWSubAccountType(account_subtype_id = "CUR", account_type_id = "DBT", account_subtype_name = "Current Account")
ppf = MWSubAccountType(account_subtype_id = "PPF", account_type_id = "RET", account_subtype_name = "Personal Providend Funds Account")
vpf = MWSubAccountType(account_subtype_id = "VPF", account_type_id = "RET", account_subtype_name = "Voluntary Providend Funds Account")
nps = MWSubAccountType(account_subtype_id = "NPS", account_type_id = "RET", account_subtype_name = "National Pension Schemes Account")


with app.app_context():
    # seed user roles
    db.session.add_all([root, user])
    db.session.commit()

    # seed user account types
    db.session.add_all([dbt, cdt, wlt, dmt, ret, ins, mfa, tda])
    db.session.commit()

    # seed user sub-account types
    db.session.add_all([fds, rds, svn, sal, cur, ppf, vpf, nps])
    db.session.commit()
