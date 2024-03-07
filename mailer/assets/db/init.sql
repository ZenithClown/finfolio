-- MySQL DB Initialization Commands - initialize docker image with `init`-parameters

CREATE DATABASE IF NOT EXISTS mails;

-- use a database names `mails` for storing all informations
USE mails;

CREATE TABLE `emailMaster` (
	`GUID` varchar(36) NOT NULL,
	`typeID` varchar(64) NOT NULL UNIQUE,
	`address` varchar(255) NOT NULL UNIQUE,
	PRIMARY KEY (`GUID`,`address`)
);

CREATE TABLE `emailTypeMaster` (
	`typeID` varchar(8) NOT NULL,
	`acronym` varchar(64),
	`description` varchar(128),
	PRIMARY KEY (`typeID`)
);

CREATE TABLE `history` (
	`ID` INT NOT NULL AUTO_INCREMENT,
	`datetime` DATETIME(64) NOT NULL,
	`sender` varchar(36) NOT NULL,
	`receiver` varchar(36) NOT NULL,
	`remarks` varchar(255),
	PRIMARY KEY (`ID`)
);

CREATE TABLE `subscribers` (
	`ID` INT NOT NULL AUTO_INCREMENT,
	`subscriber` varchar(255) NOT NULL,
	`preferences` varchar(255) NOT NULL,
	`isActive` BOOLEAN NOT NULL,
	PRIMARY KEY (`ID`)
);

CREATE TABLE `preferenceMaster` (
	`ID` INT NOT NULL AUTO_INCREMENT,
	`type` varchar(64) NOT NULL UNIQUE,
	`remarks` varchar(255) UNIQUE,
	PRIMARY KEY (`ID`)
);

ALTER TABLE `emailMaster` ADD CONSTRAINT `emailMaster_fk0` FOREIGN KEY (`typeID`) REFERENCES `emailTypeMaster`(`typeID`);

ALTER TABLE `history` ADD CONSTRAINT `history_fk0` FOREIGN KEY (`sender`) REFERENCES `emailMaster`(`GUID`);

ALTER TABLE `history` ADD CONSTRAINT `history_fk1` FOREIGN KEY (`receiver`) REFERENCES `emailMaster`(`GUID`);

ALTER TABLE `subscribers` ADD CONSTRAINT `subscribers_fk0` FOREIGN KEY (`subscriber`) REFERENCES `emailMaster`(`GUID`);

ALTER TABLE `subscribers` ADD CONSTRAINT `subscribers_fk1` FOREIGN KEY (`preferences`) REFERENCES `preferenceMaster`(`ID`);
