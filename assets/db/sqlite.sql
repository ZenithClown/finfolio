-- use this file to create a SQLite database

CREATE TABLE emailMaster (
	GUID varchar,
	typeID varchar,
	address varchar
);

CREATE TABLE emailTypeMaster (
	typeID varchar,
	acronym varchar,
	description varchar
);

CREATE TABLE history (
	ID integer PRIMARY KEY AUTOINCREMENT,
	datetime datetime,
	sender varchar,
	receiver varchar,
	remarks varchar
);

CREATE TABLE subscribers (
	ID integer PRIMARY KEY AUTOINCREMENT,
	subscriber varchar,
	preferences varchar,
	isActive boolean
);

CREATE TABLE preferenceMaster (
	ID integer PRIMARY KEY AUTOINCREMENT,
	type varchar,
	remarks varchar
);






