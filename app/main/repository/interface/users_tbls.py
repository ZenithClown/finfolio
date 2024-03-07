# -*- encoding: utf-8 -*-

from ... import db
from ...models import *
from .references_tbls import RolesTypeRepository

class UserMasterRepository(object):
    """Interface Class for UserMaster"""

    get_all      = lambda self : [row.__to_dict__() for row in UserMaster.query.all()]
    get_by_id    = lambda self, UUID : [UserMaster.query.filter_by(UUID = UUID).first().__to_dict__()]
    get_by_email = lambda self, email : [UserMaster.query.filter_by(email = email).first().__to_dict__()]
    get_by_uname = lambda self, username : [UserMaster.query.filter_by(username = username).first().__to_dict__()]


    def get_user_with_role(self, **kwargs):
        """Returns User's Table Information along with User Roles"""

        all_users = self.get_all()

        user_with_role = [] # join on RoleID
        for row in all_users:
            try:
                user_with_role.append({**row, **RolesTypeRepository().get_by_id(RoleID = row["RoleID"])[0]})
            except AttributeError as err:
                # error is raised when a RoleID present in UserMaster
                # but the RoleID is not Present in RolesType
                # TODO: throw a CRITICAL error for DevOps

                # this function will append `None` value to Each Row
                # when RoleID is missing
                user_with_role.append({**{k : None for k in RolesType().__get_column_names__()}, **row})

        # define kwargs for data filtering
        UUID     = kwargs.get("filter_by_uuid", None)
        email    = kwargs.get("filter_by_email", None)
        username = kwargs.get("filter_by_username", None)
        RoleID   = kwargs.get("filter_by_roleid", None)

        if UUID:
            user_with_role = list(filter(lambda row : row["UUID"] == UUID), user_with_role)
        elif email:
            user_with_role = list(filter(lambda row : row["email"] == email), user_with_role)
        elif username:
            user_with_role = list(filter(lambda row : row["username"] == username), user_with_role)
        elif RoleID:
            user_with_role = list(filter(lambda row : row["RoleID"] == RoleID), user_with_role)
        else:
            # TODO Raise Requirement Alert to DevOps
            pass

        return user_with_role
