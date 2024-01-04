# -*- encoding: utf-8 -*-

"""
The Skeleton File can Serve as a Starting Point for CLI Application

The skeleton file can serve as a backend for any debugging during the
development purpose. Later, this file can be safely removed, moved or
renamed based on the requirement.
"""

import os
import yaml
import sqlite3

import logging.config
from pathlib import Path


class NoConsoleFilter(logging.Filter):
    def filter(self, record : logging.LogRecord) -> bool:
        # filter logs from console based on below conditions, example
        # logger.info("no-console. This will not be logged into console")
        return not (record.levelname == "INFO") & ("no-console" in record.msg)


def setupLogging(logFile : str, logLevel : int = 0, appType : str = "streamlit"):
    """
    Setup Basic Logging using a Log-Level

    The function returns the logging object as `root` that can be
    used widely in the module. To overwrite, set a log level with an
    accepted integer value as defined in documentations.

    A streamlit application has its own set of logging configuration,
    implemented at different level which is defined in `config.toml`
    (https://docs.streamlit.io/library/advanced-features/configuration).
    In addition, streamlit has a in-built vast logging/debugging
    feature, thus file/console level logging is required only in the
    legacy-cli application.
    """

    if appType == "cli":
        cur_dir = os.path.dirname(os.path.abspath(__file__))
        config_ = os.path.join(cur_dir, "logger.yaml")
        with open(config_, "r") as f:
            log_cfg = yaml.safe_load(f.read())

            # add default log file name externally
            # https://stackoverflow.com/a/62152596/6623589
            log_cfg["handlers"]["fileHandler"]["filename"] = logFile
            logging.config.dictConfig(log_cfg)

    else:
        logging.basicConfig(format = "%(asctime)s - %(name)s - %(levelname)s - %(message)s", filename = logFile)

    logger = logging.getLogger("root")
    logger.setLevel(logLevel)    

    return logger


def setupHome(homepath : str = os.path.join(Path.home(), "pOrgz")):
    """
    Set Home Directory under a Custom Directory

    The home directory is typically User's Path `~/pOrgz` in *nix or
    `${HOME}/pOrgz` in Windows, however based on user preference this
    can be selected as any directory. The function creates the
    directory if does not exists already.
    """

    os.makedirs(homepath, exist_ok = True)
    return homepath


def getOrFetchDB(dbFile : str):
    con = sqlite3.connect(dbFile)
    return con, con.cursor()
