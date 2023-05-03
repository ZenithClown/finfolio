# -*- encoding: utf-8 -*-

"""
ORM Structure for User Roles

Typically, for each created user we may want to assign a different
roles based on their privileges. The roles master can be defined to
set different types of roles and for control. The `roles` table
however is defined such that each user falls in any one of the
defined categories.
"""

import datetime as dt
import sqlalchemy as sa

from app.main import db

class RolesMaster(db.Model):
    __tablename__ = "roles_master"

    id_ = db.Column(sa.Integer, primary_key = True, autoincrement = True)
    role = db.Column(sa.String(25), nullable = False, unique = True)
    description = db.Column(sa.String(255), nullable = False, unique = True)


class UsersRoles(db.Model):
    __tablename__ = "user_roles"

    id_ = db.Column(sa.Integer, primary_key = True, autoincrement = True)
    username = db.Column(sa.String(25), db.ForeignKey('users.username', ondelete = "CASCADE"), nullable = False)
    user_role = db.Column(sa.String(25), db.ForeignKey('roles_master.role', ondelete = "CASCADE"), nullable = False)
