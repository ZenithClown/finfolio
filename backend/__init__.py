# -*- encoding: utf-8 -*-

"""
The Server Class (i.e. the backend) for the FinFolio-DB Application

The server module presents one-stop solutions for backend jobs, like
write/update/delete operation on the tables. Check individual section
for more information on usages.

@author:  nxLogics, Debmalya Pramanik
@version: v0.0.1
"""

def execute(statement : str, engine : object, params : tuple = tuple()) -> bool:
    """
    An Function to Execute any Arbitary SQL Statement with Paramaters

    The `engine` object is an instance of the `sqlite3.connect()` and
    the function simply executes like:

    ```python
    import sqlite3 as db

    statement = "" # statement, or `open(file).read()` like
    executed_ = execute(statement, engine = db.connect("data.db"))
    ```

    :type  statement: str
    :param statement: The SQL statement, may be parameterized with `?`
        or a simple statement like `SELECT * FROM table`, and can be
        parameterized like `SELECT * FROM table WHERE feature = ?`.
        SQLite uses "atomic commit" approach, and only allows one
        statement execution at a time.

    :type  engine: object
    :param engine: An instance of the `sqlite3.connect()` to establish
        connection and execute statement.

     :type  params: tuple
     :param params: Optionally pass the parameters in case of a
        parametric query.
    """

    engine.execute(statement, params)
    engine.commit() # commit to database
    return True


def executescript(statement : str, engine : object) -> bool:
    """
    An Function to Execute Multiple SQL Statements

    The `engine` object is an instance of the `sqlite3.connect()` and
    the function simply executes like:

    ```python
    import sqlite3 as db

    statement = "" # statement, or `open(file).read()` like
    executed_ = execute(statement, engine = db.connect("data.db"))
    ```

    :type  statement: str
    :param statement: Multiple SQL statements can be executed using
        the `engine.executescript()` command, however this does not
        allow parameteric contents. More information:
        https://stackoverflow.com/a/34806782/6623589

    :type  engine: object
    :param engine: An instance of the `sqlite3.connect()` to establish
        connection and execute statement.
    """

    engine.executescript(statement)
    engine.commit() # commit to database
    return True

# -*- encoding: utf-8 -*-

"""
The Backend Application Layer for the **`finfolio`** Repository

The backend application layer seperates the application from the
presentation layer (frontend) and helps in maintaining the DRY
strategy. The code is OOP oriented, and uses SQLAlchemy.
"""

import os
import pathlib

APP_ROOT_DIRECTORY = os.path.abspath(os.path.dirname(__file__))
USER_HOME_DIRECTORY = os.path.join(pathlib.Path.home(), ".pOrgz")

# ? the app version is defined and maybe used in the routes
__version__ = open(os.path.join(APP_ROOT_DIRECTORY, "VERSION"), "r").read()
