CREATE TABLE UserMaster (
	UUID string,
	username string,
	FirstName string,
	MiddleName string,
	LastName string,
	email string,
	password string,
	mobile string,
	RoleID string
);

CREATE TABLE AccountDetails (
	AccountID integer,
	IFSCCode string,
	CIFNumber string,
	OpenDate date,
	CloseDate date,
	UUID string,
	ACTypeID string
);

CREATE TABLE RolesType (
	RoleID string,
	RoleName string
);

CREATE TABLE AccountType (
	ACTypeID string,
	ACTypeName string
);

CREATE TABLE UserTransactions (
	ID integer PRIMARY KEY AUTOINCREMENT,
	TransactionDate timestamp,
	TransactionDetails string,
	TransactionType string,
	TransactionAmount decimal,
	AccountID integer
);






