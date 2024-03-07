CREATE TABLE "public.UserMaster" (
	"UUID" VARCHAR(64) NOT NULL,
	"username" VARCHAR(64) NOT NULL UNIQUE,
	"FirstName" VARCHAR(128) NOT NULL,
	"MiddleName" VARCHAR(128),
	"LastName" VARCHAR(128) NOT NULL,
	"email" VARCHAR(256) UNIQUE,
	"password" VARCHAR(1024) NOT NULL,
	"mobile" VARCHAR(16),
	"RoleID" VARCHAR(64) NOT NULL,
	CONSTRAINT "UserMaster_pk" PRIMARY KEY ("UUID")
) WITH (
  OIDS=FALSE
);



CREATE TABLE "public.AccountDetails" (
	"AccountID" integer NOT NULL,
	"IFSCCode" VARCHAR(16),
	"CIFNumber" VARCHAR(16),
	"OpenDate" DATE NOT NULL,
	"CloseDate" DATE,
	"UUID" VARCHAR(64) NOT NULL,
	"ACTypeID" VARCHAR(64) NOT NULL,
	CONSTRAINT "AccountDetails_pk" PRIMARY KEY ("AccountID")
) WITH (
  OIDS=FALSE
);



CREATE TABLE "public.RolesType" (
	"RoleID" VARCHAR(64) NOT NULL,
	"RoleName" VARCHAR(16) NOT NULL UNIQUE,
	CONSTRAINT "RolesType_pk" PRIMARY KEY ("RoleID")
) WITH (
  OIDS=FALSE
);



CREATE TABLE "public.AccountType" (
	"ACTypeID" VARCHAR(64) NOT NULL,
	"ACTypeName" VARCHAR(16) NOT NULL UNIQUE,
	CONSTRAINT "AccountType_pk" PRIMARY KEY ("ACTypeID")
) WITH (
  OIDS=FALSE
);



CREATE TABLE "public.UserTransactions" (
	"ID" serial NOT NULL,
	"TransactionDate" TIMESTAMP NOT NULL,
	"TransactionDetails" VARCHAR(1024) NOT NULL,
	"TransactionType" VARCHAR(8) NOT NULL,
	"TransactionAmount" DECIMAL(32) NOT NULL,
	"AccountID" integer(32) NOT NULL,
	CONSTRAINT "UserTransactions_pk" PRIMARY KEY ("ID")
) WITH (
  OIDS=FALSE
);



ALTER TABLE "UserMaster" ADD CONSTRAINT "UserMaster_fk0" FOREIGN KEY ("RoleID") REFERENCES "RolesType"("RoleID");

ALTER TABLE "AccountDetails" ADD CONSTRAINT "AccountDetails_fk0" FOREIGN KEY ("UUID") REFERENCES "UserMaster"("UUID");
ALTER TABLE "AccountDetails" ADD CONSTRAINT "AccountDetails_fk1" FOREIGN KEY ("ACTypeID") REFERENCES "AccountType"("ACTypeID");



ALTER TABLE "UserTransactions" ADD CONSTRAINT "UserTransactions_fk0" FOREIGN KEY ("AccountID") REFERENCES "AccountDetails"("AccountID");






