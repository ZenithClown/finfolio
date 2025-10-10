<div align = "center">

# WorldDB

**_an `api` designed to fetch world informations_**

</div>

<div align = "justify">

## Objective

🧾 The repository provides an 🎉✨ *open-source alternate* places information API. The data has been collected from various sources and formatted to create a compact database structure.

## Table(s) & Description(s)

### Standard Notation

* A table name is `lowercase` and words are seperated by `_` sign.
* Column Names are in `CamalCase` (also called `PascalCase`) with additional notation like:
  - PKs are defined like `{TableName}ID` - example `CountryID` for `country` table etc.
  - A PK is named as `_id` when not to be used, as in transactional tables.

### Country Master Table (`country`)

The SQL counterpart table contains bare minimum information about a country with static contents (which are not going to change, ever) linked with various NoSQL tables to get additional informations.

</div>
