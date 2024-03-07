# -*- encoding: utf-8 -*-

from .. import db
from .bank_details import AccountDetails

class DebitCardAccount(db.Model):
    __tablename__ = "DebitCardAccount"

    AccountNumber  = db.Column(db.Integer, db.ForeignKey('accountdetails.AccountNumber'), primary_key = True, nullable = False)
    StatementPeriod = db.Column(db.String(45), nullable = False)  
    DebitCardNumber = db.Column(db.Integer, nullable = False)  
    OpeningDate = db.Column(db.Date, nullable = True)   
    ClosingDate = db.Column(db.Date, nullable = True)
    OpeningBalance = db.Column(db.Float, nullable = True)
    ClosingBalance = db.Column(db.Float, nullable = True)

    def __repr__(self):
        # return { c.key : getattr(self, c.key) for c in self.__table__.columns }
        return f"<{self.AccountNumber}(DebitCardNumber = {self.DebitCardNumber}, OpeningDate = {self.OpeningDate}, ClosingDate = {self.ClosingDate}>"

    def toDict(self):
        return { c.key : getattr(self, c.key) for c in self.__table__.columns }