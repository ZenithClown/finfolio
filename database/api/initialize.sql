/********************************************************************
Initialization Statement for API Schema Namespace for Project FINFOLIO

The API schema namespace exposes all the RESTful API endoints using
the PostgREST library and thus reduces external module support (like
`prisma` for nodejs or `flask` for python based application) to
develop and maintain ORM for the tables - keeping the code base simple
and easy to manage; given the simple use case.

The API schema will not hold any table by default and all the SQL
based objects (functions, views, etc.) are publically exposed in the
API and the Swagger UI is available at `/swagger` endpoint.

Copywright © [2024] Debmalya Pramanik (ZenithClown)
********************************************************************/

\i database/api/views/meta.sql
