/********************************************************************
Transaction Types Master Tables

Transactions can be of various types and methods which is described
in this table. For example, a DEBIT based account has "deposit" or
"withdrawal" as the transaction type, which CREDIT has different
nomenclature to transaction types.

Copywright © [2023] pOrgz <https://github.com/pOrgz-dev>
********************************************************************/

CREATE TABLE IF NOT EXISTS "ams.mwTransactionTypes" (
    trxType       VARCHAR(16) PRIMARY KEY,
    AccountTypeID INTEGER NOT NULL,
    
    -- let's define a field to identify how to consider the value
    -- `IF(+)`: user point of view, amount is added into the account
    -- `ELSE(-)`: this is an expense for the user and reduces capital
    _trxSymbol VARCHAR(2) NOT NULL,

    -- ? optionally, add a description column for understanding
    _description TEXT, -- ? optional, descriptive information

    FOREIGN KEY(AccountTypeID) REFERENCES "ams.mwAccountType"(AccountTypeID)
);

/*** INSERT PRE-DEFINED (GLOBAL/STATIC) VALUES ***/
INSERT INTO "ams.mwTransactionTypes" (trxType, AccountTypeID, _trxSymbol, _description)
VALUES
    ("DEPOSIT", 1, "+", "The amount is credited (added) to a DEBIT account."),
    ("WITHDRAW", 1, "-", "The amount is debited (removed/taken out) from a DEBIT account."),
    ("DEBIT", 2, "-", "The transaction is made against available credit limit, and has to be paid back to the company."),
    ("CREDIT", 2, "+", "Payment of bill against credited transactions - settled up.");
