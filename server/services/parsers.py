# -*- encoding: utf-8 -*-

"""
Raw Files/Data Parser Module

A set of functions defined to parse raw files like csv,pdf and
typically return a dataframe (`pd.DataFrame`) to be inserted into the
data tables.

@author:  Debmalya Pramanik
@version: v0.0.1
"""

import numpy as np
import pandas as pd

def sbi(filepath : str, filetype : str = "excel") -> pd.DataFrame:
    """
    Read and Parse Transaction File for a SBI Account

    The "State Bank of India (SBI)" is a major banking service in the
    country, and as an individual there is a provision to download
    statements in csv/pdf format. The function reads the statements
    and return a dataframe as per the "ams.transactions" table
    defination. However, the function only returns a raw view of the
    table, while an external function is required for cosmetics.

    :type  filepath: str
    :param filepath: Complete filepath, raises "FileNotFoundError" if
        not available. Recommended to send file paths using `os.path`
        format to globalize.

    :type  filetype: str
    :param filetype: Type of the file, defaults to 'excel'. Currently,
        only 'excel' file is supported, and raises an error
        "NotImplementedError" if filetype is not defined.
    """

    records = pd.read_excel(
        filepath,
        # TODO: parameterize the `pd.read_*` with kwargs
        skiprows = 1, header = None,
        # ! do not change, as the header are named as per table
        names = [
            "trxDate", # transaction date, typically the first colum
            "_description", "_reference", # merged into `trxDescOrig`

            # ? only transaction value is stored, while balance is
            # kept in parsed raw pickle file for future reference
            "_debit", "_credit", "_balance"
        ]
    )

    records["trxDate"] = records["trxDate"].apply(lambda x : x.date())
    records["trxDescOrig"] = records[["_description", "_reference"]] \
        .apply(lambda x : f"{x[0]} ref:: {x[1]}", axis = 1)
    
    records["trxType"], records["trxAmount"] = zip(
        *records[["_debit", "_credit"]].apply(
            lambda x : ("DEPOSIT", x[1]) if np.isnan(x[0]) else
                ("WITHDRAW", x[0]),
                axis = 1
        )
    )

    return records
