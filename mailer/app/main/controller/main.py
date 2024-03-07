# -*- encoding: utf-8 -*-

"""Defination of Main Controller of Controlling Module for the Application"""

from flask import request

from ._base_mailer import BaseMailer
from ._base_resource import BaseResource

class Mailer(BaseResource):
    """Master Controller for Mailer Application"""

    def __init__(self) -> None:
        super().__init__()

        self.req_parser.add_argument("subject", type = str, required = True)
        self.req_parser.add_argument("receiver", type = str, required = True)

        # ! argument for messages can be set or added (more) if required
        # ! an email can be DEBUG INFO ERROR CRITICAL WARN types (as defined under logger)
        # TODO define email template for every type/inherit from a particular template
        # ? to do finalize what parameters are required against each email types, and thus define
        # * currently a simple message of `type == str` is defined
        # TODO define different params and update the HTML as required
        self.req_parser.add_argument("message", type = str, required = True)

        # * object defination for the base mailer for sending and receiving emails
        self.mailer = BaseMailer()


    def get(self):
        """GET Information Regarding the Mail Sent"""

        self.mailer.__login__() # login to the email server
        self.mailer.sendMail(
            receiver = self.args["receiver"],
            message  = self.args["message"],
            subject  = self.args["subject"]
        )
        self.mailer.__close__()

        return self.formatter.get("mail sent")
