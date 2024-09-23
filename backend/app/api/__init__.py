# -*- encoding: utf-8 -*-

"""
SQLAlchemy Application Programming Interface (API) Layer for FINFOLIO

The API follows a typical MVC (Model-View-Controller) archtecture to
communicate with the underlying SQLite database as the backend. The
directory is designed as follows:
    > `models` - the database structure, i.e., typically table
        defination, relationships and data retreival logic,
    > `views` - restructures the model's output into a standard JSON
        format and passed to controller to serve request, and
    > `controller` - the component that enables the interconnection
        between the `views` and `models`; also serves as the default
        layer to handle all types of user requests through routes.

Typically MVC framework is not a hard-fast rule as in Django (which
is perhaps the most scalable and widely used web-framework), however
the API layer is defined such that it can be easily scaled.
"""
