/************************************************
SCHEMA Name: LocationMaster

Usage: The following tables can be  used to keep
track of registered user's place of origin. This
is just a basic information that may be shown in
the profile page.

@author: pOrgz-dev
@contact: pOrgz@tuta.io
************************************************/

-- Setup Schema (Run the Below Code for First Time Use ONLY)
DROP SCHEMA IF EXISTS `LocationMaster`; -- WARNING: Deletes an existing schema.

/************** SCHEMA INFORMATION **************
Default CHARecter Set: utf8mb4

Create and select the schema. Finally, execute
all table create statements.
************************************************/
CREATE SCHEMA `LocationMaster` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;
USE `LocationMaster`; -- selects the database for operation

CREATE TABLE `CountryMaster` (
	`CountryID` CHAR(8) NOT NULL,
	`CountryName` VARCHAR(128) NOT NULL UNIQUE,
	`ISO3` CHAR(3) NOT NULL UNIQUE,
	`ISO2` CHAR(2) UNIQUE,
	`NumericCode` INTEGER NOT NULL UNIQUE,
	`RegionID` CHAR(8),
	`CurrencyCode` CHAR(3) NOT NULL,
	`TLDCode` CHAR(3) NOT NULL,
	`CountryLat` DECIMAL(6, 3),
	`CountryLon` DECIMAL(6, 3),
	`CountryCapital` CHAR(8),
	PRIMARY KEY (`CountryID`)
);

CREATE TABLE `RegionMaster` (
	`RegionID` CHAR(8) NOT NULL,
	`RegionName` VARCHAR(32) NOT NULL,
	`SubRegionName` VARCHAR(64) NOT NULL UNIQUE,
	PRIMARY KEY (`RegionID`)
);

CREATE TABLE `CurrencyMaster` (
	`CurrencyCode` CHAR(3) NOT NULL,
	`CurrencyName` VARCHAR(40) NOT NULL UNIQUE,
	`CurrencySymbol` VARCHAR(8) NOT NULL,
	PRIMARY KEY (`CurrencyCode`)
);

CREATE TABLE `StateMaster` (
	`StateID` char(8) NOT NULL,
	`StateName` varchar(128) NOT NULL,
	`StateCode` varchar(5),
	`CountryID` char(8),
	`StateLat` DECIMAL(10, 6),
	`StateLon` DECIMAL(10, 6),
	PRIMARY KEY (`StateID`)
);

/************* FOREIGN KEY DETAILS **************
Definations of all foreign keys are defined here.
By convention, the name is set as:
`fk#_originating-table_reference-table`, i.e.

`#` : A unique number, representing the number
of foreign key present in a table.
`originating-table` : Name of the table where
the key is set as foreign key.
`reference-table` : Reference table name.
************************************************/
ALTER TABLE `CountryMaster` ADD CONSTRAINT `fk0_country_region` FOREIGN KEY (`RegionID`) REFERENCES `RegionMaster`(`RegionID`);
-- TODO Check Foreign Key Integrity Error: sqlalchemy.exc.IntegrityError: (pymysql.err.IntegrityError)
-- (1452, 'Cannot add or update a child row: a foreign key constraint fails
-- (`LocationMaster`.`CountryMaster`, CONSTRAINT `fk1_country_states` FOREIGN KEY (`CountryCapital`) REFERENCES `StateMaster` (`StateID`))')
-- ALTER TABLE `CountryMaster` ADD CONSTRAINT `fk1_country_states` FOREIGN KEY (`CountryCapital`) REFERENCES `StateMaster`(`StateID`);
ALTER TABLE `CountryMaster` ADD CONSTRAINT `fk2_country_currency` FOREIGN KEY (`CurrencyCode`) REFERENCES `CurrencyMaster`(`CurrencyCode`);
ALTER TABLE `StateMaster` ADD CONSTRAINT `fk0_states_country` FOREIGN KEY (`CountryID`) REFERENCES `CountryMaster`(`CountryID`);