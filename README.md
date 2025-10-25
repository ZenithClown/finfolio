<h1 align = "center">
  Personal Portfolio Management Tool <img src = "./static/images/favicon.png" height = "190" width = "175" align = "right" /><br>
  <code>finfolio</code><br>
  <a href = "https://dbdocs.io/dpramanik.official/finfolio"><img src="https://img.shields.io/badge/DBDocs-Documentation-darkgreen?style=plastic&logo=docker"/></a>
  <a href = "https://dbdiagram.io/d/finfolio-66f1c03ca0828f8aa6cc7e4d"><img src="https://img.shields.io/badge/DBDocs-Schema_Explore-darkgreen?style=plastic&logo=databricks"/></a>
</h1>

<div align = "justify">

**Project `finfolio`** is a personal finance management and analysis system that helps individuals track income, expenses, savings, and
investments with **Python**, **PostgreSQL**, and interactive **NextJS Admin Dashboard**.

## 📜 Project Objective

Most personal finance tools in the market depend on **third-party integrations** such as email parsing, SMS reading, or
automatic syncing with bank accounts. While convenient, these approaches often come at the cost of **privacy** — data is shared
across multiple platforms, leaving users with little to no control over how their financial information is stored or used. In
addition, most of these apps share personal information which leads to unnecessary telemarketing calls and may trigger other
fradulent activities.

To resolve this, meet **`finfolio`** a project designed with a **privacy-first approach**, ensuring that users maintain complete
ownership of their data. The robust database design makes the application suitable for personal usage that let's you track
expenses, incomes and even plugins added for tracking share market investments (like stocks, mutual funds) and generate summary
notes with LLM powered third-party applications (optional) and other paid tools built on top of the project as an extensions.

### 🔑 Key Objectives

The project has the following key objectives and development stages, complexity (user-friendly), and other important details
are as follows:

<div align = "center">

| MVP Feature | Feature Note | Development Status |
| --- | --- | :---: |
| ✅ **Fully Offline Operation** | Data is Stored and Managed by End-User. | 🚧 |
| ✅ **Zero Third-Party Data Sharing** | No Data Sharing/Third-Party Integration. | 🚧 |
| ✅ **Flexible Data Entry** | Manual/Import Flat Files | 🚧 |
| ✅ **Essential Financial Dashboards** | Intercative PowerBI Dashboard | 🚧 |

</div>

## 📜 Getting Started

This is now a [NextJS](https://nextjs.org) project using [PostgREST](https://docs.postgrest.org/en/v13/) that automatically
provides RESTful API for the underlying tables and data. Since the data is hosted in a secured cloud of choice by the end user,
so any new changes in the database can automatically reflect in the RESTful API design without updating the underlying ORM
models giving the felxibility and reducing coding dependency when the underying is updated.

```shell
npm install # install dependencies with npm
npm run dev # run the development server in http://localhost:3000

# create suitable environment variables that hosts your database
# and this is referenced in the shell script to initialize and host service
# check https://docs.postgrest.org/en/v13/ for more information
export ORACLE_POSTGRES_HOST=localhost
export ORACLE_POSTGRES_PORT=5432

export ORACLE_POSTGRES_USERNAME=webanon
export ORACLE_POSTGRES_PASSWORD=password

# run the postgrest using the ./postgrest.sh
# the configuration is defined under the postgrest.conf
# not the shell script name is same as the service, so ./ is used
./postgrest.sh # API server runs in http://localhost:3100
```

In addition, if you are using a windows machine, then the same can be done by installing PostgREST ZIP file from
[source code](https://github.com/PostgREST/postgrest) and then adding the unzipped file under environment variables. The
script can be run as below:

```powershell
set PGRST_DB_URI=postgres://postgres:password@localhost:port/finfolio
postgrest postgrest.conf
```

The project uses the [`next/font`](https://nextjs.org/docs/app/building-your-application/optimizing/fonts) and is configured
globally with the constant `defaultFont` to switch between fonts easily as per user's preferences.

### RESTful API & Swagger UI Documentation

The PostgREST comes in-built with Swagger UI 2.0 and is available in the root path as per the configuration file. The
file is designed to handle all the necessary schemas that are required currently defined under the `./database` directory
and all the tables have `GET, POST, UPDATE` defined along with.

</div>
