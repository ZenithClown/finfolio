# -*- encoding: utf-8 -*-

"""All Configurations for FinFolio-DB"""

import os

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
