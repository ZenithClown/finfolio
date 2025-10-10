# -*- encoding: utf-8 -*-

"""
Space to Initialize the Application & Configure Runtime Capabilities

Runtime capabilities, including init time option registrations are
configured for the application in the `__init__` file. This serves as
the base file for the application development, while the `app.py`
imports the required objects to run and setup the environment.

Typically, the `dash.Dash()` considers a name argument, but it is
better to set it as `dash.Dash(__name__)` while the magic variable
`__name__` considers the directory name (i.e., in this case is
RetailDashboard). The `name` also serves as a bridge between flask,
but for the product purpose, both the FlaskAPI and DASH-Plotly is
configured individually.
"""

import dash

# create the core object `app` and define it with any other
# optional/required parameters here
app = dash.Dash(
    __name__, # configure project name to define `__name__`
    meta_tags = [{"name" : "viewport", "content" : "width = device-width, initial-scale = 1"}]
)

# define a server object for manipulation
server = app.server

# import the layout variable, and initialize the application
from template.layout import layout
app.layout = layout
