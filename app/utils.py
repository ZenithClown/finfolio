# -*- encoding: utf-8 -*-

import time

class ResponseFormatter(object):
    """Format any CRUD Operation to a Standard API Response"""

    def get_small_message(self, code : str) -> int:
        """Define Status Codes for API Response"""

        return {
            200 : "OK",
            201 : "Created",
            204 : "No Content",
            400 : "Bad Request",
            401 : "Unauthorized",
            403 : "Forbidden",
            404 : "Not Found",
            500 : "Internal Server Error"
        }.get(code, 502) # 502 > Bad Gateway


    def get(self, data : list, err : str = None, code : int = 200, msg : str = None) -> dict:
        """Format O/P of all GET Response"""

        return {
            "status" : {
                "code"    : code, # https://www.restapitutorial.com/httpstatuscodes.html
                "refer"   : self.get_small_message(code), # reference TAG (derived from code)
                "error"   : str(err) if err else err, # this error to be logged, for DevOps
                "message" : msg # Long Message Description - for UI/UX
            },

            "data" : data,

            "time" : time.ctime()
        }




    def post(self, data : list, err : str = None, code : int = 200, msg : str = None) -> dict:
        """Format O/P of all GET Response"""

        return {
            "status" : {
                "code"    : code, # https://www.restapitutorial.com/httpstatuscodes.html
                "refer"   : self.get_small_message(code), # reference TAG (derived from code)
                "error"   : str(err) if err else err, # this error to be logged, for DevOps
                "message" : msg # Long Message Description - for UI/UX
            },

            "time" : time.ctime()
        }
