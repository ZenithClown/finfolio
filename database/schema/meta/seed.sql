/********************************************************************
Initial Seed Data for FINFOLIO Project - META Tables

The seed data are captured and is inserted during the database
initialization phase. All the meta data with typical seed values are
defined here, and in order the tables are defined.

Copywright © [2024] Debmalya Pramanik (ZenithClown)
********************************************************************/

INSERT INTO meta.account_type_master
  (account_type_key, account_type_id, account_type_name, account_type_desc)
VALUES
  ('CDT/BRW', 'CDT', 'Credit Account', 'Use this to store transactions related to loans, credit cards, etc.', 'BRW', 'Personal Borrowed Account', 'Amount borrwed from a person based on terms and conditions.'),
  ('CDT/CCD', 'CDT', 'Credit Account', 'Use this to store transactions related to loans, credit cards, etc.', 'CCD', 'Credit Card Account', NULL),
  ('CDT/LND', 'CDT', 'Credit Account', 'Use this to store transactions related to loans, credit cards, etc.', 'LND', 'Personal Lending Account', 'Amount lended to a person based on terms and conditions.'),
  ('DBT/CUR', 'DBT', 'Debit Account', 'Use this to store transactions from savings/current account.', 'CUR', 'Current Account', NULL),
  ('DBT/SAL', 'DBT', 'Debit Account', 'Use this to store transactions from savings/current account.', 'SAL', 'Salary Account', NULL),
  ('DBT/SVN', 'DBT', 'Debit Account', 'Use this to store transactions from savings/current account.', 'SVN', 'Saving Account', NULL),
  ('DMT', 'DMT', 'DEMAT Account', 'A typical table for holding information related to share market, populate equity, F&O transactions.', NULL, NULL, NULL),
  ('INS', 'INS', 'Insurance Account', 'Use this to track investments/redemptions into insurance.', NULL, NULL, NULL),
  ('MFA', 'MFA', 'Mutual Fund Account', 'A typical account for management of mutual funds and SIP/STP informations.', NULL, NULL, NULL),
  ('RET/NPS', 'RET', 'Retirement Account', 'An account dedicated for savings for retirements, like PPF, VPF, NPS, etc.', 'NPS', 'National Pension Schemes Account', NULL),
  ('RET/PPF', 'RET', 'Retirement Account', 'An account dedicated for savings for retirements, like PPF, VPF, NPS, etc.', 'PPF', 'Personal Providend Funds Account', NULL),
  ('RET/VPF', 'RET', 'Retirement Account', 'An account dedicated for savings for retirements, like PPF, VPF, NPS, etc.', 'VPF', 'Voluntary Providend Funds Account', NULL),
  ('TDA/FDS', 'TDA', 'Term Deposit Account', 'Term deposit accounts like FD/RD/etc. can be tracked here.', 'FDS', 'Fixed Deposit Account', NULL),
  ('TDA/RDS', 'TDA', 'Term Deposit Account', 'Term deposit accounts like FD/RD/etc. can be tracked here.', 'RDS', 'Recurring Deposit Account', NULL),
  ('WLT', 'WLT', 'Wallet Account', 'A type of account for storing gift cards, points, cashbacks, rewards etc. informations.', NULL, NULL, NULL);


INSERT INTO meta.expense_category_master
  (expense_category_key, expense_category_name, expense_category_desc, expense_subcategory_name, expense_subcategory_desc)
VALUES
  ('HOUSING/SECURITY DEPOSIT', 'HOUSING', 'House maintenance, rent, mortage, loan, etc.', 'SECURITY DEPOSIT', 'Money spent on security deposit, typically against home loan, rental period, etc..'),
  ('HOUSING/HOME MAINTENANCE', 'HOUSING', 'House maintenance, rent, mortage, loan, etc.', 'HOME MAINTENANCE', 'Money spent on home maintenance, like repair, renovations, etc.'),
  ('HOUSING/HOME LOAN', 'HOUSING', 'House maintenance, rent, mortage, loan, etc.', 'HOME LOAN', 'Money spent on home loan.'),
  ('HOUSING/RENT', 'HOUSING', 'House maintenance, rent, mortage, loan, etc.', 'RENT', 'Money spent on rent.'),
  ('FOODING/WINE & HARD DRINKS', 'FOODING', 'Amount spend on monthly food, grocery, including outside food.', 'WINE & HARD DRINKS', 'A reserved category to track non-essential food habits like hard drinks.'),
  ('FOODING/DINING OUT', 'FOODING', 'Amount spend on monthly food, grocery, including outside food.', 'DINING OUT', 'Spent occured while dining out in restaurants, etc.'),
  ('FOODING/FOOD ORDERING', 'FOODING', 'Amount spend on monthly food, grocery, including outside food.', 'FOOD ORDERING', 'Spent on food ordering platforms like Zomato, Swiggy, etc.'),
  ('FOODING/GROCERY', 'FOODING', 'Amount spend on monthly food, grocery, including outside food.', 'GROCERY', 'Grocery spends.'),
  ('TRANSPORTATION/CAR MAINTENANCE', 'TRANSPORTATION', 'Amount spent on fuel, car maintenance, rental veichles, etc.', 'CAR MAINTENANCE', 'Car maintenance are routine and part of transportation expenses.'),
  ('TRANSPORTATION/CAR FUEL', 'TRANSPORTATION', 'Amount spent on fuel, car maintenance, rental veichles, etc.', 'CAR FUEL', 'Car fuel expenses are part of transportation expenses.'),
  ('TRANSPORTATION/RENTAL CABS', 'TRANSPORTATION', 'Amount spent on fuel, car maintenance, rental veichles, etc.', 'RENTAL CABS', 'Rental cab services like Ola/Uber/etc.'),
  ('TRANSPORTATION/PUBLIC TRANSIT (FLIGHT)', 'TRANSPORTATION', 'Amount spent on fuel, car maintenance, rental veichles, etc.', 'PUBLIC TRANSIT (FLIGHT)', 'Flight cost are often higher than other modes of transport, hence a different category.'),
  ('TRANSPORTATION/PUBLIC TRANSIT (BUS & TRAIN)', 'TRANSPORTATION', 'Amount spent on fuel, car maintenance, rental veichles, etc.', 'PUBLIC TRANSIT (BUS & TRAIN)', 'Cost while traveling in public transport like bus, train, auto, etc.'),
  ('UTILITY/GAS SERVICE', 'UTILITY', 'Essential utility services like telephone bills, electricity bill, etc.', 'GAS SERVICE', 'Piped or metered gas/cylinder bills.'),
  ('UTILITY/ELECTRICITY BILL', 'UTILITY', 'Essential utility services like telephone bills, electricity bill, etc.', 'ELECTRICITY BILL', 'Home electricity bill.'),
  ('UTILITY/INTERNET BILL', 'UTILITY', 'Essential utility services like telephone bills, electricity bill, etc.', 'INTERNET BILL', 'Internet services recharges.'),
  ('UTILITY/TELECOM BILL', 'UTILITY', 'Essential utility services like telephone bills, electricity bill, etc.', 'TELECOM BILL', 'Telecommunication bills like mobile recharge.'),
  ('INSURANCE/AUTOMOIBILE INSURANCE', 'INSURANCE', 'Health/life/automobile insurance, etc.', 'AUTOMOIBILE INSURANCE', 'Automobile insurance premium'),
  ('INSURANCE/LIFE INSURANCE', 'INSURANCE', 'Health/life/automobile insurance, etc.', 'LIFE INSURANCE', 'Life insurance premium.'),
  ('INSURANCE/HEALTH INSURANCE', 'INSURANCE', 'Health/life/automobile insurance, etc.', 'HEALTH INSURANCE', 'Health insurance premium.'),
  ('MEDICAL/HOSPITALIZATION', 'MEDICAL', 'Medical expenditure like medicines, special care, hospitalization, etc.', 'HOSPITALIZATION', 'Cost for hospitalizations.'),
  ('MEDICAL/MEDICINES', 'MEDICAL', 'Medical expenditure like medicines, special care, hospitalization, etc.', 'MEDICINES', 'Cost for buying medicines.'),
  ('PERSONAL CARE/SHOPPING (OTHERS)', 'PERSONAL CARE', 'Personal care like gym membership, clothes, home decor, etc.', 'SHOPPING (OTHERS)', 'Other retail shopping.'),
  ('PERSONAL CARE/SHOPPING (GADGETS)', 'PERSONAL CARE', 'Personal care like gym membership, clothes, home decor, etc.', 'SHOPPING (GADGETS)', 'Electronics gadgets which were bought from retail stores.'),
  ('PERSONAL CARE/ONLINE SHOPPING (OTHERS)', 'PERSONAL CARE', 'Personal care like gym membership, clothes, home decor, etc.', 'ONLINE SHOPPING (OTHERS)', 'All other online shopping items like gifts, etc.'),
  ('PERSONAL CARE/ONLINE SHOPPING (GADGETS)', 'PERSONAL CARE', 'Personal care like gym membership, clothes, home decor, etc.', 'ONLINE SHOPPING (GADGETS)', 'Electronics gadgets which were bought online.'),
  ('PERSONAL CARE/HOME DECOR', 'PERSONAL CARE', 'Personal care like gym membership, clothes, home decor, etc.', 'HOME DECOR', 'Home decoration and essential items.'),
  ('PERSONAL CARE/APARRELS', 'PERSONAL CARE', 'Personal care like gym membership, clothes, home decor, etc.', 'APARRELS', 'Apparels cost - include both online/shop under this category.'),
  ('PERSONAL CARE/GYM MEMBERSHIP', 'PERSONAL CARE', 'Personal care like gym membership, clothes, home decor, etc.', 'GYM MEMBERSHIP', 'Gym membership charges.'),
  ('ENTERTAINMENT/HOBBIES', 'ENTERTAINMENT', 'Entertainments like subscriptions, movies, etc.', 'HOBBIES', 'Hobbies like books, coins, etc.'),
  ('ENTERTAINMENT/EVENT TICKET', 'ENTERTAINMENT', 'Entertainments like subscriptions, movies, etc.', 'EVENT TICKET', 'Events like sports, concert tickets, etc.'),
  ('ENTERTAINMENT/VIDEO GAMES', 'ENTERTAINMENT', 'Entertainments like subscriptions, movies, etc.', 'VIDEO GAMES', 'Spends on video games and other in-app game purchases.'),
  ('ENTERTAINMENT/MOVIES', 'ENTERTAINMENT', 'Entertainments like subscriptions, movies, etc.', 'MOVIES', 'Movie outing expenses.'),
  ('ENTERTAINMENT/OTT SUBSCRIPTION', 'ENTERTAINMENT', 'Entertainments like subscriptions, movies, etc.', 'OTT SUBSCRIPTION', 'OTT subscription charges like Netflix/Prime/etc.'),;


INSERT INTO meta.income_category (income_category_name, income_category_desc) VALUES
  ('SALARY', 'Regular compensation from employer.'),
  ('BUSINESS', 'Income from self-employment or business'),
  ('INVENTMENT', 'Income from investments like stocks, bonds, etc.'),
  ('RENTAL INCOME', 'Income from rental property.');


INSERT INTO meta.income_subcategory (income_subcategory_name, primary_income_category, income_subcategory_desc) VALUES
  ('CONSULTING', 'BUSINESS', 'Income from self-consulting, moonlighting, part-time jobs, etc.'),
  ('INTEREST', 'INVENTMENT', 'Interest income from savings, fixed deposits, etc.'),
  ('DIVIDEND', 'INVENTMENT', 'Dividend income from stocks, bonds, etc.');
