# -*- encoding: utf-8 -*-

from ... import db
from ...models import *

class RolesTypeRepository(object):
    """Interface Class for RolesType"""

    get_all     = lambda self : [row.__to_dict__() for row in RolesType.query.all()]
    get_by_id   = lambda self, RoleID : [RolesType.query.filter_by(RoleID = RoleID).first().__to_dict__()]
    get_by_name = lambda self, RoleName : [RolesType.query.filter_by(RoleName = RoleName).first().__to_dict__()]


class AccountTypeRepository(object):
    """Interface Class for AccountType"""

    get_all     = lambda self : [row.__to_dict__() for row in AccountType.query.all()]
    get_by_id   = lambda self, ACTypeID : [AccountType.query.filter_by(ACTypeID = ACTypeID).first().__to_dict__()]
    get_by_name = lambda self, ACTypeName : [AccountType.query.filter_by(ACTypeName = ACTypeName).first().__to_dict__()]
