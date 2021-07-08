# -*- encoding: utf-8 -*-

import os

basedir = os.path.abspath(os.path.dirname(__file__))
DB_NAME = os.getenv("DATABASE_NAME", "InspirigenceWorks")

# convigure below line(s) to get database from environment variable
# local_base = os.getenv("DATABASE_URL", f"sqlite:///{basedir}") # uncomment for using SQLite
username    = "dPramanik"
password    = "paRam#@123"
server_addr = "localhost"
local_base = os.getenv("DATABASE_URL", f"mysql+pymysql://{username}:{password}@{server_addr}") # uncomment for using SQLite

class Config:
    """Base Configuration Class - Inherited by Others"""

    DEBUG      = False
    SECRET_KEY = os.getenv("SECRET_KEY", "my_secret_key")


class DevelopmentConfig(Config):
    """Development Configuration: invoke this using config_name = dev"""

    DEBUG = True # This is a development server.

    # set database
    SQLALCHEMY_DATABASE_URI = f"{local_base}/{DB_NAME}"
    SQLALCHEMY_TRACK_MODIFICATIONS = False


class TestingConfig(Config):
    """Testing Environment: invoke this using config_name = test"""

    DEBUG   = True
    TESTING = True

    # set database
    SQLALCHEMY_DATABASE_URI = f"{local_base}/{DB_NAME}"

    PRESERVE_CONTEXT_ON_EXCEPTION  = False
    SQLALCHEMY_TRACK_MODIFICATIONS = False


class ProductionConfig(Config):
    """Production Environment: invoke this using config_name = prod"""

    DEBUG = False

    # uncomment the line below to use configure database
    # SQLALCHEMY_DATABASE_URI = local_base

config_by_name = dict(
        dev  = DevelopmentConfig,
        test = TestingConfig,
        prod = ProductionConfig
    )

key = Config.SECRET_KEY