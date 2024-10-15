/********************************************************************
Initial Set of Data for the META Tables for the FINFOLIO Application

The initial set of data can also be called from ORM to typically
populate the metadata tables. The initial data has fixed values as
their primary key and thus is easier to understand.

Copywright © [2024] Debmalya Pramanik
********************************************************************/

INSERT INTO meta.user_role (role_id, role_name, role_desc) VALUES
  (1, 'ROOT', 'Root/Super Administrator User'),
  (2, 'SUDO', 'A User with Elevated Privileges'),
  (3, 'USER', 'Normal User with Viewing Rights'),
  (4, 'INT+', 'Internal Normal User without Viewing Rights'),
  (5, 'EXT+', 'External User Typically having a Transactional Relationships');

INSERT INTO meta.user_subrole (subrole_id, role_id, subrole_name, subrole_desc) VALUES
  (1, 5, 'FAMILY', 'The user is part of the family, and his account may be tracked.'),
  (2, 5, 'RELATIVE', 'The user is part of the extended family and typically does not have a tracked account.'),
  (3, 5, 'FRIENDS', 'A friend of the user, who typically has a transactional relationship.'),
  (4, 5, 'ORGANIZATION', 'An organization which has a transactional relationship, example companies where the user has worked.');

INSERT INTO meta.account_type_detail (account_type_id, account_type_name, account_type_desc) VALUES
  ('DBT', 'Debit Account', 'Use this to store transactions from savings/current account.'),
  ('CDT', 'Credit Account', 'Use this to store transactions related to loans, credit cards, etc.'),
  ('WLT', 'Wallet Account', 'A type of account for storing gift cards, points, cashbacks, rewards etc. informations.'),
  ('DMT', 'DEMAT Account', 'A typical table for holding information related to share market, populate equity, F&O transactions.'),
  ('RET', 'Retirement Account', 'An account dedicated for savings for retirements, like PPF, VPF, NPS, etc.'),
  ('INS', 'Insurance Account', 'Use this to track investments/redemptions into insurance.'),
  ('MFA', 'Mutual Fund Account', 'A typical account for management of mutual funds and SIP/STP informations.'),
  ('TDA', 'Term Deposit Account', 'Term deposit accounts like FD/RD/etc. can be tracked here.');

INSERT INTO meta.account_subtype_detail (account_subtype_id, account_type_id, account_subtype_name, account_subtype_desc) VALUES
  ('FDS', 'TDA', 'Fixed Deposit Account', NULL),
  ('RDS', 'TDA', 'Recurring Deposit Account', NULL),
  ('SVN', 'DBT', 'Saving Account', NULL),
  ('SAL', 'DBT', 'Salary Account', NULL),
  ('CUR', 'DBT', 'Current Account', NULL),
  ('PPF', 'RET', 'Personal Providend Funds Account', NULL),
  ('VPF', 'RET', 'Voluntary Providend Funds Account', NULL),
  ('NPS', 'RET', 'National Pension Schemes Account', NULL),
  ('LND', 'CDT', 'Personal Lending Account', 'Amount lended to a person based on terms and conditions.'),
  ('BRW', 'CDT', 'Personal Borrowed Account', 'Amount borrwed from a person based on terms and conditions.');

INSERT INTO meta.transaction_type (type_id, trx_type_detail) VALUES
  ('D', 'Deposit into the Account'),
  ('W', 'Withdraw from the Account');

INSERT INTO meta.transaction_method (method_name, method_desc) VALUES
  ('NEFT', 'National Electronic Funds Transfer'),
  ('IMPS', 'Immediate Payment Service'),
  ('RTGS', 'Real Time Gross Settlement'),
  ('UPI', 'United Payment Interface'),
  ('MANDATE', 'Automatic Standing Instructions');
