# -*- encoding: utf-8 -*-

"""Dry Run Email Application and Check if Mail is Fired Properly"""

import sys
from os.path import (
    join,
    abspath,
    dirname
)

if __name__ == "__main__":
    sys.path.append(join(abspath(dirname(__file__)), "..", "main", "controller"))

    try:
        from _base_mailer import BaseMailer
    except ImportError as err:
        raise ImportError("unable to resolve path", err)
    else:
        print("INFO : Import Succesful.")

    # define mailer object
    mailer = BaseMailer()
    print(f"Checking for: {mailer}")

    mailer.__login__() # check if login succesful

    try:
        mailer.sendMail(
            receiver = "dPramanik.INSW@gmail.com",
            message  = "Hello World! This is a test email. Please do not reply to this email.",
            subject  = "Testing Email Service"
        )
    except Exception as err:
        print(f"MMail Not Sent. Received - <{type(err)} - {err}>")
    else:
        print("Email Sent Succesfully.")

    try:
        mailer.sendMail(
            receiver = "dPramanik.INSW@gmail.com",
            message  = open("template.html", "r").read(),
            subject  = "Testing Email Service by Embedding HTML Document"
        )
    except Exception as err:
        print(f"MMail Not Sent. Received - <{type(err)} - {err}>")
    else:
        print("Email (with HTML Embeddings) Sent Succesfully.")

    mailer.__close__()
