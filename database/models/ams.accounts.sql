/********************************************************************
Defination of Master Table(s) for Account Management System (AMS)

The account management system constitues of the following primary
and/or master tables to efficiently manage maximum possible
attributes of an individual/family. The following table are defined
whose objective/descriptions is as follows:

    1. mwAccountType : The application has the capability of storing
        information of various types of accounts, like DEBIT/CREDIT/
        DEMAT/etc. and each type of account has seperate attributes
        associated. To facilitate this, the master tables provide a
        master key to map different available attributes of an
        account with any of the different attributes.
    2. mwAccountProperty : Any of the defined account type has
        certain attributes associated with it, for example account
        number, name etc. being the basic required information. In
        addition, certain special attributes like "IFSC",
        "POINT_CONVERSION" etc. can be associated with account types.
        The following extended tables are added for capturing all the
        attributes related to an account holder:

        * extDebitAccount : Holds information related to a debit
            account, typically savings bank branch details, nominee
            details etc.
        * extCreditAccount : Holds credit account details like
            payment cycles, credit limits etc.

Copywright © [2023] pOrgz <https://github.com/pOrgz-dev>
********************************************************************/

CREATE TABLE IF NOT EXISTS "ams.mwAccountType" (
    AccountTypeID   INTEGER PRIMARY KEY AUTOINCREMENT,
    AccountTypeName VARCHAR(10) UNIQUE NOT NULL, -- ! treated as TEXT
    _description    TEXT -- ? optional, descriptive information
);

/*** INSERT PRE-DEFINED (GLOBAL/STATIC) VALUES ***/
INSERT INTO "ams.mwAccountType" (AccountTypeID, AccountTypeName, _description)
VALUES
    (1, 'DEBIT', 'Use this to store transactions from savings/current account.'),
    (2, 'CREDIT', 'Use this to store transactions related to loans, credit cards, etc.'),
    (3, 'WALLET', 'A type of account for storing gift cards, points, cashbacks, rewards etc. informations.'),
    (4, 'DEMAT', 'A typical table for holding information related to share market, populate equity, f&o transactions.'),
    (5, 'RETIREMENT', 'An account dedicated for savings for retirements, like PPF, VPF, NPS, etc.'),
    (6, 'INSURANCE', 'Use this to track investments/redemptions into insurance'),
    (7, 'MUTUALFUND', 'A typical account for management of mutual funds and SIP/STP informations.'),
    (8, 'TDACCOUNT', 'Term deposit accounts like FD/RD/etc. can be tracked here.');

CREATE TABLE IF NOT EXISTS "ams.extAccountType" (
    AccountSubTypeID INTEGER PRIMARY KEY AUTOINCREMENT,
    AccountTypeID    INTEGER NOT NULL,
    SubTypeName      VARCHAR(16) NOT NULL,
    _description     TEXT, -- ? optional, descriptive information

    FOREIGN KEY(AccountTypeID) REFERENCES "ams.mwAccountType"(AccountTypeID)
);

INSERT INTO "ams.extAccountType" (AccountSubTypeID, AccountTypeID, SubTypeName, _description)
VALUES
    (1, 8, 'FD', 'Fixed Deposit Account'),
    (2, 8, 'RD', 'Recurring Deposit Account');

/***** Account Information & Related Extended Tables *****/
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

CREATE TABLE IF NOT EXISTS "ams.extDebitAccount" (
    _id       INTEGER PRIMARY KEY AUTOINCREMENT,
    AccountID INTEGER NOT NULL UNIQUE, -- ! not a PK, for easier join

    -- information available for a debit type account
    -- typically, a debit card is associated with an institution
    CIF  TEXT, -- customer identification file number
    IFSC TEXT, -- related to a savings/current account

    -- additionally, a debit account can have multiple owner this
    -- is addressed by keeping a field for "secondary holder" while
    -- in case of more than 2 holders, holders can be added into
    -- the "tertiary and others" holder field, csv expected
    SecondaryHolder    TEXT DEFAULT NULL, -- ? get from `ums.?`
    TertiaryPlusHolder TEXT DEFAULT NULL, -- ! csv value expected

    -- optionally add/maintain nominee informations
    _hasNominee INTEGER CHECK(_hasNominee IN (0, 1)) DEFAULT 0 NOT NULL,
    NomineeName TEXT, -- ? can we maintain this from the `ums.?`
    NomineeRelationship TEXT,

    FOREIGN KEY(AccountID) REFERENCES "ams.mwAccountProperty"(AccountID)
);

CREATE TABLE IF NOT EXISTS "ams.extCreditAccount" (
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
