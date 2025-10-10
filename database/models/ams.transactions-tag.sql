/********************************************************************
A Set of TAG(s) Defined to Categorize Transactions

The tags are maintained at different level, like account, method, end
user tags, etc. which can be used for categorizing the transactions
and thus in better reporting.

Adopted Notation: This is a master table with pre-configured data,
maintained for simplification of end-usage report generation. By
default, the tables are named like:

```
ams.dmw_<column-name>
```

Where, `dmw` stands for "derived master" records, and this is a new
suffix added into the project. In case, the original column names
starts with a leading (`_`, i.e.,, in case of derived columns) then
only single (`_`) sign. The tagged `id` column is always named like:

```
_<column-name>_id TYPE PRIMARY KEY # snake case column name
```

In addition, all the tables have a field `_search_terms` which is
defined for automatic tagging by code purpose. The value is comma
seperated, and most of the time is of no use to the end user.

Copywright © [2024] Debmalya Pramanik
********************************************************************/

CREATE TABLE IF NOT EXISTS "ams.dmw_trxMethod" (
    _method_id   VARCHAR(8) PRIMARY KEY,
    _method_desc VARCHAR(128) NOT NULL,

    _search_terms VARCHAR(256) UNIQUE NOT NULL
);

CREATE TABLE IF NOT EXISTS "ams.dmw_trxAccount" (
    _account_id   VARCHAR(16) PRIMARY KEY,
    _account_name VARCHAR(128) UNIQUE NOT NULL,
    
    -- ! each can have a different type, which is not
    -- related to `mwAccountType` table, but is for
    -- maintaing tags for accounts which can be used
    -- in a combined report/filtering a data subset
    -- ? account details are maintained as below:
    -- useful for grouping different levels, like work
    _account_type VARCHAR(16) NOT NULL,
    _account_desc VARCHAR(64) NOT NULL,

    _search_terms VARCHAR(256) UNIQUE NOT NULL
);
