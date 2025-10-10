/********************************************************************
A Simple Query to Create a New Account Property

The account base property is defined under `ams.mwAccountProperty`
while various other extended properties are added in respective
extended tables with the suffix `ext*` in the `models/ams.accounts`
file. For now,, only the account property is populated while other
tables will be gradually populated.

Copywright © [2024] pOrgz <https://github.com/pOrgz-dev>
********************************************************************/

INSERT INTO "ams.mwAccountProperty" (AccountID, AccountNumber, AccountName, AccountTypeID, AccountSubTypeID, AccountOpenDate, AccountCloseDate)
    VALUES (?, ?, ?, ?, ?, ?, ?);
