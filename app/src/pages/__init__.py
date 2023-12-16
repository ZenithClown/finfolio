# -*- encoding: utf-8 -*-

"""
Customize the Pages with Name/Icons and Initialize

By default, `streamlit` uses the name of the file as the page name in
the navigation window. However, this can be customized by using the
`PAGE_NAV` variable which is set to run from the `pages/__init__.py`
file and in addition, each page does not require an `if __name__`
block to run.

@author:  Debmalya Pramanik
@copywright: pOrgz <https://github.com/pOrgz-dev>
"""

from .create import create

PAGE_MAP = {
    "🎉 Create A/C" : create
}

__all__ = ["PAGE_MAP"]
