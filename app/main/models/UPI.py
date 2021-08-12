# -*- encoding: utf-8 -*-

from .. import db
from .mobile_wallet import MobileWallet

class UPI(db.Model):
    __tablename__ = "UPI"

    ID = db.Column(db.String(45), primary_key = True, nullable = False)  
    ApplictionName = db.Column(db.String(45), nullable = False) 
    WalletIdentifier  = db.Column(db.String(45), db.ForeignKey('mobilewallet.WalletIdentifier'), nullable = False)

    def __repr__(self):
        # return { c.key : getattr(self, c.key) for c in self.__table__.columns }
        return f"<{self.ID}(ApplictionName = {self.ApplictionName}>"

    def toDict(self):
        return { c.key : getattr(self, c.key) for c in self.__table__.columns }