# -*- encoding: utf-8 -*-

"""
Developer Usage: Defination of Base Model Class

The base model class file can be inherited by models to typically
store common functions. Usage:

```python
from sqlalchemy.ext.declarative import declarative_base

_base = declarative_base()

class BaseModel(_base):
    pass
```

The base model class file binds over the engine for providing
additional utility functions define below.
"""

class BaseModel(object): # TODO: replace with `isinstance(_base)`
    """
    Base Model Class File Defination

    The base function is defined under the `api/models/_base.py` file
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
