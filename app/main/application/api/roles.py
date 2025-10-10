# -*- encoding: utf-8 -*

from flask import request
from flask import redirect

from app.main.application._base_resource import BaseResource
from app.main.repository.interface import RolesMasterInterface

class RolesAPI(BaseResource):
    def __init__(self):
        super().__init__()

        # database access repository/interfaces modules
        self.roles_master_tbl_interface = RolesMasterInterface()

    
    def get(self):
        return self.formatter.get(self.roles_master_tbl_interface.get_all())
