/********************************************************************
Transactions Table for Account Management System [AMS]

The main/core transactions table that holds all the transactions
information along with certain additional derived features (explained
on each line) is defined.

Copywright © [2023] pOrgz <https://github.com/pOrgz-dev>
********************************************************************/

CREATE TABLE IF NOT EXISTS "ams.transactions" (
    _id       INTEGER PRIMARY KEY AUTOINCREMENT,
    AccountID VARCHAR(32) NOT NULL,

    -- ? most of the time transaction record is available at day level
    -- each of the transaction has a type, amount and description
    trxDate   DATE NOT NULL,
    trxType   VARCHAR(16) NOT NULL,    -- TODO: define key definations
    trxAmount DECIMAL(16, 2) NOT NULL, -- ? MAX: 99,999,999,999,999.99

    -- ! all of the derived column have a leading "_" for identification
    -- ! all of the derived fields allow/defaults to NULL, unless explicit:
    -- null since ai/ml is yet in development stage, and may be revised

    -- ? each record has two types of descriptions:
    --   1. as available from the raw records/files/user inputs
    --   2. cleaned/formatted description for text analytics/featurization
    trxDescOrig VARCHAR(512) NOT NULL,
    _trxDescDrv VARCHAR(512), -- ! derived, allow null, maybe added later

    -- ! additional derived field using text analytics/featurizations
    _trxMethod  VARCHAR(8), -- method of transaction, eg. NEFT/RTGS/UPI/etc.
    _trxAccount VARCHAR(256), -- transation account details, can be named/number

    -- self account transactions can be identified using the flag
    -- helps in reducing duplicate records/calculations
    _self_account_transfer BOOLEAN CHECK(_self_account_transfer IN (0, 1)) DEFAULT 0 NOT NULL,

    -- ! self classified tags using ai/ml classification method
    _tag_by_automation VARCHAR(128), -- csv, automatic tagging by ai/ml model

    -- ! allow end user to manually tag/classify the records
    -- this manual tagging has the highest precedence over any other tagging
    _tag_by_end_user VARCHAR(128), -- csv, multiple manual tagging by the end user

    -- specify created/updated on timestamp for verification
    created_on DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_on DATETIME DEFAULT NULL,

    FOREIGN KEY(AccountID) REFERENCES "ams.mwAccountProperty"(AccountID),

    -- optional:: added foreign key for dev/tagged categorization
    FOREIGN KEY(_trxMethod) REFERENCES "ams.trxMethod"(MethodName),
    FOREIGN KEY(_trxAccount) REFERENCES "ams.trxAccounts"(AccountID)
);

CREATE TABLE "ams.extFixedDeposits" (
    FDAccountNumber VARCHAR(32) PRIMARY KEY,

    -- track the deposit and withdraw transaction
    -- from the linked/defined debit accounts,
    -- ? can fetch all details using `JOIN` statement
    DepositTrxID  INTEGER NOT NULL UNIQUE,
    WithdrawTrxID INTEGER NOT NULL UNIQUE,

    FOREIGN KEY(FDAccountNumber) REFERENCES "ams.mwAccountProperty"(AccountID)
);
