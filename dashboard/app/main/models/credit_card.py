# -*- encoding: utf-8 -*-

from .. import db
from .bank_details import AccountDetails

class CreditCardLimit(db.Model):
    __tablename__ = "CreditCardLimit"

    AccountNumber  = db.Column(db.Integer, db.ForeignKey('accountdetails.AccountNumber'), primary_key = True, nullable = False)
    CashLimit = db.Column(db.Float, nullable = False)  
    CreditLimit = db.Column(db.Float, nullable = False)  
    RevisionDate = db.Column(db.Date, nullable = True)   

    def __repr__(self):
        # return { c.key : getattr(self, c.key) for c in self.__table__.columns }
        return f"<{self.AccountNumber}(CashLimit = {self.CashLimit}, CreditLimit = {self.CreditLimit}>"

    def toDict(self):
        return { c.key : getattr(self, c.key) for c in self.__table__.columns }


class CreditCardAccount(db.Model):
    __tablename__ = "CreditCardAccount"

    AccountNumber  = db.Column(db.Integer, db.ForeignKey('accountdetails.AccountNumber'), nullable = False)
    StatementIdentifier = db.Column(db.String(45), nullable = False)  
    Amount = db.Column(db.Float, nullable = False)  
    StatementDate = db.Column(db.Date, nullable = False)   
    PayementInfo = db.Column(db.String(45), nullable = True) 

    def __repr__(self):
        # return { c.key : getattr(self, c.key) for c in self.__table__.columns }
        return f"<{self.AccountNumber}(StatementIdentifier = {self.StatementIdentifier}, Amount = {self.Amount}>"

    def toDict(self):
        return { c.key : getattr(self, c.key) for c in self.__table__.columns }


class CreditPayement(db.Model):
    __tablename__ = "CreditPayement"

    StatementIdentifier = db.Column(db.String(45), nullable = False)  
    PayementMode = db.Column(db.String(45), nullable = False) 
    PayementDate = db.Column(db.Date, nullable = False)
    PaymentAmount = db.Column(db.Float, nullable = False)  

    def __repr__(self):
        # return { c.key : getattr(self, c.key) for c in self.__table__.columns }
        return f"<{self.StatementIdentifier}(PayementMode = {self.PayementMode}, PayementDate = {self.PayementDate}, PaymentAmount = {self.PaymentAmount}>"

    def toDict(self):
        return { c.key : getattr(self, c.key) for c in self.__table__.columns }
