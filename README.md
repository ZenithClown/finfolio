<h1 align = "center">
  Personal Portfolio Management Tool <img src = "./static/images/favicon.png" height = "190" width = "175" align = "right" /><br>
  <code>finfolio</code><br>
  <a href = "https://dbdocs.io/dpramanik.official/finfolio"><img src="https://img.shields.io/badge/DBDocs-Documentation-darkgreen?style=plastic&logo=docker"/></a>
  <a href = "https://dbdiagram.io/d/finfolio-66f1c03ca0828f8aa6cc7e4d"><img src="https://img.shields.io/badge/DBDocs-Schema_Explore-darkgreen?style=plastic&logo=databricks"/></a>
</h1>

<div align = "justify">

**Project `finfolio`** is a personal finance management and analysis system that helps individuals track income, expenses, savings, and
investments with **Python**, **PostgreSQL**, and interactive **Power BI dashboards**.

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

This is now a [next.js](https://nextjs.org) project using [prisma](https://www.prisma.io/) to ship scalable database API to
handle user requests. Initialize the project and first run the project under development server like:

```bash
$ npm install # install dependencies with npm
$ npm run dev # run the development server in http://localhost:3000
```

The project uses the [`next/font`](https://nextjs.org/docs/app/building-your-application/optimizing/fonts) and is configured
globally with the constant `defaultFont` to switch between fonts easily as per user's preferences.

</div>
