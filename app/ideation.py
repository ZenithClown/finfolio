# -*- encoding: utf-8 -*-

"""
API Ideation Phase is Tested using IDEATION File

This is a ideation/main file for controlling the application in
development and initial dashboard build. Currently, live market data
testing is pending, and thus no database is yet defined.

TODO design database and understand how to insert data in real-time
TODO create different modules for data processing and storage
! Only a CONTROLLER is defined that controlls every aspect of code
"""

import pandas as pd
import datetime as dt
import sqlalchemy as sa

from flask import jsonify
from flask import request
from flask import redirect

from app.main.config import local_base
from app.main.application._base_resource import BaseResource

class SymbolList(BaseResource):
    # return a list of avaiable symbol to download

    def __init__(self):
        super().__init__()

    
    def get(self):
        return self.formatter.get([
            "NIFTY",
            "BANKNIFTY"
        ])


class OptionsChain(BaseResource):
    # options chain main class file controls and provides all details

    def __init__(self):
        super().__init__()

        today = dt.datetime.now().date()
        self.engine = sa.create_engine(f"sqlite:////database/sqlite/nse-options-chain/{today}.db")

        # * add argument parser for `symbols`
        self.req_parser.add_argument(
            "symbols", type = str, required = True, location = "args",
            help = "List of Symbols in CSV (example `sym1,sym2`)"
        )

        self.req_parser.add_argument(
            "effective_date", type = str, required = False, location = "args",
            help = "Effective Date in `DD-MM-YYYY` Format"
        )

        # * parse input arguments into correct format
        self.symbols = self.args["symbols"].split(",")

        try:
            self.effective_date = dt.datetime.strptime(self.args["effective_date"], "%d-%m-%Y")
        except TypeError:
            self.effective_date = None

    def get(self):
        options_chain = pd.concat([
            pd.read_sql(f"SELECT '{symbol}' AS symbol, * FROM {symbol}", self.engine)
            for symbol in self.symbols
        ], ignore_index = True)
        options_chain["expiry_date_dt"] = pd.to_datetime(options_chain["expiry_date"], format = "%Y-%m-%d")

        if request.endpoint == "effective_date":
            json = options_chain.sort_values(["expiry_date_dt"]).groupby("symbol")["expiry_date"].unique().to_dict()
            return self.formatter.get({k : json[k].tolist() for k in json.keys()})
        elif request.endpoint == "strike_price":
            pass
        else:
            return redirect("/404")
