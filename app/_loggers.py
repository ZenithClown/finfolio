# -*- encoding: utf-8 -*-

"""Considering the YAML Settings file as Logging Defination and other Parameters,
the File Exposes **4** different logging variables, that can be used `module-wide`
to log information according to their level and degree of severity."""

import yaml
import logging
import logging.config

from os.path import (
    join,
    abspath,
    dirname
)


def __getLoggerName__(logLevel : int):
    """Get the Name of the logger, as defiend in YAML based on `logLevel`"""

    return {
        logging.INFO     : "infoLogger",     # noqa: E203
        logging.ERROR    : "errorLogger",    # noqa: E203
        logging.DEBUG    : "debugLogger",    # noqa: E203
        logging.CRITICAL : "criticalLogger", # noqa: E203
        logging.WARNING  : "warnLogger",     # noqa: E203
    }.get(logLevel, __name__)


def __getLogger__(logLevel : int = logging.INFO):
    """Defination of a Logger-Functionality - can be used to Track User Sessions and Login Information"""

    # define logger using PyYAML
    with open(join(abspath(dirname(__file__)), "logger.yaml"), "r") as stream:
        config = yaml.safe_load(stream)
    
    logging.config.dictConfig(config)

    return logging.getLogger(__getLoggerName__(logLevel))


infoLogger     = __getLogger__(logLevel=logging.INFO)     # noqa: E203
errorLogger    = __getLogger__(logLevel=logging.ERROR)    # noqa: E203
debugLogger    = __getLogger__(logLevel=logging.DEBUG)    # noqa: E203
criticalLogger = __getLogger__(logLevel=logging.CRITICAL) # noqa: E203
warnLogger     = __getLogger__(logLevel=logging.WARNING)  # noqa: E203
