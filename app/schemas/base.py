# -*- encoding: utf-8 -*-

"""
Base Configuration Model for Pydantic Schema Validators
=======================================================

The base model should only be used for internal purposes, or for type
checking. The model is  defined in two parts - (I) the base model from
the schema, useful for client input validation and (II) the ORM model
which maps the schema model, typically useful for output response.

.. code-block:: python

    from app.schemas.base import BaseSchema

    print(isinstance(ModelSchema, BaseSchema))
    >> True # all models are subclasses of BaseSchema

    print(isinstance(OutModelSchema, ORMSchema))
    >> True # output models are also subclass of ORMSchema

The ORM schema is modeled for :mod:`SQLAlchemy` ORM instances and
looks for data from attribute standpoint while the base schema always
expects data from dictionary standpoint.

.. code-block:: python

    # dictionary interface for schema model
    indata = {"name" : "John Doe", "age" : 25}
    BaseSchema.model_validate(indata) # works, returns instance
    >> BaseSchema(name='John Doe', age=25)

    # attribute interface for ORM model
    insess = session.get(user, 1)
    BaseSchema.model_validate(insess) # fails without model attributes
    >> pydantic_core._pydantic_core.ValidationError: ...

    # however, we can set the session attribute directly
    ORMSchema.model_validate(insess) # works, returns instance
    >> ORMSchema(name='John Doe', age=25)

Typically, the base and ORM schema is defined such that all the
requests are handled by the ``BaseSchema`` while the ``ORMSchema`` is
for any response to the handler.
"""

from pydantic import BaseModel

class BaseSchema(BaseModel):
    pass # use default attributes


class ORMSchema(BaseModel):
    model_config = {"from_attributes": True}
