CREATE TABLE `UserMaster` (
	`UUID` VARCHAR(64) NOT NULL,
	`username` VARCHAR(64) NOT NULL UNIQUE,
	`FirstName` VARCHAR(128) NOT NULL,
	`MiddleName` VARCHAR(128),
	`LastName` VARCHAR(128) NOT NULL,
	`email` VARCHAR(256) UNIQUE,
	`password` VARCHAR(1024) NOT NULL,
	`mobile` VARCHAR(16),
	`RoleID` VARCHAR(64) NOT NULL,
	PRIMARY KEY (`UUID`)
);

CREATE TABLE `AccountDetails` (
	`AccountID` INT NOT NULL,
	`IFSCCode` VARCHAR(16),
	`CIFNumber` VARCHAR(16),
	`OpenDate` DATE NOT NULL,
	`CloseDate` DATE,
	`UUID` VARCHAR(64) NOT NULL,
	`ACTypeID` VARCHAR(64) NOT NULL,
	PRIMARY KEY (`AccountID`)
);

CREATE TABLE `RolesType` (
	`RoleID` VARCHAR(64) NOT NULL,
	`RoleName` VARCHAR(16) NOT NULL UNIQUE,
	PRIMARY KEY (`RoleID`)
);

CREATE TABLE `AccountType` (
	`ACTypeID` VARCHAR(64) NOT NULL,
	`ACTypeName` VARCHAR(16) NOT NULL UNIQUE,
	PRIMARY KEY (`ACTypeID`)
);

CREATE TABLE `UserTransactions` (
	`ID` INT NOT NULL AUTO_INCREMENT,
	`TransactionDate` TIMESTAMP NOT NULL,
	`TransactionDetails` VARCHAR(1024) NOT NULL,
	`TransactionType` VARCHAR(8) NOT NULL,
	`TransactionAmount` DECIMAL(32) NOT NULL,
	`AccountID` INT(32) NOT NULL,
	PRIMARY KEY (`ID`)
);

ALTER TABLE `UserMaster` ADD CONSTRAINT `UserMaster_fk0` FOREIGN KEY (`RoleID`) REFERENCES `RolesType`(`RoleID`);

ALTER TABLE `AccountDetails` ADD CONSTRAINT `AccountDetails_fk0` FOREIGN KEY (`UUID`) REFERENCES `UserMaster`(`UUID`);

ALTER TABLE `AccountDetails` ADD CONSTRAINT `AccountDetails_fk1` FOREIGN KEY (`ACTypeID`) REFERENCES `AccountType`(`ACTypeID`);

ALTER TABLE `UserTransactions` ADD CONSTRAINT `UserTransactions_fk0` FOREIGN KEY (`AccountID`) REFERENCES `AccountDetails`(`AccountID`);






