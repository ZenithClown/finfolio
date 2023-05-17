# -*- encoding: utf-8 -*-

"""
ORM Defination of `users` Table

Users basic information is stored under generic `users` table. The 
`users` table is the most significant table with Primary Key (PK) set
as `username` which is set on user creation. Other columns has their
relevant meanings.

TODO: demography, alternate details, security, roles, etc.
"""

import datetime as dt
import sqlalchemy as sa

from app.main import db

class UsersTable(db.Model):
    __tablename__ = "users"

    username = db.Column(sa.String(25), primary_key = True)
    password = db.Column(sa.String(1024), nullable = False)

    # adding the users personal information
    first_name = db.Column(sa.String(255), nullable = False)
    middle_name = db.Column(sa.String(255), nullable = True)
    family_name = db.Column(sa.String(255), nullable = False)

    # this section adds identity information
    email_id = db.Column(sa.String(255), nullable = False, unique = True)
    mobile_number = db.Column(sa.Integer, nullable = False, unique = True) # no country code

    # this stores the record datetime information
    created_at = db.Column(sa.DateTime, default = dt.datetime.now())
    updated_at = db.Column(sa.DateTime, onupdate = dt.datetime.now())


    def __repr__(self) -> str:
        return f"<UsersTable (id = {id}, username = {self.username})>"
