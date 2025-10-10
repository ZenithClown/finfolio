# -*- encoding: utf-8 -*-

from .. import db

class MobileWallet(db.Model):
    __tablename__ = "MobileWallet"

    WalletIdentifier  = db.Column(db.String(45),primary_key = True, nullable = False)
    WalletName = db.Column(db.String(45), nullable = False)  
    WalletOpenDate = db.Column(db.Date, nullable = True)
    WaletLimit = db.Column(db.Float, nullable = True) 

    def __repr__(self):
        # return { c.key : getattr(self, c.key) for c in self.__table__.columns }
        return f"<{self.WalletIdentifier}(WalletName = {self.WalletName}, WaletLimit = {self.WaletLimit}, WalletOpenDate = {self.WalletOpenDate}>"

    def toDict(self):
        return { c.key : getattr(self, c.key) for c in self.__table__.columns }