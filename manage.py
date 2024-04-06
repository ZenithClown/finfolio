# -*- encoding: utf-8 -*-

"""API Management & Server Running Module"""

import os
from finfolio import app

if __name__ == "__main__":
    app.run(
        debug = True, # run the application in debug mode
        port = os.getenv("port", 5000), # run the application on default 5000 Port
        # localhost is required to run the code from m/c
        # else, 0.0.0.0 can be used for docker container
        host = os.getenv("host", "0.0.0.0") # define host, as required
    )
