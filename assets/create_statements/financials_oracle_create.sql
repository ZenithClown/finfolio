CREATE TABLE "UserMaster" (
	"UUID" VARCHAR2(64) NOT NULL,
	"username" VARCHAR2(64) UNIQUE NOT NULL,
	"FirstName" VARCHAR2(128) NOT NULL,
	"MiddleName" VARCHAR2(128),
	"LastName" VARCHAR2(128) NOT NULL,
	"email" VARCHAR2(256) UNIQUE,
	"password" VARCHAR2(1024) NOT NULL,
	"mobile" VARCHAR2(16),
	"RoleID" VARCHAR2(64) NOT NULL,
	constraint USERMASTER_PK PRIMARY KEY ("UUID"));


/
CREATE TABLE "AccountDetails" (
	"AccountID" INT NOT NULL,
	"IFSCCode" VARCHAR2(16),
	"CIFNumber" VARCHAR2(16),
	"OpenDate" DATE NOT NULL,
	"CloseDate" DATE,
	"UUID" VARCHAR2(64) NOT NULL,
	"ACTypeID" VARCHAR2(64) NOT NULL,
	constraint ACCOUNTDETAILS_PK PRIMARY KEY ("AccountID"));


/
CREATE TABLE "RolesType" (
	"RoleID" VARCHAR2(64) NOT NULL,
	"RoleName" VARCHAR2(16) UNIQUE NOT NULL,
	constraint ROLESTYPE_PK PRIMARY KEY ("RoleID"));


/
CREATE TABLE "AccountType" (
	"ACTypeID" VARCHAR2(64) NOT NULL,
	"ACTypeName" VARCHAR2(16) UNIQUE NOT NULL,
	constraint ACCOUNTTYPE_PK PRIMARY KEY ("ACTypeID"));


/
CREATE TABLE "UserTransactions" (
	"ID" INT NOT NULL,
	"TransactionDate" TIMESTAMP NOT NULL,
	"TransactionDetails" VARCHAR2(1024) NOT NULL,
	"TransactionType" VARCHAR2(8) NOT NULL,
	"TransactionAmount" DECIMAL(32) NOT NULL,
	"AccountID" NUMBER(32, 0) NOT NULL,
	constraint USERTRANSACTIONS_PK PRIMARY KEY ("ID"));

CREATE sequence "USERTRANSACTIONS_ID_SEQ";

CREATE trigger "BI_USERTRANSACTIONS_ID"
  before insert on "UserTransactions"
  for each row
begin
  select "USERTRANSACTIONS_ID_SEQ".nextval into :NEW."ID" from dual;
end;

/
ALTER TABLE "UserMaster" ADD CONSTRAINT "UserMaster_fk0" FOREIGN KEY ("RoleID") REFERENCES "RolesType"("RoleID");

ALTER TABLE "AccountDetails" ADD CONSTRAINT "AccountDetails_fk0" FOREIGN KEY ("UUID") REFERENCES "UserMaster"("UUID");
ALTER TABLE "AccountDetails" ADD CONSTRAINT "AccountDetails_fk1" FOREIGN KEY ("ACTypeID") REFERENCES "AccountType"("ACTypeID");



ALTER TABLE "UserTransactions" ADD CONSTRAINT "UserTransactions_fk0" FOREIGN KEY ("AccountID") REFERENCES "AccountDetails"("AccountID");

