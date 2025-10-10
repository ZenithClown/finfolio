# -*- encoding: utf-8 -*-

"""
Alembic Migrations Toolkit for Personal Finance Management Application
======================================================================

Project-local helpers and program entry points for database migrations
for :mod:`SQLAlchemy`. The sub-package complements the :mod:`alembic`
to perform CLI operations for database migrations (for example 
CI/CD hooks or one-off administrative tasks).

Submodule Overview
------------------

The script ``alembic.ini`` centralizes the discovery and migration
script location. In addition, exposes convinient entry points or
functions for ``upgrade``, ``downgrade`` and incspect current revisions.

Module Quickstart
-----------------

The following commands are available for the ``alembic`` command line
tool:

.. code-block:: bash

    $ python -m alembic upgrade head
    $ python -m alembic downgrade
    $ python -m alembic revision --autogenerate

Check the api version note and changelogs for more details and changes
to the project. The project uses PostgreSQL as the de-facto backend
database and hosted by the enduser.
"""

