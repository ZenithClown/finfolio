/********************************************************************
A Set of TAG(s) Defined to Categorize Transactions

The tags are maintained at different level, like account, method, end
user tags, etc. which can be used for categorizing the transactions
and thus in better reporting.

Copywright © [2024] Debmalya Pramanik
********************************************************************/

CREATE TABLE IF NOT EXISTS "ams.trxMethod" (
    MethodName VARCHAR(8) PRIMARY KEY,
    MethodDescription VARCHAR(128) NOT NULL
);

INSERT INTO "ams.trxMethod" (MethodName, MethodDescription)
VALUES
    ("ATMCASH", "Cash Transaction at ATM"),
    ("INTEREST", "Interest Received, typically at Savings Account"),
    ("NEFT", "National Electronic Funds Transfer (NEFT) Transaction"),
    ("UPI", "Unified Payments Interface (UPI) Transaction"),
    ("MANDATE", "Automatic Payment Setup by Account Holder");
