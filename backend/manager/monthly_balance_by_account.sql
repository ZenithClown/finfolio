/********************************************************************
A View of DBT Transactions to Fetch Monthly Balanace for an A/C

The account monthly overview showcases the balance at the end of each
month by querying the database. The SQL statement is designed to get
values from database using the `params` like:

```python
con = db.connect(.../FinFolio-DB.db)
montlyBalanaceView = con.execute(statement, params = (account_name))

# then using the `numpy` the monthly balance is:
monthlyBalanceView["balance"] = np.cumsum(
    monthlyBalanceView["trx_amount"].values
)
```

To ensure `np.cumsum`, the table/view must be ordered in ascending
order by date, which is the default return view.

Copywright © [2024] pOrgz-dev, Debmalya Pramanik
********************************************************************/

SELECT
    STRFTIME('%Y-%m', trx_date) AS trx_month
    , SUM ( CASE
        WHEN trx_type = 'DEPOSIT' THEN trx_amount
        WHEN trx_type = 'WITHDRAW' THEN - trx_amount
        ELSE 0
    END ) AS trx_amount
FROM "ams.DBTTransactions" A
LEFT JOIN "ams.mwAccountProperty" B ON A.account_id = B.account_id
WHERE B.account_name = '{account_name}'
GROUP BY trx_month
ORDER BY trx_month
