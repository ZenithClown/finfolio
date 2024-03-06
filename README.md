<h1 align = "center">
  Finance Portfolio Management DB Schema <img src = "./logo.png" height = "190" width = "175" align = "right" /><br>
  <code>finfolio</code><br>
  <a href = "https://www.linkedin.com/in/dpramanik/"><img height="16" width="16" src="https://unpkg.com/simple-icons@v3/icons/linkedin.svg"/></a>
  <a href = "https://github.com/ZenithClown"><img height="16" width="16" src="https://unpkg.com/simple-icons@v3/icons/github.svg"/></a>
  <a href = "https://gitlab.com/ZenithClown/"><img height="16" width="16" src="https://unpkg.com/simple-icons@v3/icons/gitlab.svg"/></a>
  <a href = "https://www.researchgate.net/profile/Debmalya_Pramanik2"><img height="16" width="16" src="https://unpkg.com/simple-icons@v3/icons/researchgate.svg"/></a>
  <a href = "https://www.kaggle.com/dPramanik/"><img height="16" width="16" src="https://unpkg.com/simple-icons@v3/icons/kaggle.svg"/></a>
  <a href = "https://app.pluralsight.com/profile/Debmalya-Pramanik/"><img height="16" width="16" src="https://unpkg.com/simple-icons@v3/icons/pluralsight.svg"/></a>
  <a href = "https://stackoverflow.com/users/6623589/"><img height="16" width="16" src="https://unpkg.com/simple-icons@v3/icons/stackoverflow.svg"/></a>
</h1>

<div align = "justify">

The application uses [**`SQLite`**](https://sqlite.org/index.html) as the de facto database, which is a lightweight, and a
serverless, self-contained full-featured database engine. The schema definations, queries and views are written in SQL
format and is chosen over _query builder_ or a full-fldged _ORM_ since the database is hosted serverlessly and is encrypted
using a hasing algorithm - thus minimizing the risk of data leak ([more information](https://www.youtube.com/watch?v=x1fCJ7sUXCM)
on choosing the right method to communicate with a database).

## Adapted Notations

The database module controls both `ams` and `ums` module and any related table is prefixed by `ams.*` or `ums.*` respectively.
In addition, master tables are prefixed as `mw*` while the transactional tables are referenced as `trx*`, and the table names
are written in `camelCase` format. New developers are requested to follow the same convention, or the PR will be rejected.
In addition, please note the following:
  * `COMPOSITE_KEY` is avoided in tables, and for transactional tables the default primary key is set as
    `_id(sa.Integer, primary_key = True, autoincrement = True)`, and
  * All `date` is formatted as `YYYY-MM-DD` while `datetime` is formatted as `YYYY-MM-DD HH:MM:SS.SSS` formatting.

Since there are different types of account types which have unrelated properties, like savings account typically has a branch
while a demat/mutual fund account does not have, but they have portfolio information and service providers. For this, an
"extended table" are used with the prefix `ext*` to denote an extension typically of a master table. By defination, the extended
table defination is in the same file as the primary table.

The key notations (PK, FK, and Composite Key) used in the system are designed considering the best use cases of both
[OLAP and OLTP](https://www.youtube.com/watch?v=iw-5kFzIdgY), and thus tables with primary key defined as `_id` are specifically
designed to retreive and perform analytical function faster. In addition, if a composite key mapping is required, then a `RecordHash`
is generated (to be implemented) so that each record can be uniquely identified and duplicate records can be deleted using
simple `COUNT(*) GROUP BY RecordHash` logic.

SQLite uses a more general dynamic type system, and thus does not have an in-built `datetime` data type (among others) and all is stored
as `TEXT`, for more information check the [data types](https://www.sqlite.org/datatype3.html) documentation. Strict database design is
avoided, and may be incorporated in the future.

## Getting Started

A standard structure ([help](https://www.geeksforgeeks.org/structure-of-database-management-system/)) is develop to structure
the [**`database`**](./database/) and is seperated into the following sub-directories:
  * [`models`](./database/models) - contains master and transaction tables definations,
  * [`views`](./database/views/) - definations of table views derived from masters and transactional tables, and
  * [`queries`](./database/queries/) - parameterized queries to interact with the database.

By convention, the name of the file (in `models`, `views`) is same as that of the table/view name defined within, while a more descriptive name is associated with the `queries` statements. In addition, for any static content for the master tables the data is populated using `INSERT INTO *` statement associated in the same file as the master table.

</div>
