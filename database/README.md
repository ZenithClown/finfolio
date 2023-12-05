<h1 align = "center">Database Module</h1>

<div align = "justify">

The application uses `SQLite` as the de facto database, which is a lightweight, and a serverless, self-contained full-featured database engine. An ORM structure is developed for all the tables, views which provides necessary security from external attacks. The ORM is developed using SQL-Alchemy which is an open-source obejct relation mapper toolkit for `python` programming.

## Adapted Notations

The database module controls both `ams` and `ums` module and any related table is prefixed by `ams_*` or `ums_*` respectively. In addition, master tables are prefixed as `*_mw*` while the transactional tables are referenced as `*_trx*`, and the table names are written in `camelCase` format. New developers are requested to follow the same convention, or the PR will be rejected. In addition, please note the following:
  * `COMPOSITE_KEY` is avoided in tables, and for transactional tables the default primary key is set as `_id(sa.Integer, primary_key = True, autoincrement = True)`, and
  * All `date` is formatted as `YYYY-MM-DD` while `datetime` is formatted as `YYYY-MM-DD HH:MM:SS.SSS` formatting.

SQLite does not have an in-built `datetime` data type and all is stored as `TEXT`, for more information check the [data types](https://www.sqlite.org/datatype3.html) documentation. Strict database design is avoided, and may be incorporated in the future.

</div>
