# -*- encoding: utf-8 -*-

"""
CLI Interface to Create a New Account

Any user can have multiple types of accounts linked under his/her
name. The function provided here invokes the post function to create
a new account mapped under a username.
"""

import cli
import requests

if __name__ == "__main__":
    print(f"pOrgz CLI Interface - {cli.__version__}")

    username = input("Enter Username : ")
    account_number = int(input("Enter New Account Number (int) : "))

    account_name = input("Set a New Name to Account : ")
    account_type = input("Set a Type of the Account : ")

    opening_date = input("Account Opening Date (DD-MM-YYYY) : ")
    closing_date = input("Account Closing Date (DD-MM-YYYY) : ") or None

    payload = {
        "username" : username,
        "account_number" : account_number,
        "account_name" : account_name,
        "account_type" : account_type,
        "opening_date" : opening_date,
        "closing_date" : closing_date
    }

    data = requests.post("http://localhost:5000/dev/create/new-account", data = payload)
    print(data.status_code, data.text)
