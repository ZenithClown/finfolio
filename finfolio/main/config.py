# -*- encoding: utf-8 -*-

"""All Configurations for FinFolio-DB"""

import os
import time

import datetime as dt

from uuid import UUID
from decimal import Decimal
from typing import Iterable

from flask_restful import reqparse, Resource

# from finfolio import __version__

class BaseConfig(object):
    """Base Configuration Class - Inherited by Others"""

    DEBUG   = False
    TESTING = False

    # TODO: consider the use of secrets, password salting
    # https://flask-security-too.readthedocs.io/en/stable/quickstart.html
    SECRET_KEY = os.getenv("SECRET_KEY", "my_secret_key")

    # ? not using the flask-sqlalchemy event system, thus
    # https://stackoverflow.com/a/33790196/6623589
    SQLALCHEMY_TRACK_MODIFICATIONS = False


class DevelopmentConfig(BaseConfig):
    """Development Configuration - Invoke using `config_name = dev` Key"""

    DEBUG = True # all debugs are logged into cosole

    # ? database configurations are defined here, may use config
    SQLALCHEMY_DATABASE_URI = "sqlite:///C://Users//debmalya//pOrgz//database.db"


class BaseModel(object):
    """
    Developer Usage: Defination of Base Model Class

    The base model class file can be inherited by models to typically
    store common function logics, like dunder methods. The base
    function is defined under the `api/models/config.py` file
    and is used as a wrapper over the `isinstance(create_engine())`
    to provide a common space for shared functionalities.

    In Flask-SQLAlchemy Extention, the model class is used as a
    argument like:

    ```python
    # https://flask-sqlalchemy.palletsprojects.com/en/2.x/customizing/
    from flask_sqlalchemy import SQLAlchemy

    db = SQLAlchemy(model_class = ModelClass)
    ```

    The base model should be simple enough to be used like:

    ```python
    class ExampleModel(db):
        __tablename__ = "my-table"
        ...

    class ExampleService(object):
        ...

        def get(self, ...) -> dict:
            ...

            records = ExampleModel.query.all()
            return [record.__to_dict__() for record in records]
    ```

    The base model will also expose the general dunder methods
    `__repr__` and `__str__` if not already defined.
    """

    def __get_features__(self):
        return [ c.key for c in self.__table__.columns ]


    def __get_dtypes__(self):
        return { c.key : str(c.type) for c in self.__get_features__() }


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

            "data" : data, # returns a `iterable` of records
            "time" : time.ctime(),
            "version" : None
        }




    def post(self, msg : str, err : str = None, code : int = 200) -> dict:
        """Format O/P of all GET Response"""

        return {
            "status" : {
                "code"    : code, # https://www.restapitutorial.com/httpstatuscodes.html
                "refer"   : self.get_small_message(code), # reference TAG (derived from code)
                "error"   : str(err) if err else err, # this error to be logged, for DevOps
                "message" : msg # Long Message Description - for UI/UX
            },

            "time" : time.ctime(),
            "version" : None
        }


class BaseResource(Resource):
    """
    Developer Usage: Resource Base Defination for all Controllers

    The base resource is a utilitity provided for all the controllers
    defined in the `./finfolio/main/controllers/*.py` section. This
    reduces overhead and code duplicacy.

    ```python
    from finfolio.main.config import BaseResource
    ...

    class ExampleController(BaseResource):
        ...

        def __init__(self) -> None:
            ...

            super().__init__()

            self.req_parser.add_argument("name", **kwargs)
            ...


        def get(self) -> dict:
            ...

            return self.formatter.get(data)
    ```

    Check individual sections, functions, and arguments for more
    informations on usage.
    """

    def __init__(self) -> None:
        self.formatter  = ResponseFormatter() # parse and format responses
        self.req_parser = reqparse.RequestParser() # parse incoming params
    

    @property
    def args(self) -> object:
        """
        Request Parser Arguments for all Incoming Parameters

        The REST-API only accepts named arguments for querying, like:
        `.../endpoint?username=username` for fetching details,
        instead of arguments in URL like `../endpoint/username` as in
        some adopted REST-API usecases.
        """

        return self.req_parser.parse_args()
    

    def __to_dict__(self, records : Iterable, columns : Iterable) -> Iterable[dict]:
        """
        Converts a Table View and Returns Parsed Results as a List of JSON/DICT

        The views table only allows GET operations on a given table
        views. The table views are defined under `app/main/models/views`
        and each specific table is imported for further analysis.

        :type  records: array-like
        :param records: A set of records obtained using `query.all()`
            functionality. This is a `row` type object, which is JSON
            serialized in this function.

        :type  columns: array-like
        :param columns: List of column names, available as `.columns`
            arguments on a table object.
        """

        records_ = [] # serialized JSON object
        for row in records:
            di = dict() # intermediate records
            for column, value in zip(columns, row):
                # TODO optimize such that `Decimal` is auto-converted to `float`
                if isinstance(value, Decimal):
                    value = float(value)

                # TODO optimize/define `UUID` for columns using `uniqueidentifier`
                if isinstance(value, UUID):
                    value = str(value)

                # TODO also update for any date/time/datetime type
                if (
                    isinstance(value, dt.datetime)
                    or isinstance(value, dt.datetime.date)
                    or isinstance(value, dt.datetime.time)
                ):
                    value = str(value)

                di[column.key] = value
            records_.append(di)

        return records_
