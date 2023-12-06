<h1 align = "center">Database Module</h1>

<div align = "justify">

The application uses `SQLite` as the de facto database, which is a lightweight, and a serverless, self-contained full-featured database engine. The schema definations, queries and views are written in SQL format and is chosen over _query builder_ or a full-fldged _ORM_ since the database is hosted serverlessly and is encrypted using a hasing algorithm - thus minimizing the risk of data leak ([more information](https://www.youtube.com/watch?v=x1fCJ7sUXCM) on choosing the right method to communicate with a database).

## Adapted Notations

The database module controls both `ams` and `ums` module and any related table is prefixed by `ams.*` or `ums.*` respectively. In addition, master tables are prefixed as `*mw*` while the transactional tables are referenced as `*trx*`, and the table names are written in `camelCase` format. New developers are requested to follow the same convention, or the PR will be rejected. In addition, please note the following:
  * `COMPOSITE_KEY` is avoided in tables, and for transactional tables the default primary key is set as `_id(sa.Integer, primary_key = True, autoincrement = True)`, and
  * All `date` is formatted as `YYYY-MM-DD` while `datetime` is formatted as `YYYY-MM-DD HH:MM:SS.SSS` formatting.

SQLite does not have an in-built `datetime` data type and all is stored as `TEXT`, for more information check the [data types](https://www.sqlite.org/datatype3.html) documentation. Strict database design is avoided, and may be incorporated in the future.

## Getting Started

A standard structure ([help](https://www.geeksforgeeks.org/structure-of-database-management-system/)) is develop to structure the **`database`** and is seperated into the following sub-directories:
  * `models` - contains master and transaction tables definations,
  * `models/views` - definations of table views derived from masters and transactional tables, and
  * `queries` - additional important queries to interact with the database.

By convention, the name of the file (in `models`, `views`) is same as that of the table/view name defined within, while a more descriptive name is associated with the `queries` statements. In addition, for any static content for the master tables the data is populated using `INSERT INTO *` statement associated in the same file as the master table.

</div>
