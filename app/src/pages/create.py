# -*- encoding: utf-8 -*-

"""
Create/Open a New Account of Any Pre-Defined Types

Use the CLI script to open/register a new account under any of the
defined types.

@author:  Debmalya Pramanik
@copywright: pOrgz <https://github.com/pOrgz-dev>
"""

import streamlit as st

from uuid import uuid4 as UUID

def create(state : object = None) -> str:
    """
    Create a New Account for the Module

    The function considers the basic requirements required to open
    a new account, and later based on the account type it asks users
    for additional informations.
    """

    with st.form("create") as form:
        st.write("Create a New Account")

        AccountID        = str(UUID()).upper()
        AccountNumber    = st.number_input("Account Number:")
        AccountName      = st.text("Account Name:")
        AccountType      = st.selectbox("Account Type:", options = ["DEBIT", "CREDIT"])
        AccountOpenDate  = st.date_input("Account Open Date:")
        AccountCloseDate = st.date_input("Account Close Date:")
        
        submit = st.form_submit_button("Create Account")

    if submit:
        st.write(AccountID)
