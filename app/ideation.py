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
        self.req_parser.add_argument("symbol", type = str, required = False, location = "args")
        self.req_parser.add_argument("symbols", type = str, required = False, location = "args")
        self.req_parser.add_argument("effective_date", type = str, required = False, location = "args")

    def get(self):
        if request.endpoint == "effective_date":
            options_chain = pd.concat([
                pd.read_sql(f"SELECT '{symbol}' AS symbol, * FROM {symbol}", self.engine)
                for symbol in self.args["symbols"].split(",")
            ], ignore_index = True)

            options_chain["expiry_date_dt"] = pd.to_datetime(options_chain["expiry_date"], format = "%Y-%m-%d")
            json = options_chain.sort_values(["expiry_date_dt"]).groupby("symbol")["expiry_date"].unique().to_dict()
            return self.formatter.get({k : json[k].tolist()[:2] for k in json.keys()})
        elif request.endpoint == "strike_price":
            symbol = self.args["symbol"]
            strike_prices = pd.read_sql(f"SELECT * FROM strike_prices WHERE symbol = '{symbol}'", self.engine)
            strike_prices["expiry_date"] = strike_prices[["expiry_date", "time"]].apply(lambda x : f"{x[0]} {x[1]}", axis = 1)
            strike_prices["expiry_date"] = pd.to_datetime(strike_prices["expiry_date"], format = "%Y-%m-%d %H:%M:%S.%f")

            return self.formatter.get(strike_prices[strike_prices["expiry_date"] == strike_prices["expiry_date"].max()]["strike_prices"].values.tolist())
        else:
            return redirect("/404")


class PlotController(BaseResource):
    def __init__(self):
        super().__init__()

        today = dt.datetime.now().date()
        self.engine = sa.create_engine(f"sqlite:////database/sqlite/nse-options-chain/{today}.db")

        self.req_parser.add_argument("symbol", type = str, required = True, location = "args")
        self.req_parser.add_argument("expiry_date", type = str, required = False, location = "args")
        self.req_parser.add_argument("strike_prices", type = str, required = True, location = "args")


    def get(self):
        date_ = self.args["expiry_date"].split("-")
        date_ = f"{date_[2]}-{date_[1]}-{date_[0]}"
        data = pd.read_sql(f"SELECT * FROM NIFTY", self.engine)

        data = data[
            (data["expiry_date"] == date_) &
            (data["Strike Price"].isin(list(map(int, self.args["strike_prices"].split(",")))))
        ]
        return {
            strike_price : data[["time", "PE OI Chg", "CE OI Chg"]].to_dict(orient = "list")
            for strike_price in self.args["strike_prices"].split(",")
        }
