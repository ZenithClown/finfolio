/********************************************************************
Transactions Table for Account Management System [AMS]

The main/core transactions table that holds all the transactions
information along with certain additional derived features (explained
on each line) is defined.

In addition, an extended table is defined that handles all internal
transactions to- and fro- own accounts. For example, a Term/Time
deposit account is linked to a parent debit account and the nature
of transaction is:
    > STEP 1: On opening a TD Account, the amount is deducted
        (WITHDRAW) from the linked DEBIT account,
    > STEP 2: Interest is accumulated in the TD Account, and finally
        the total amount is credited (DEPOSIT) back.

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
    _trxAccount VARCHAR(16), -- transation account detail, mapped to tags table

    -- ! deposit/withdraw category can be amc, charges, etc.
    -- TODO create a pre-configured tags for auto-population from model
    _trxCategory VARCHAR(3), -- ? if null, then undefined, i.e., normal transaction

    -- ? also, allow tagging based on model/user as below:
    -- TODO: #14 create a derived column "Transaction Category" based on `_trxCategory*`
    _trxCategoryAuto VARCHAR(128), -- ? csv, automatic tagging by ai/ml model
    _trxCategoryUser VARCHAR(128), -- ? csv, multiple manual tagging by the end user

    -- specify created/updated on timestamp for verification
    created_on DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_on DATETIME DEFAULT NULL,

    FOREIGN KEY(AccountID) REFERENCES "ams.mwAccountProperty"(AccountID),

    -- optional:: added foreign key for dev/tagged categorization
    FOREIGN KEY(_trxMethod) REFERENCES "ams.dmw_trxMethod"(_method_id),
    FOREIGN KEY(_trxAccount) REFERENCES "ams.dmw_trxAccount"(_account_id)
);

-- extended transactions account, to get all types of inter-account and transaction breakup
CREATE TABLE IF NOT EXISTS "ams.extDebitTransactions" (
    _id      INTEGER PRIMARY KEY AUTOINCREMENT,
    refTrxID INTEGER UNIQUE NOT NULL, -- ! not unique to hold credit account information
    
    -- src - source, dst - destination :: account details are mapped
    srcAccountID VARCHAR(32) NOT NULL,
    dstAccountID VARCHAR(32) NOT NULL,

    -- the transaction type is related to the destination account::
    _trxType VARCHAR(16) NOT NULL,

    FOREIGN KEY(refTrxID) REFERENCES "ams.transactions"(_id),
    FOREIGN KEY(srcAccountID) REFERENCES "ams.mwAccountProperty"(AccountID),
    FOREIGN KEY(dstAccountID) REFERENCES "ams.mwAccountProperty"(AccountID),

    -- ? add unique constraint to avoid duplicate entry
    UNIQUE(srcAccountID, dstAccountID, _trxType)
);

CREATE TABLE IF NOT EXISTS "ams.DEMATTransactions" (
    _id       INTEGER PRIMARY KEY AUTOINCREMENT,
    AccountID VARCHAR(32) NOT NULL,

    -- ? ISIN is considered as the primary key, as certain
    -- transactions comes with a tag like `-BE`, `-T` which can
    -- be avoided and also, ISIN number is unique for stocks listed
    -- in both NSE and BSE which have different symbols
    ISIN VARCHAR(12) NOT NULL, -- ? https://www.investopedia.com/terms/i/isin.asp
    _sym VARCHAR(24) NOT NULL, -- ! todo delete this on symbol master setup

    -- other information to trade informetions::
    tradeDate DATE NOT NULL,
    exchgName VARCHAR(5) NOT NULL,
    
    -- ? segment and series name needs understanding
    segmentName VARCHAR(5),
    seriesName  VARCHAR(5),

    -- TODO: create a master for this
    tradeType VARCHAR(5) NOT NULL,
    onAuction INTEGER CHECK(onAuction IN (0, 1)),
    
    -- ! quantity is total order value, price is per unit
    tradeQuantity INTEGER NOT NULL,
    _symUnitPrice DECIMAL(7, 3) NOT NULL,

    -- optional informations, kept, todo develop use-cases
    _trade_id VARCHAR(16),
    _order_id VARCHAR(24),
    
    -- order execution time is also provided by brokers
    orderExecutionTime DATETIME,

    -- specify created/updated on timestamp for verification
    created_on DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_on DATETIME DEFAULT NULL,

    FOREIGN KEY(ISIN) REFERENCES "mwSymbolDetails"(ISINCode),
    FOREIGN KEY(AccountID) REFERENCES "ams.mwAccountProperty"(AccountID)
);
