/********************************************************************
View Definations Related to the Transactions Posted in FinFolio-DB

Transaction tables should be accessed only from the view tables to
reduce data. In addition, several views are created which are
associated to one particular type of account.

Copywright © [2024] pOrgz-dev, Debmalya Pramanik
********************************************************************/

CREATE VIEW "ams.vwFixedDeposits" AS
    SELECT
        A.FDAccountNumber
        , A.DepositTrxID
        , B.trxDate AS DepositTrxDate
        , B.trxType AS DepositTrxType
        , B.trxAmount AS DepositTrxAmount
        , A.WithdrawTrxID
        , C.trxDate AS WithdrawTrxDate
        , C.trxType AS WithdrawTrxType
        , C.trxAmount AS WithdrawTrxAmount
    FROM "ams.extFixedDeposits" A
    LEFT JOIN "ams.transactions" B ON A.DepositTrxID = B._id
    LEFT JOIN "ams.transactions" C ON A.WithdrawTrxID = C._id
    ORDER BY A.DepositTrxID DESC;
