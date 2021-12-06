# -*- encoding: utf-8 -*-

import os
import smtplib

from email.mime.text import MIMEText
from email.message import EmailMessage
from email.mime.multipart import MIMEMultipart

# setting the environment
from dotenv import load_dotenv # Python 3.6+

load_dotenv(verbose = True)

class BaseMailer(object):
    """Base Class for Mailing"""
    
    def __init__(self, protocol : str = "SMTP", **kwargs) -> None:
        """default constructor"""

        # TODO defination and configuration of all email protocols
        # * currently only SMTP protocol is supported and configured
        self.protocol = protocol
        
        # * connection parameters for SMTP Server
        # ? should `_host` and `_port` be allowed to define directly
        self._host = os.getenv("MAIL_SMTP_SERVER", kwargs.get("_host"))
        self._port = os.getenv("MAIL_SMTP_SERVER_PORT", kwargs.get("_port"))

        # * defination of admin/sender email address
        # ? should `_email` be allowed to define directly
        self.sender = os.getenv("ADMIN_EMAIL", kwargs.get("_email"))

        self.mail_server = smtplib.SMTP(
            host = self._host,
            port = self._port
        )


    def __login__(self, **kwargs) -> bool:
        """Check if the Mail Server be logged in for Sending Emails"""

        try:
            self.mail_server.connect(self._host, self._port)

            # * try logging into the server with the credentials provided
            # ? should `_password` be allowed to define directly
            self.mail_server.login(
                user     = self.sender,
                password = os.getenv("ADMIN_EMAIL_PASSWORD", kwargs.get("_password")),
            )
        except ConnectionRefusedError as err:
            raise ConnectionRefusedError(f"Active Machine: <{self._host} -p {self._port}> | {err}")
        except smtplib.SMTPAuthenticationError as err:
            return False

        return True


    def __close__(self) -> bool:
        """Close the Email Server (after operation)"""

        try:
            self.mail_server.quit()
        except smtplib.SMTPServerDisconnected:
            # ? why is connection closed with an raised error
            # ! raised when mail_server is already closed?
            return False

        return True


    def sendMail(self, receiver : str, message : str, subject : str) -> bool:
        """Defination of Function for Sending Emails"""

        if type(message) == str:
            email_message = EmailMessage()
            email_message.set_content(message)

            email_message["Subject"] = subject
            email_message["From"]    = self.sender
            email_message["To"]      = receiver

            self.mail_server.send_message(email_message)
        else: # ? type: _io.TextIOWrapper
            email_message = MIMEMultipart('alternative')

            email_message["Subject"] = subject + "(in HTML)"
            email_message["From"]    = self.sender
            email_message["To"]      = receiver

            email_message.attach(MIMEText(message, 'html'))

            self.mail_server.sendmail(self.sender, receiver, email_message.as_string())
        return True


    def __str__(self):
        return f"{__name__}: PROTOCOL = {self.protocol}"


    def __repr__(self):
        return f"{__name__}: PROTOCOL = {self.protocol} ({self._host}, {self._port})"
