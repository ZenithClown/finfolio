# -*- encoding: utf-8 -*-

from .. import db

class EMI_Information(db.Model):
    __tablename__ = "EMI_Information"

    EMI_Identifier  = db.Column(db.String(45),primary_key = True, nullable = False)
    ItemName = db.Column(db.String(45), nullable = False)  
    ProductPrice = db.Column(db.Float, nullable = False)
    InterestRate = db.Column(db.Float, nullable = False)
    Tenure = db.Column(db.Integer, nullable = False)  
    MonthlyEMI = db.Column(db.Float, nullable = False)   

    def __repr__(self):
        # return { c.key : getattr(self, c.key) for c in self.__table__.columns }
        return f"<{self.EMI_Identifier}(ItemName = {self.ItemName}, ProductPrice = {self.ProductPrice}, Tenure = {self.Tenure}>"

    def toDict(self):
        return { c.key : getattr(self, c.key) for c in self.__table__.columns }