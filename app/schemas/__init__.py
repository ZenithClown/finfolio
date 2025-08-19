# -*- encoding: utf-8 -*-

"""
Pydantic Schemas for Finfolio | I/O Contracts
=============================================

The module uses the :mod:`pydantic` framework for data validation and
serialization, while :mod:`fastapi` for the web framework. The DRY
principle is typically violated when using the `pydantic` framework,
as the `sqlalchemy` models has a persistence mapping or lazy-loading
mechanism, while the pydantic schema are used for in-line validation
and serialization. This approach also provides field aliasing and
inherent security by hiding internal or auto-generated fields.

The seperation and keeping two copies of SQLAlchemy ORM and Pydantic
model validators avoids tight coupling betwwen the HTTP(s) boundary
and the database layer, providing scalability and maintainability.
"""

