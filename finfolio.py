# -*- encoding: utf-8 -*-

"""
FINFOLIO (Finance Portfolio) Application Main File

The file serves as the main file to start and serve the project
to end user, and integrates backend with frontend.
"""

import time
import prettify # pyright: ignore[reportMissingImports]

from backend.main import engine
from backend import USER_HOME_DIRECTORY

from backend.app.api.models import * # noqa: F401, F403 # pyright: ignore[reportMissingImports]
from backend.app.api.base import model

import backend.app.config.skeleton as skeleton


if __name__ == "__main__":
    prettify.textAlign("Welcome to FINFOLIO Start Module")
    prettify.textAlign("================================")

    print(f"{time.ctime()} : Setting Application Home at - {USER_HOME_DIRECTORY}", end = "\n\n")
    skeleton.setupHome(USER_HOME_DIRECTORY) # ? initialize project path
    model.metadata.create_all(engine)
