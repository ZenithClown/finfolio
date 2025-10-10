/********************************************************************
A Set of View(s) defined to get the Account Details

The account and all related details are colated from the
`ams.accounts` tables and is presented using a master view for BI
usages.

Copywright © [2024] Debmalya Pramanik
********************************************************************/

CREATE VIEW "ams.vwDebitAccount" AS
    SELECT
        A.AccountID AS AccountID
        , CIF
        , IFSC
        , CASE
            WHEN TertiaryPlusHolder IS NOT NULL THEN SecondaryHolder || ',' || TertiaryPlusHolder
            WHEN SecondaryHolder IS NOT NULL THEN SecondaryHolder
            ELSE NULL
            END AS SecondaryAccountHolders
        , AccountNumber
        , AccountName
        , AccountOpenDate
        , AccountCloseDate
        , CASE
            WHEN AccountCloseDate IS NULL THEN ROUND((JULIANDAY(CURRENT_TIMESTAMP) - JULIANDAY(AccountOpenDate)) / 365, 2)
            ELSE ROUND((JULIANDAY(AccountCloseDate) - JULIANDAY(AccountOpenDate)) / 365, 2)
            END AS AccountAgeYears
        , NomineeName
        , NomineeRelationship
    FROM "ams.mwAccountProperty" A
    LEFT JOIN "ams.extDebitAccount" B ON A.AccountID = B.AccountID
    WHERE AccountTypeID = 1

CREATE VIEW "ams.vwTermDeposittAccount" AS
    SELECT
        A.AccountID AS AccountID
        , A.AccountNumber
        , A.AccountName
        , SubTypeName AS AccountType
        , C._description AS AccountTypeLong
        , AccountOpenDate
        , AccountCloseDate
        , DebitAccount
        , D.AccountNumber AS DebitAccountNumber
        , D.AccountName AS DebitAccountName
        , CASE
            WHEN AccountCloseDate IS NULL THEN (JULIANDAY(CURRENT_TIMESTAMP) - JULIANDAY(AccountOpenDate))
            ELSE (JULIANDAY(AccountCloseDate) - JULIANDAY(AccountOpenDate))
            END AS TenureDays
    FROM "ams.mwAccountProperty" A
    LEFT JOIN "ams.extTermDepositAccount" B ON A.AccountID = B.AccountID
    LEFT JOIN "ams.extAccountType" C ON B.AccountSubTypeID = C.AccountSubTypeID
    LEFT JOIN (
        SELECT AccountID, AccountNumber, AccountName FROM "ams.mwAccountProperty"
        WHERE AccountTypeID = 1
    ) D ON B.DebitAccount = D.AccountID
    WHERE A.AccountTypeID = 8
