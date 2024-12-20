/********************************************************************
Account Type and Sub-Type Details for FINFOLIO

Copywright © [2024] Debmalya Pramanik
********************************************************************/

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
