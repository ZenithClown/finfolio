# -*- encoding: utf-8 -*-

"""
API Ideation Phase is Tested using IDEATION File

This is a ideation/main file for controlling the application in
development and initial dashboard build. Currently, live market data
testing is pending, and thus no database is yet defined.

TODO design database and understand how to insert data in real-time
TODO create different modules for data processing and storage
! Only a CONTROLLER is defined that controlls every aspect of code
"""

from flask import request
from flask import redirect

from app.main.application._base_resource import BaseResource

class SymbolList(BaseResource):
    # return a list of avaiable symbol to download

    def __init__(self):
        super().__init__()

    
    def get(self):
        return self.formatter.get([
            "NIFTY",
            "BANKNIFTY"
        ])
