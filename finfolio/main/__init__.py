# -*- encoding: utf-8 -*-

"""Main Package for REST-API Management"""

from flask import Flask
from flask_bcrypt import Bcrypt # hasing algorithms
from flask_sqlalchemy import SQLAlchemy

# ? namespace:: internal module imports
from finfolio.main.config import * # noqa: F401, F403 # pyright: ignore[reportMissingImports]

# ! 🎉 Primary `db` Object for All Database Interactions
db = SQLAlchemy(model_class = BaseModel)
flask_bcrypt = Bcrypt() # bcrypt hashing utilities

def create_app(config_name : str):
    """
    Creates a Flask Application by Invoking `Flask(__name__)` Command

    Flask is a lightweight WSGI web application framework. The module
    uses the functional approach to define and configure the flask
    application for providing REST-API services. For more information
    on Flask: https://github.com/pallets/flask.

    The project is structred using the template repository concept
    available at: https://github.com/ZenithClown/flask-docker-template.

    :type  config_name: str
    :param config_name: Configuration for setting up the environment
        for the application. Currently, only the `dev` environment is
        defined. For more, check: https://tinyurl.com/flask-app-config.
    """

    app = Flask(__name__)
    app.config.from_object({
        "dev" : DevelopmentConfig
    }[config_name])

    # initialize the db, and return the application
    db.init_app(app)
    flask_bcrypt.init_app(app)

    return app
