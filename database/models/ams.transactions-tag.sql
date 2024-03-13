/********************************************************************
A Set of TAG(s) Defined to Categorize Transactions

The tags are maintained at different level, like account, method, end
user tags, etc. which can be used for categorizing the transactions
and thus in better reporting.

Adopted Notation: This is a master table with pre-configured data,
maintained for simplification of end-usage report generation. By
default, the tables are named like:

```
ams.dmw_<column-name>
```

Where, `dmw` stands for "derived master" records, and this is a new
suffix added into the project. In case, the original column names
starts with a leading (`_`, i.e.,, in case of derived columns) then
only single (`_`) sign.

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
    ("MANDATE", "Automatic Payment Setup by Account Holder"),
    ("IMPS", "Immediate Payment Service (IMPS) Transaction");

CREATE TABLE IF NOT EXISTS "ams.trxAccounts" (
    AccountID   VARCHAR(256) PRIMARY KEY,
    AccountName VARCHAR(512) UNIQUE NOT NULL,
    
    -- ? institution details are maintained as below:
    InstitutionType VARCHAR(16) NOT NULL,
    InstitutionDesc VARCHAR(64) NOT NULL
);

INSERT INTO "ams.trxAccounts" (AccountID, AccountName, InstitutionType, InstitutionDesc)
VALUES
    ("DIBS", "Digital Indian Business Solutions Pvt. Ltd.", "ORGANIZATION", "Internship Company"),
    ("IIFL", "IIFL Securities Pvt. Ltd.", "ORGANIZATION", "DEMAT A/C"),
    ("IWORKS", "Inspirigence Works Pvt. Ltd.", "ORGANIZATION", "Internship Company"),
    ("JASNI", "Jasni A Salim", "INDIVIDUAL", "Content Writing - Freelancing Work"),
    ("KTP", "Kolkata Traffic Police", "GOVERNMENT", "Challan/Charges for Traffic Violations"),
    ("PIL", "Pidilite Industries Ltd.", "ORGANIZATION", "Full-Time Working Company"),
    ("RIL", "Reliance Jio Infocomm Ltd.", "ORGANIZATION", "Full-Time Working Company"),
    ("ZERODHA", "Zerodha Pvt. Ltd.", "ORGANIZATION", "DEMAT A/C");
