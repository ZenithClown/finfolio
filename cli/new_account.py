# -*- encoding: utf-8 -*-

"""
A Set of Interface Function to Create a New A/C

The python interface to create a new type of account and store the
data into the FinFolio-DB system.

@author:  pOrgz, Debmalya Pramanik
@version: v0.0.1
"""

from uuid import uuid4 as UUID

def setAccountProperty(subtypes : list) -> tuple:
    """
    Fetch Primary Account Opening Details from User

    Primary account opening details are populated into the table
    `ams.mwAccountProperty` while all the extended table informations
    are fetched using `set*****Account()` functions.
    """

    _random_new_uuid = str(UUID()).upper()
    AccountID = input(f"Create a New Account ID [{_random_new_uuid}]: ") or _random_new_uuid
    AccountNumber = int(input(f"Enter Account Number: "))
    AccountName = input(f"Set an Account Name: ")
    AccountOpenDate = input(f"Account Opening Date (YYYY-MM-DD): ")
    AccountCloseDate = input(f"Account Closing Date (YYYY-MM-DD): ") or None

    print("\nRegister a Sub-Type with the Account: ")
    print("  >> 0 : No Sub Type")
    for idx, subtype in enumerate(subtypes):
        subtype = f"{subtype[0]} ({subtype[1]})"
        print(f"  >> {idx + 1} : {subtype}")

    choice_ = int(input("Enter Sub-Type Number: "))
    AccountSubTypeID = None if choice_ == 0 else subtypes[choice_ - 1][0]

    return (AccountID, AccountNumber, AccountName, AccountSubTypeID, AccountOpenDate, AccountCloseDate)


def setDebitAccount(subtypes : list) -> tuple:
    """
    Create/Register a New DEBIT (Savings, Salary, Current) Account

    The python-interface function to create and register a new debit
    card account. Since, this is part of a CLI application, the
    functions prompts the opening questions only in terminal.
    """

    AccountTypeID = "DBT" # always constant
    AccountID, AccountNumber, AccountName, AccountSubTypeID, AccountOpenDate, AccountCloseDate = setAccountProperty(subtypes)

    # ? setting additional properties as per extended table schema:
    CIF = input("Enter Associated CIF Number: ")
    IFSC = input("Enter Associated IFSC Number: ")

    SecondaryHolder = input("Secondary Account Holder: ") or None
    TertiaryPlusHolder = input("Other Associated Account Holder (csv): ") or None

    NomineeName = input("Nominee Name: ") or None
    NomineeRelationship = input("Nominee Relationship: ") or None

    return (
        (AccountID, AccountNumber, AccountName, AccountTypeID, AccountSubTypeID, AccountOpenDate, AccountCloseDate),
        (AccountID, CIF, IFSC, SecondaryHolder, TertiaryPlusHolder, NomineeName, NomineeRelationship)
    )


def setTDAccount(subtypes : list, accounts : list) -> tuple:
    """
    Create/Register a New DEBIT (Savings, Salary, Current) Account

    The python-interface function to create and register a new debit
    card account. Since, this is part of a CLI application, the
    functions prompts the opening questions only in terminal.
    """

    AccountTypeID = "DBT" # always constant
    AccountID, AccountNumber, AccountName, AccountSubTypeID, AccountOpenDate, AccountCloseDate = setAccountProperty(subtypes)

    print("\nLinked Primary/DEBIT Account: ")
    for idx, account in enumerate(accounts):
        account = f"{account[2]} ({account[1]})"
        print(f"  >> {idx + 1} : {account}")

    choice_ = int(input("Enter Account Choice Number: "))
    DebitAccount = accounts[choice_ - 1][0]

    OperationMode = input("Operation Mode: ") or None
    SchemeDetails = input("Scheme Details: ") or None
    MaturityDetails = input("Maturity Details: ") or None

    TDRemarks = input("Remarks (example: 'savings for super-computer'; csv): ") or None
    return (
        (AccountID, AccountNumber, AccountName, AccountTypeID, AccountSubTypeID, AccountOpenDate, AccountCloseDate),
        (AccountID, DebitAccount, OperationMode, SchemeDetails, MaturityDetails, TDRemarks)
    )
