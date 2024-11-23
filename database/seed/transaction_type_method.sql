/********************************************************************
Code Description

Copywright © [2024] Debmalya Pramanik
********************************************************************/

INSERT INTO meta.transaction_type (type_id, trx_type_detail) VALUES
  ('D', 'Deposit into the Account'),
  ('W', 'Withdraw from the Account');

INSERT INTO meta.transaction_method (method_name, method_desc) VALUES
  ('NEFT', 'National Electronic Funds Transfer'),
  ('IMPS', 'Immediate Payment Service'),
  ('RTGS', 'Real Time Gross Settlement'),
  ('UPI', 'United Payment Interface'),
  ('MANDATE', 'Automatic Standing Instructions'),
  ('CASH', 'Cash Withdrawl/Deposit'),
	('CREDIT', 'Transactions via a Credit Card');
