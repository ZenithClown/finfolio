# -*- encoding: utf-8 -*-

"""Security Features & Settings"""

import os
import hashlib
from dotenv import load_dotenv
load_dotenv(verbose = True)

class PasswordEncryption(object):
    """Encrypt & Decrypt Data as Required"""

    def __init__(self):
        self._forward_salt  = os.getenv('forward_salt')
        self._backward_salt = os.getenv('backward_salt')


    def encrypt(self, password : str) -> str:
        _salted_password = self._forward_salt + password + self._backward_salt
        return hashlib.sha512(_salted_password.encode()).hexdigest()


    def validate(self, cur_password : str, set_password : str) -> bool:
        _salted_cur_password = self._forward_salt + cur_password + self._backward_salt

        if hashlib.sha512(_salted_cur_password.encode()).hexdigest() == set_password:
            return True

        return False # password does not match
