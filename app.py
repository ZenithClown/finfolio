# -*- encoding: utf-8 -*-

"""
A Simple Dashboard Template Build for Visualization of AI-ML Projects

Visualization is an important part of an AI-ML project and this
template is built to simply visualize different components. The app
can be used to produce charts and visualizations as a production
built layer for any model.

The defined file `app.py` is the entry point for a production level
dashboard application. The dashboard can be used and/or customized as
per need from the `application` interface menu. The application
provides the following configurations:

    1. Colors: All the colors used in the application is available
       under `config/colors.yaml` and each component is defined.
    2. Application Name: The name of the application is `__name__`
       which is the name of the parent directory of `app` object.

In addition, certain parameters and configurations are defined under
environment variable. A simple `.bash_profile` is available for quick
setup of the application in an `*nix* system, however for `windows`
users each variable has to be seperately configured.
"""

import os # miscellaneous os interfaces
import yaml # for manipulating yaml files

from template import app # ! configure `app.__init__`

if __name__ == "__main__":
    app.run_server(
        # run the app in default port of 8050,
        # or define the appropriate environment variables
        port = os.getenv("DASH_APPLICATION_PORT", 8050),

        # run the app in the localhost (be default), or
        # set the appropriate environment variable
        host = os.getenv("DASH_APPLICATION_HOST", "localhost"),

        # under development environment set `debug = True`
        debug = True
    )
