CREATE TABLE [UserMaster] (
	UUID string(64) NOT NULL,
	username string(64) NOT NULL UNIQUE,
	FirstName string(128) NOT NULL,
	MiddleName string(128),
	LastName string(128) NOT NULL,
	email string(256) UNIQUE,
	password string(1024) NOT NULL,
	mobile string(16),
	RoleID string(64) NOT NULL,
  CONSTRAINT [PK_USERMASTER] PRIMARY KEY CLUSTERED
  (
  [UUID] ASC
  ) WITH (IGNORE_DUP_KEY = OFF)

)
GO
CREATE TABLE [AccountDetails] (
	AccountID integer NOT NULL,
	IFSCCode string(16),
	CIFNumber string(16),
	OpenDate date NOT NULL,
	CloseDate date,
	UUID string(64) NOT NULL,
	ACTypeID string(64) NOT NULL,
  CONSTRAINT [PK_ACCOUNTDETAILS] PRIMARY KEY CLUSTERED
  (
  [AccountID] ASC
  ) WITH (IGNORE_DUP_KEY = OFF)

)
GO
CREATE TABLE [RolesType] (
	RoleID string(64) NOT NULL,
	RoleName string(16) NOT NULL UNIQUE,
  CONSTRAINT [PK_ROLESTYPE] PRIMARY KEY CLUSTERED
  (
  [RoleID] ASC
  ) WITH (IGNORE_DUP_KEY = OFF)

)
GO
CREATE TABLE [AccountType] (
	ACTypeID string(64) NOT NULL,
	ACTypeName string(16) NOT NULL UNIQUE,
  CONSTRAINT [PK_ACCOUNTTYPE] PRIMARY KEY CLUSTERED
  (
  [ACTypeID] ASC
  ) WITH (IGNORE_DUP_KEY = OFF)

)
GO
CREATE TABLE [UserTransactions] (
	ID integer NOT NULL,
	TransactionDate timestamp NOT NULL,
	TransactionDetails string(1024) NOT NULL,
	TransactionType string(8) NOT NULL,
	TransactionAmount decimal(32) NOT NULL,
	AccountID integer(32) NOT NULL,
  CONSTRAINT [PK_USERTRANSACTIONS] PRIMARY KEY CLUSTERED
  (
  [ID] ASC
  ) WITH (IGNORE_DUP_KEY = OFF)

)
GO
ALTER TABLE [UserMaster] WITH CHECK ADD CONSTRAINT [UserMaster_fk0] FOREIGN KEY ([RoleID]) REFERENCES [RolesType]([RoleID])
ON UPDATE CASCADE
GO
ALTER TABLE [UserMaster] CHECK CONSTRAINT [UserMaster_fk0]
GO

ALTER TABLE [AccountDetails] WITH CHECK ADD CONSTRAINT [AccountDetails_fk0] FOREIGN KEY ([UUID]) REFERENCES [UserMaster]([UUID])
ON UPDATE CASCADE
GO
ALTER TABLE [AccountDetails] CHECK CONSTRAINT [AccountDetails_fk0]
GO
ALTER TABLE [AccountDetails] WITH CHECK ADD CONSTRAINT [AccountDetails_fk1] FOREIGN KEY ([ACTypeID]) REFERENCES [AccountType]([ACTypeID])
ON UPDATE CASCADE
GO
ALTER TABLE [AccountDetails] CHECK CONSTRAINT [AccountDetails_fk1]
GO



ALTER TABLE [UserTransactions] WITH CHECK ADD CONSTRAINT [UserTransactions_fk0] FOREIGN KEY ([AccountID]) REFERENCES [AccountDetails]([AccountID])
ON UPDATE CASCADE
GO
ALTER TABLE [UserTransactions] CHECK CONSTRAINT [UserTransactions_fk0]
GO

