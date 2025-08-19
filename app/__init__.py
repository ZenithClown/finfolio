# -*- encoding: utf-8 -*-

"""
REST API Application Endpoint Initialization & Entry Points
===========================================================

The module comparmentalize and initialize the entry points for the
REST API application, by dividing the applications into different
sections following DRY & SOLID principles.

The module uses PostgreSQL as the de-facto database, however the
:mod:`SQLAlchemy` ORM allows easy migrations and change the underlying
database flavor. Using :mod:`pydantic` for data validation and
serialization, while :mod:`fastapi` for the web framework.
"""

import os

# define application root path, for global reference
APP_ROOT_DIR = os.path.dirname(os.path.abspath(__file__))

# define application version, useful for alembic migrations control
__version__ = open(os.path.join(APP_ROOT_DIR, "VERSION"), "r").read()

# create project environment setup, different environment have a
# different control and objectives:
#   - development: development environment; with all debugging tools
#       enabled, also useful for model testing and validation
#   - production: production environment; with all debugging tools
#       disabled, and optimized for maximum performance
PROJECT_ENVIRONMENT = os.getenv("PROJECT_ENVIRONMENT", "development")
