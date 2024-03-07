# -*- encoding: utf-8 -*-

"""Controller to Check the Status & Health of the API Running"""

from time import ctime
from flask import request
from flask_restful import Resource

from ... import (
    __author__,
    __author_email__,

    __status__,
    __version__,
    __copyright__
)

class StatusCheck(Resource):
    """Status can be used for Debug/Monitoring Purposes"""
    
    def get(self):
        """GET Status of the Running API Module"""

        return {
            "status" : {
                "code"    : 200,
                "refer"   : "Ok",
                "remarks" : "All Services are Up & Running"
            },

            "__header__" : {
                "Author"      : f"{__author__} <{__author_email__}>",
                "API Version" : f"{__version__} ({__status__})",
                "Copywrights" : __copyright__
            },

            "links" : {
                "Project Link" : "https://github.com/pOrgz-dev/mailer",
                "Organization" : "pOrgz-dev <https://github.com/pOrgz-dev>",
            },

            "Current Time" : ctime()
        }