<div align = "center">

<img src = "./assets/logo.png" height = "128" width = "128" />
<h1 align = "center">OAuth REST API</h1>

</div>

<p align = "justify"><b>OAuth REST API</b> is a <i>high-level</i> interface designed for user authentication and security for <a href = "https://github.com/pOrgz/pOrgz-py"><b>pOrgz</b></a>. Built using <i>flask</i>, which is a <q>micro web framework</q>, and can be compiled with <b>python 3.7+</b> (as it uses the <i>f-string</i> conventions).</p>

## Setup

<p align = "justify">A list of minimal required package for running this application is available, and can be installed using <code>pip install -r requirements.txt</code>. By default, this application runs on <code>localhost:5000</code>, however everything is changeble/configurable using environment variables, which are defined as follows:</p>

| VARIABLE NAME | Defination/Remarks | Settings |
| :---: | --- | :---: |
| **port** | PORT on which flask application will run. | 5000 |
| **host** | HOST name/address for flask application. | localhost |
| PROJECT_ENV_NAME | Name of the Project Environment, signifies the type of application hosting.<br>It can be one of the following:<br>- `dev` : signifies development setup, i.e. the *flask* application will be running on *debugging* mode,<br>- `test` : environment for testing, and<br>- `prod` : production environment setup. | dev |
| **database_host** | Host address where the database resides. | localhost |
| **username** | Username for connecting to database. | `None` |
| **password** | Password for connecting to database. | `None` |
| **DATABASE_URL** | Full database URI (like one of MySQL, SQLite, PSQL, etc.).<br>Syntax for different databse is as follows:<br>- **MySQL** : `mysql+pymysql://username:password@database_host`.<br>- **SQLite** : *todo*. | *MySQL* |
| dev_db | Development Database Name | pOrgz |
| test_db | Production Database Name | test |

[SQLAlchemy Engine String](https://docs.sqlalchemy.org/en/14/core/engines.html)

### Password Security and Encryption

<p align = "justify">As decided earlier, <b>pOrgz</b> is currently set to work in localhost environment, safegurding user informations locally. Though local, there are certain security measures developed, one of which is encrypting the password, and using salting to save the password in the database - making it secure even if you are using a simple database like SQLite.</p>

<p align = "justify">The simple salting method used here is of style : <code>forward_salt + actual_password + backward_salt</code>, where <code>forward_salt</code> and <code>backward_salt</code> depends on the user and can be set to PATH/Environment Variables as desired - if not configured, it only saves the password using <code>SHA-256</code> encryption.</p>

## API Return JSON

<p align = "justify">All type of Authentication API will follow a general structure, which is summarized as below. For <code>login</code> authentication, there is no <code>data</code> block in the return JSON.</p>

```json
{
    "status" : {
        "type"    : "<str>  JSON Message Type : Generally a String Representing the APIs [`login` or `signup`]",
        "message" : "<str>  Message Body",
        "code"    : 200,
        "error"   : "<bool> `True` : Compilation or Programming Error Message, if Received; else `False`"
    },
    "data" : {
        "status" : "<str> Main Message - which is either `success` or `failed`, representing login/signup",
        "user"   : {
            "user-id"  : "<str> User ID Associated (a new ID on registration or an existing ID on login)",
            "username" : "<str> Username, as provided during Login",
            "email"    : "<str> Email Address - from DB (optional)",
            "fullname" : "<str> Full Name of the Login Person (as per Requirement)"
        },
        "remarks"  : "<str> Reason if `status` = `failed` else `None`",
        "errorMsg" : "<str> Error Traceback as Thrown by Python-Compiler"
    },
    "time" : "<str> Time on which Login/Signup is Requested"
}
```

```json
{
    "status" : {
        "type"    : "<str>  JSON Message Type : Generally a String Representing the APIs [`login` or `signup`]",
        "message" : "<str>  Message Body",
        "code"    : 200,
        "error"   : "<bool> `True` : Compilation or Programming Error Message, if Received; else `False`"
    },
    "time"     : "<str> Time on which Login/Signup is Requested",
    "errorMsg" : "<str> Error Traceback as Thrown by Python-Compiler"
}
```

## Dependency for `importlib-resources`
Python version 3.7 and above supports `importlib.resources` instead of `importlib_resources`. If using a version lower than 3.7, then install required dependency using `pip install importlib-resources`, however apart from this, the code should run in `py36` without a problem. Check `.github/gunicorn-server-py36.yml` to run a dependency check.

## Docker Information
Setting up docker files for testing and development ease. Use `docker-compose -f dummy-db.yml up` to setup a testing environment which uses `MySQL v5.7`. TODO: create table, schema and default data for testing.

## Utility Functions

<p align = "justify">To properly function and operate the <a href = "https://github.com/pOrgz-dev"><b>pOrgz-dev</b></a>, a list of utility functions, boilerplate designs, template files, etc. are provided in this repository. Check individual submodules for more information(s).</p>
