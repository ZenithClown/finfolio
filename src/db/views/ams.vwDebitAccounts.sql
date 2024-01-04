CREATE VIEW "ams.vwDebitAccounts" AS
    SELECT
        A.AccountID AS AccountID
        , CIF
        , IFSC
        , CASE
            WHEN QuaternaryHolder IS NOT NULL THEN SecondaryHolder || ',' || TertiaryHolder || ',' || QuaternaryHolder
            WHEN TertiaryHolder IS NOT NULL THEN SecondaryHolder || ',' || TertiaryHolder
            WHEN SecondaryHolder IS NOT NULL THEN SecondaryHolder
            ELSE NULL
            END AS SecondaryAccountHolders
        , CASE
            WHEN QuaternaryHolder IS NOT NULL THEN 4
            WHEN TertiaryHolder IS NOT NULL THEN 3
            WHEN SecondaryHolder IS NOT NULL THEN 2
            ELSE 1
            END AS NumHolders
        , AccountNumber
        , AccountName
        , AccountOpenDate
        , AccountCloseDate
        , CASE
            WHEN AccountCloseDate IS NULL THEN ROUND((JULIANDAY(CURRENT_TIMESTAMP) - JULIANDAY(AccountOpenDate)) / 365, 2) || ' years'
            ELSE ROUND((JULIANDAY(AccountCloseDate) - JULIANDAY(AccountOpenDate)) / 365, 2) || ' years'
            END AS AccountAge
        , CASE
            WHEN _hasNominee = 0 OR _hasNominee IS NULL THEN 'WARN: Need to update nominee details as per mandate.'
            ELSE NULL
            END AS NomineeDetails
        , NomineeName
        , NomineeRelationship
    FROM "ams.mwAccountProperty" A

    LEFT JOIN "ams.mwDebitAccountProperty" B ON A.AccountID = B.AccountID

    WHERE AccountTypeID = 1
