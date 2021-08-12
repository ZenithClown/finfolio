# -*- encoding: utf-8 -*-

"""Password Security with MD5"""

import _io

import os
import hashlib
import smtplib

from email.mime.text import MIMEText
from email.message import EmailMessage
from email.mime.multipart import MIMEMultipart

# setting the environment
from dotenv import load_dotenv # Python 3.6+
load_dotenv(verbose = True)

def encrypt(_password : str) -> str:
    """Encrypts the Password with MD5 and SALT"""
    __password_salt__ = os.getenv('forward_salt') + _password + os.getenv('backward_salt')
    return hashlib.sha256(__password_salt__.encode()).hexdigest()

def validate(_password : str, _original_password : str) -> bool:
    """Validate Password"""
    __password_salt__ = os.getenv('forward_salt') + _password + os.getenv('backward_salt')
    
    if hashlib.sha256(__password_salt__.encode()).hexdigest() == _original_password:
        return True

    return False

class Mailing(object):
    """Email Sending Class"""

    def __init__(self, protocol : str = "SMTP", **kwargs):
        """default constructor"""

        self.protocol    = protocol # only SMTP setup completed

        # set SMTP
        self._host = os.getenv("MAIL_SMTP_SERVER")
        self._port = os.getenv("MAIL_SMTP_SERVER_PORT")

        # set email sender
        self.sender = os.getenv("ADMIN_EMAIL")

        self.mail_server = smtplib.SMTP(
                host = self._host,
                port = self._port
            )

    def _login(self):
        # check login
        self.mail_server.connect(self._host, self._port)
        self.mail_server.login(
                user     = self.sender,
                password = os.getenv("ADMIN_EMAIL_PASSWORD"),
            )

        return True

    def _close(self):
        # close server
        try:
            self.mail_server.quit()
        except smtplib.SMTPServerDisconnected:
            return True # close the connection

        return False

    def sendMail(
            self,
            receiver : str,
            message  : str or _io.TextIOWrapper,
            subject  : str = "OAuth Server Alerts"
        ):
        """Main Class to Send an Email"""

        if type(message) == str:
            _msg = EmailMessage()
            _msg.set_content(message) # text content can be set easily

            _msg["Subject"] = subject
            _msg["From"]    = self.sender
            _msg["To"]      = receiver

            self.mail_server.send_message(_msg)
        else: # type: _io.TextIOWrapper
            _msg = MIMEMultipart('alternative')

            _msg["Subject"] = subject + "(in HTML)"
            _msg["From"]    = self.sender
            _msg["To"]      = receiver

            _msg.attach(MIMEText(message, 'html'))

            self.mail_server.sendmail(self.sender, receiver, _msg.as_string())
        return True


    def __str__(self):
        return f"{__name__}: PROTOCOL = {self.protocol}"

    def __repr__(self):
        return f"{__name__}: PROTOCOL = {self.protocol} ({self._host}, {self._port})"

if __name__ == "__main__":
    # check if email is working
    # run this code using `python utils.py`
    import time

    obj = Mailing()
    print(f"{time.ctime()} Executing - {str(obj)}")
    print(f"\t>> DevOps Note: {repr(obj)}")

    # send plain text message
    obj.sendMail(receiver = "user@pOrgz.com", message = "Greetings from pOrgz OAuth!")

    # send HTML template and other advanced message formats
    obj.sendMail(receiver = "user@pOrgz.com", message = open("../static/template/dummy.html").read())

    # close mailer
    obj._close()
