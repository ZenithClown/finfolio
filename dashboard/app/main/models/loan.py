# -*- encoding: utf-8 -*-

from .. import db
from .EMI import EMI_Information

class LoanInformation(db.Model):
    __tablename__ = "LoanInformation"

    LoanDate = db.Column(db.Date, nullable = False)   
    LoanIdentifier = db.Column(db.String(45), primary_key = True, nullable = False) 
    Amount = db.Column(db.Float, nullable = False) 
    LenderName = db.Column(db.String(45), nullable = False) 
    BorrowerName = db.Column(db.String(45), nullable = False) 
    LoanType = db.Column(db.String(45), nullable = False) 
    EMI_Identifier  = db.Column(db.String(45), db.ForeignKey('emi_information.EMI_Identifier'), nullable = False)

    def __repr__(self):
        # return { c.key : getattr(self, c.key) for c in self.__table__.columns }
        return f"<{self.LoanIdentifier}(LoanDate = {self.LoanDate}, Amount = {self.Amount}, EMI_Identifier = {self.EMI_Identifier}>"

    def toDict(self):
        return { c.key : getattr(self, c.key) for c in self.__table__.columns }


class LoanPayement(db.Model):
    __tablename__ = "LoanPayement"

    LoanIdentifier  = db.Column(db.String(45), db.ForeignKey('loaninformation.LoanIdentifier'), nullable = False)
    InstallmentDate = db.Column(db.Date, nullable = False)
    Amount = db.Column(db.Float, nullable = False) 

    def __repr__(self):
        # return { c.key : getattr(self, c.key) for c in self.__table__.columns }
        return f"<{self.LoanIdentifier}(InstallmentDate = {self.InstallmentDate}, Amount = {self.Amount}>"

    def toDict(self):
        return { c.key : getattr(self, c.key) for c in self.__table__.columns }