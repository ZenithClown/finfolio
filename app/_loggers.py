# -*- encoding: utf-8 -*-

"""Considering the YAML Settings file as Logging Defination and other Parameters,
the File Exposes **4** different logging variables, that can be used `module-wide`
to log information according to their level and degree of severity."""

import yaml
import logging
import logging.config

try:
    import importlib.resources as pkg_resources
except ImportError:
    # Try backported to PY<37 `importlib_resources`.
    import importlib_resources as pkg_resources


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


    # https://stackoverflow.com/questions/6028000/
    # https://stackoverflow.com/questions/56688232/
    loggerFile = pkg_resources.open_text('logger.yaml')

    # define logger using PyYAML
    config = yaml.safe_load(loggerFile.read())
    logging.config.dictConfig(config)

    return logging.getLogger(__getLoggerName__(logLevel))


infoLogger     = __getLogger__(logLevel=logging.INFO)
errorLogger    = __getLogger__(logLevel=logging.ERROR)
debugLogger    = __getLogger__(logLevel=logging.DEBUG)
criticalLogger = __getLogger__(logLevel=logging.CRITICAL)
warnLogger     = __getLogger__(logLevel=logging.WARNING)
