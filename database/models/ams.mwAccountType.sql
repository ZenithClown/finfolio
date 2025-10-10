/********************************************************************
Master Table Defination of Account Types

The application has the capability of storing information of various
types of accounts, like DEBIT/CREDIT/DEMAT/etc. and each type of
account has seperate attributes associated. The master tables provide
a master key to map different available attributes of an account with
any of the different attributes.

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
    (4, 'DEMAT', 'A specialized account type that contains transactions related to shares, mutual funds, etc.'),
    (5, 'RETIREMENT', 'An account dedicated for savings for retirements, like PPF, VPF, NPS, etc.'),
    (6, 'INSURANCE', 'Use this to track investments/redemptions into insurance');
