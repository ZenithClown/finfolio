# -*- encoding: utf-8 -*-

from uuid import uuid4
from datetime import date

from .. import db
from ..models import *
from .interface import *

class OpenAccountRepository(object):
    """Handle Registrations Request"""

    def __init__(self):
        # default constructor
        # define interface class objs
        # for CRUD operations and/or control
        
        self.account_type_repository = AccountTypeRepository()
        self.roles_type_repository = RolesTypeRepository()
        self.user_master_repository = UserMasterRepository()


    def create_user_account(self, args : dict):
        """Create a New User and/or Open a New User Account"""

        UUID = str(uuid4()) # generate a new User-ID

        # creating a new account affects the following tables
        user_master_record = UserMaster(
                UUID       = UUID,
                username   = args["username"],
                FirstName  = args["FirstName"],
                MiddleName = None, # args["MiddleName"],
                LastName   = args["LastName"],
                email      = args["email"],
                password   = args["password"],
                mobile     = None, # args["mobile"],
                RoleID     = self.roles_type_repository.get_by_name(RoleName = "USERS")[0]["RoleID"]
            )

        account_details_record = AccountDetails(
                AccountID = args["AccountID"],
                IFSCCode  = args["IFSCCode"],
                CIFNumber = args["CIFNumber"],
                OpenDate  = date(*list(map(int, args["OpenDate"].split("-")[::-1]))),
                CloseDate = None,
                UUID      = UUID,
                ACTypeID  = self.account_type_repository.get_by_name(ACTypeName = args["AccountType"])[0]["ACTypeID"],
            )

        # add new records to the table
        # in order of PK-FK constraints
        db.session.add(user_master_record)
        db.session.add(account_details_record)

        db.session.commit()
        db.session.close()
        db.engine.dispose()

        return UUID
