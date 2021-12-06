# -*- encoding: utf-8 -*-

"""Dry Run Email Application and Check if Mail is Fired Properly"""

import sys
import time

from os.path import (
    join,
    abspath,
    dirname
)

from jinja2 import (
    Environment,
    FileSystemLoader
)

if __name__ == "__main__":
    sys.path.append(join(abspath(dirname(__file__)), "..", "main", "controller"))

    try:
        from _base_mailer import BaseMailer
    except ImportError as err:
        raise ImportError("unable to resolve path", err)
    else:
        print(f"{time.ctime()} [INFO] All Modules are Imported.")

    # define mailer object
    mailer = BaseMailer()
    print(f"{time.ctime()} [INFO] Object <{repr(mailer)}> Initialized.")

    mailer.__login__() # check if login succesful

    try:
        mailer.sendMail(
            receiver = "dPramanik.INSW@gmail.com",
            message  = "Hello World! This is a test email. Please do not reply to this email.",
            subject  = "Testing Email Service #2"
        )
    except Exception as err:
        print(f"MMail Not Sent. Received - <{type(err)} - {err}>")
    else:
        print(f"  >> {time.ctime()} [INFO] Email with TEXT is Sent Sucessfully.")

    # * adding HTML template with jinja2
    env = Environment(loader = FileSystemLoader(dirname(__file__)))
    template = env.get_template("template.html")

    try:
        mailer.sendMail(
            receiver = "dPramanik.INSW@gmail.com",
            message  = template.render(), # open("template.html", "r").read(),
            subject  = "Testing Email Service by Embedding HTML Document & Jinja2 #2"
        )
    except Exception as err:
        print(f"MMail Not Sent. Received - <{type(err)} - {err}>")
    else:
        print(f"  >> {time.ctime()} [INFO] Email with HTML Embeddings are Sent Sucessfully.")

    mailer.__close__()
