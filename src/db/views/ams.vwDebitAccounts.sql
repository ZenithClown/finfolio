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
