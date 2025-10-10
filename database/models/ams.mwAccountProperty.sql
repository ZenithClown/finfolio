/********************************************************************
Master Table Defination to Store Attributes for a Account Type

Any of the defined account type (under `ams.mwAccountType`) has
certain attributes associated with it, for example account number,
name etc. being the basic required information. In addition, certain
special attributes like "IFSC", "POINT_CONVERSION" etc. can be
associated with account types.

Copywright © [2023] pOrgz <https://github.com/pOrgz-dev>
********************************************************************/

CREATE TABLE IF NOT EXISTS "ams.mwAccountProperty" (
    AccountID        VARCHAR(32) PRIMARY KEY, -- generate unique identity
    AccountNumber    INTEGER NOT NULL UNIQUE,
    AccountName      VARCHAR(64) NOT NULL UNIQUE,
    AccountTypeID    INTEGER NOT NULL,
    AccountOpenDate  DATE NOT NULL, -- ! resulting affinity - TEXT
    AccountCloseDate DATE,
    
    -- ? AccountTags: csv, use this to generate combined report
    -- for programming purpose, a default value (blank) is set
    AccountTags   TEXT DEFAULT '' NOT NULL,

    FOREIGN KEY(AccountTypeID) REFERENCES "ams.mwAccountType"(AccountTypeID)
);


/*** Additional Account Property for ? ACCOUNT_TYPE is Defined Below ***/
CREATE TABLE IF NOT EXISTS "ams.mwAP_DEBIT" (
    _id       INTEGER PRIMARY KEY AUTOINCREMENT,
    AccountID INTEGER NOT NULL UNIQUE, -- ! not a PK, for easier join
    
    -- information available for a debit type account
    -- typically, a debit card is associated with an institution
    CIF  TEXT, -- customer identification file
    IFSC TEXT, -- related to a savings/current account

    -- additionally, a debit account can have multiple owner
    -- TODO: can we add/fetch the information using the `ums.?` tables
    SecondaryHolder  TEXT DEFAULT NULL,
    TertiaryHolder   TEXT DEFAULT NULL,
    QuaternaryHolder TEXT DEFAULT NULL,

    -- optionally add/maintain nominee informations
    _hasNominee INTEGER CHECK(_hasNominee IN (0, 1)) DEFAULT 0 NOT NULL,
    NomineeName TEXT, -- ? can we maintain this from the `ums.?`
    NomineeRelationship TEXT,

    FOREIGN KEY(AccountID) REFERENCES "ams.mwAccountProperty"(AccountID)
);


CREATE TABLE IF NOT EXISTS "ams.mwAP_CREDIT" (
    _id       INTEGER PRIMARY KEY AUTOINCREMENT,
    AccountID INTEGER NOT NULL UNIQUE, -- ! not a PK, for easier join

    -- typically a credit card has the following additional attributes
    -- TODO: have the provision to record credit/cash revision dates
    CashLimit   INTEGER NOT NULL,
    CreditLimit INTEGER NOT NULL,
    
    -- statement is generated on a date, and due date is calculated
    StatementDay  INTEGER CHECK(StatementDay <= 31), -- day number
    StatementDue_ INTEGER, -- no. of days from statement day to pay due amount

    FOREIGN KEY(AccountID) REFERENCES "ams.mwAccountProperty"(AccountID)
);
