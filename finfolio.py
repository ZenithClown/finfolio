# -*- encoding: utf-8 -*-

"""
FINFOLIO (Finance Portfolio) Application Main File

The file serves as the main file to start and serve the project
to end user, and integrates backend with frontend.
"""

from backend import USER_HOME_DIRECTORY
import backend.app.config.skeleton as skeleton

if __name__ == "__main__":
    skeleton.setupHome(USER_HOME_DIRECTORY) # ? initialize project path
