CREATE VIEW "ams.vwMonthlyConsolidatedDebitAccountTransactions" AS
    SELECT
        AccountID
        , AccountNumber
        , AccountName
        , STRFTIME('%Y-%m', TransactionDate) AS TransactionMonth
        , ROUND(SUM(TotalDeposit), 2) AS MonthTotalDeposit
        , ROUND(SUM(TotalWithdrawal), 2) AS MonthTotalWithdrawal
        , ROUND(SUM(DayBalance), 2) AS MonthBalance
    FROM "ams.vwDailyConsolidatedDebitAccountTransactions"
    GROUP BY AccountID, AccountNumber, AccountName, TransactionMonth
    ORDER BY TransactionMonth DESC
