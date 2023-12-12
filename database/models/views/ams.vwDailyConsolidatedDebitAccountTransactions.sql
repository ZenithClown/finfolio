CREATE VIEW "ams.vwDailyConsolidatedDebitAccountTransactions" AS
    SELECT
        debit_ac_trxs.AccountID
        , debit_ac_trxs.AccountNumber
        , debit_ac_trxs.AccountName
        , debit_ac_trxs.TransactionDate
        , SUM(CASE WHEN debit_ac_trxs.TransactionType = 'DEPOSIT' THEN debit_ac_trxs.TransactionAmount ELSE 0 END) AS TotalDeposit
        , SUM(CASE WHEN debit_ac_trxs.TransactionType = 'WITHDRAW' THEN debit_ac_trxs.TransactionAmount ELSE 0 END) AS TotalWithdrawal
        , SUM(
            (CASE WHEN debit_ac_trxs.TransactionType = 'DEPOSIT' THEN debit_ac_trxs.TransactionAmount ELSE 0 END)
            - (CASE WHEN debit_ac_trxs.TransactionType = 'WITHDRAW' THEN debit_ac_trxs.TransactionAmount ELSE 0 END)
        ) AS DayBalance
    FROM
    (
        SELECT
            A.AccountID AS AccountID
            , AccountNumber
            , AccountName
            , trxDate AS TransactionDate
            , trxAmount AS TransactionAmount
            , trxType AS TransactionType
        FROM "ams.transactions" A
        LEFT JOIN "ams.mwAccountProperty" B ON A.AccountID = B.AccountID
    ) AS debit_ac_trxs
    GROUP BY
        debit_ac_trxs.AccountID
        , debit_ac_trxs.AccountNumber
        , debit_ac_trxs.AccountName
        , debit_ac_trxs.TransactionDate
    ORDER BY debit_ac_trxs.TransactionDate DESC
