-- use this to create tables in `MS-SQL Server`

CREATE TABLE [emailMaster] (
	GUID varchar(36) NOT NULL,
	typeID varchar(64) NOT NULL UNIQUE,
	address varchar(255) NOT NULL UNIQUE,
  CONSTRAINT [PK_EMAILMASTER] PRIMARY KEY CLUSTERED
  (
  [GUID] ASC
  ) WITH (IGNORE_DUP_KEY = OFF)

)
GO
CREATE TABLE [emailTypeMaster] (
	typeID varchar(8) NOT NULL,
	acronym varchar(64),
	description varchar(128),
  CONSTRAINT [PK_EMAILTYPEMASTER] PRIMARY KEY CLUSTERED
  (
  [typeID] ASC
  ) WITH (IGNORE_DUP_KEY = OFF)

)
GO
CREATE TABLE [history] (
	ID integer NOT NULL,
	datetime datetime(64) NOT NULL,
	sender varchar(36) NOT NULL,
	receiver varchar(36) NOT NULL,
	remarks varchar(255),
  CONSTRAINT [PK_HISTORY] PRIMARY KEY CLUSTERED
  (
  [ID] ASC
  ) WITH (IGNORE_DUP_KEY = OFF)

)
GO
CREATE TABLE [subscribers] (
	ID integer NOT NULL,
	subscriber varchar(255) NOT NULL,
	preferences varchar(255) NOT NULL,
	isActive boolean NOT NULL,
  CONSTRAINT [PK_SUBSCRIBERS] PRIMARY KEY CLUSTERED
  (
  [ID] ASC
  ) WITH (IGNORE_DUP_KEY = OFF)

)
GO
CREATE TABLE [preferenceMaster] (
	ID integer NOT NULL,
	type varchar(64) NOT NULL UNIQUE,
	remarks varchar(255) UNIQUE,
  CONSTRAINT [PK_PREFERENCEMASTER] PRIMARY KEY CLUSTERED
  (
  [ID] ASC
  ) WITH (IGNORE_DUP_KEY = OFF)

)
GO
ALTER TABLE [emailMaster] WITH CHECK ADD CONSTRAINT [emailMaster_fk0] FOREIGN KEY ([typeID]) REFERENCES [emailTypeMaster]([typeID])
ON UPDATE CASCADE
GO
ALTER TABLE [emailMaster] CHECK CONSTRAINT [emailMaster_fk0]
GO


ALTER TABLE [history] WITH CHECK ADD CONSTRAINT [history_fk0] FOREIGN KEY ([sender]) REFERENCES [emailMaster]([GUID])
ON UPDATE CASCADE
GO
ALTER TABLE [history] CHECK CONSTRAINT [history_fk0]
GO
ALTER TABLE [history] WITH CHECK ADD CONSTRAINT [history_fk1] FOREIGN KEY ([receiver]) REFERENCES [emailMaster]([GUID])
ON UPDATE CASCADE
GO
ALTER TABLE [history] CHECK CONSTRAINT [history_fk1]
GO

ALTER TABLE [subscribers] WITH CHECK ADD CONSTRAINT [subscribers_fk0] FOREIGN KEY ([subscriber]) REFERENCES [emailMaster]([GUID])
ON UPDATE CASCADE
GO
ALTER TABLE [subscribers] CHECK CONSTRAINT [subscribers_fk0]
GO
ALTER TABLE [subscribers] WITH CHECK ADD CONSTRAINT [subscribers_fk1] FOREIGN KEY ([preferences]) REFERENCES [preferenceMaster]([ID])
ON UPDATE CASCADE
GO
ALTER TABLE [subscribers] CHECK CONSTRAINT [subscribers_fk1]
GO


