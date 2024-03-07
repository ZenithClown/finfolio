# -*- encoding: utf-8 -*-

import sys

import pandas as pd
import sqlalchemy as sa

from time import ctime
from tqdm import tqdm as TQ

if __name__ == "__main__":
    print(f"\033[94m{ctime()} \033[0mStarting to Insert Data...")
    sheet_names = ["RegionMaster", "CurrencyMaster", "CountryMaster", "StateMaster"] # should be same as table names
    
    # get system level arguments
    _, hostname, port, username, password, schema, filename = sys.argv
    
    engine = sa.create_engine(f"mysql+pymysql://{username}:{password}@{hostname}:{port}/{schema}")
    
    # read sheets, and insert into database
    for sheet in TQ(sheet_names):
        data = pd.read_excel(filename, sheet_name = sheet)
        data.to_sql(sheet, con = engine, if_exists = "append", index = False)
