# -*- encoding: utf-8 -*-

"""
Insert Records into a `finfolio` Table

A typical object oriented approach (todo) to insert records into
the table. Can use the `PRAGMA table_info('<table-name>')` to fetch
and bind the table schema dynamically.

@author:  Debmalya Pramanik
@version: v0.0.1
"""

import pandas as pd

def to_transactions(records : pd.DataFrame, engine : object, outfile : str) -> bool:
    records = records.copy() # enable deepcopy
    records.to_pickle(outfile, compression = "gzip")

    records = records[["AccountID", "trxDate", "trxType", "trxAmount", "trxDescOrig", "created_on"]] \
        .to_sql("ams.transactions", engine, if_exists = "append", index = False)
    
    return True
