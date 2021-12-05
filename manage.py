# -*- encoding: utf-8 -*-

"""API Management and Server Running Module"""

import os
from flask_restful import Api

from app.main import (
        db, # SQLAlchemy Connector dB Object
        create_app
    )

# setting the environment
from dotenv import load_dotenv # Python 3.6+
load_dotenv(verbose = True) # configure .env File or set Environment Variables

app = create_app(os.getenv("PROJECT_ENV_NAME") or "dev") # check config.py

# adding favicon to flask-docker-template
# all application does have a favicon, and flask_restful
# also supports adding an favicon
# https://flask.palletsprojects.com/en/2.0.x/patterns/favicon/
# https://stackoverflow.com/a/48386934/6623589
# However, in most RESTFUL Design, favicon might be unnecessary
# but, if not defined the following error is raised:
# <host> - - [<date time>] "←[33mGET /favicon.ico HTTP/1.1←[0m" 404 -
# favicon.jpeg is collected from https://icon-library.com/icon/icon-www-6.html
# JPEG file is present in static and ico file is generated using https://icoconvert.com/
@app.route('/favicon.ico')
def favicon():
    # use os.path.join() syntax if not using static directory
    # like os.path.join(".", "static")
    return send_from_directory("static", "favicon.ico", mimetype = "image/vnd.microsoft.icon")

api = Api(app)

### --- List of all Resources --- ###
# included application layer
# controller moved to application/controller
from app.main.application import * # import all controllers

# a demo link is provided, delete/uncomment the controller
# this controller is set from app/main/controller/hello_world.py
# also remove app/main/controller/__init__.py
api.add_resource(HelloWorld, "/") # hello-world endpoint

if __name__ == "__main__":
    app.run(
        port = os.getenv("port", 5000), # run the application on default 5000 Port
        # localhost is required to run the code from m/c
        # else, 0.0.0.0 can be used for docker container
        host = os.getenv("host", "0.0.0.0") # define host, as required
    )
