# -*- encoding: utf-8 -*-

"""
The Main Module for pOrgz Web-Application built using StreamLit

The web-based application for Porgz is developed using streamlit, an
open-source application development interface for data science and
machine learning projects (more details https://streamlit.io/).

@author:  Debmalya Pramanik
@copywright: pOrgz <https://github.com/pOrgz-dev>
"""

import os
import sys

import sqlite3
import streamlit as st

from src.pages import PAGE_MAP

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..")
DB_PATH = "E:\\database\\pOrgz.db" # ! STATIC path is provided

DB_MODELS = os.path.join(ROOT, "database", "models")
DB_VIEWS = os.path.join(DB_MODELS, "views") # part of the `models`
DB_QUERIES = os.path.join(ROOT, "database", "queries")

def main(state : object = None):
    st.title("pOrgz")

    currentPage = st.sidebar.radio("📃 **Main Menu**", options = list(PAGE_MAP))
    PAGE_MAP[currentPage](state = state)

@st.cache_resource
def connect():
    con = sqlite3.connect(DB_PATH)
    return con

if __name__ == "__main__":
    with open("src/assets/style.css", "r") as f:
        st.markdown(f"<style>{f.read()}</style>", unsafe_allow_html = True)

    main()
