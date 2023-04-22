# -*- encoding: utf-8 -*-

"""
A Set of Administration APIs for UMS

A user may have some "ADMIN" rights, and thus they have higher
privileges to query the database - like getting the number of total
users in the database, or getting details of a user based on
username.
"""

from app.main.application._base_resource import BaseResource

class AdminAPI(BaseResource):
    """
    A List of ADMIN API for Controlling & Development

    A set of functionalities only available to ADMIN level users.
    The roles category is not yet planned for initial release,
    however the APIs are exposed to provide high-level information
    and testing purposes.
    """

    def __init__(self):
        super().__init__()

        # additional arguments that is accepted by the `AdminAPI`
        self.req_parser.add_argument("username", type = str, required = False)

        # database access repository/interfaces modules


    def get(self):
        return self.formatter.get("Hello World", code = 200)
