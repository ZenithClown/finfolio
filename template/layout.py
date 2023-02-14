# -*- encoding: utf-8 -*-

"""
Control the Application Layout

The dash application layout is controlled by `app.layout` paramter,
and all the settings and configurations are defined here. The setting
is kept seperate such that the code is unaltered and only the layout
can be taken care by a developer.

TODO there are models/libraries like `dash-bootstrap-templates`
(https://pypi.org/project/dash-bootstrap-templates/) which can be
used, or external assets can be configured from the `assets` as
in https://dash.plotly.com/external-resources
"""

from dash import (
    dcc, # dash_core_components is now part of `dash`
    html, # dash_html_components is now part of `dash`
)

layout = html.Div("Hello World!")
