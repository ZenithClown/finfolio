# -*- encoding: utf-8 -*-

"""
Initialization and Main File for FINFOLIO Backend Communication

Serves as the starting point for the backend application for the
personal finanical portfolio management application. The main file
should be as easy as to invoke like:

```shell
$ python main.py
```

The database connection, engine and session object is defined in the
main and is imported as is required, and is not set to initialization.
"""

import sqlalchemy as sa

from . import USER_HOME_DIRECTORY

engine = sa.create_engine(f"sqlite:///{USER_HOME_DIRECTORY}/finfolio.db", echo = True)
session = sa.orm.sessionmaker(autoflush = False, autocommit = False, bind = engine)