# -*- encoding: utf-8 -*-

"""
Data & File Security for the Personal Finance Management Application

Data security is a crucial aspect when dealing with sensitive data
like user's transaction, and the application is designed to be secure
by default. The data are stored in an offline database and is up to
the end user to provide security to the database by using powerful
databases like PostgreSQL/MySQL with a strong password.

In addition, the raw files once read are stored in an encrypted,
compressed pickle file format so that in case of data loss/migration
the same can be referenced easily. The data file are stored in a user
defined location and is indexed for faster access and data retreival.

@author:  Debmalya Pramanik
@version: v0.0.1
"""

from cryptography.fernet import Fernet

def keygen():
    return Fernet.generate_key()

def cipher(key : bin) -> object:
    return Fernet(key)

def encrypt(data : object, key : bin):
    cipher_ = cipher(key)
    return cipher_.encrypt(data)

def decrypt(data : bin, key : bin):
    cipher_ = cipher(key)
    return cipher_.decrypt(data)
