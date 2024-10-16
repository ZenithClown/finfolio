/********************************************************************
Code Description

Copywright © [2024] Debmalya Pramanik
********************************************************************/

INSERT INTO meta.expense_category (expense_category_name, expense_category_desc) VALUES
  ('HOUSING', 'House maintenance, rent, mortage, loan, etc.'),
  ('FOODING', 'Amount spend on monthly food, grocery, including outside food.'),
  ('TRANSPORTATION', 'Amount spent on fuel, car maintenance, rental veichles, etc.'),
  ('UTILITY', 'Essential utility services like telephone bills, electricity bill, etc.'),
  ('INSURANCE', 'Health/life/automobile insurance, etc.'),
  ('MEDICAL', 'Medical expenditure like medicines, special care, hospitalization, etc.'),
  ('PERSONAL CARE', 'Personal care like gym membership, clothes, home decor, etc.'),
  ('ENTERTAINMENT', 'Entertainments like subscriptions, movies, etc.');

INSERT INTO meta.expense_subcategory (expense_subcategory_name, primary_expense_category, expense_subcategory_desc) VALUES
  ('RENT', 'HOUSING', 'Money spent on rent.'),
  ('HOME LOAN', 'HOUSING', 'Money spent on home loan.'),
  ('HOME MAINTENANCE', 'HOUSING', 'Money spent on home maintenance, like repair, renovations, etc.'),
  ('GROCERY', 'FOODING', 'Grocery spends.'),
  ('FOOD ORDERING', 'FOODING', 'Spent on food ordering platforms like Zomato, Swiggy, etc.'),
  ('DINING OUT', 'FOODING', 'Spent occured while dining out in restaurants, etc.'),
  ('WINE & HARD DRINKS', 'FOODING', 'A reserved category to track non-essential food habits like hard drinks.'),
  ('PUBLIC TRANSIT (BUS & TRAIN)', 'TRANSPORTATION', 'Cost while traveling in public transport like bus, train, auto, etc.'),
  ('PUBLIC TRANSIT (FLIGHT)', 'TRANSPORTATION', 'Flight cost are often higher than other modes of transport, hence a different category.'),
  ('RENTAL CABS', 'TRANSPORTATION', 'Rental cab services like Ola/Uber/etc.'),
  ('CAR FUEL', 'TRANSPORTATION', 'Car fuel expenses are part of transportation expenses.'),
  ('CAR MAINTENANCE', 'TRANSPORTATION', 'Car maintenance are routine and part of transportation expenses.'),
  ('TELECOM BILL', 'UTILITY', 'Telecommunication bills like mobile recharge.'),
  ('INTERNET BILL', 'UTILITY', 'Internet services recharges.'),
  ('ELECTRICITY BILL', 'UTILITY', 'Home electricity bill.'),
  ('GAS SERVICE', 'UTILITY', 'Piped or metered gas/cylinder bills.'),
  ('HEALTH INSURANCE', 'INSURANCE', 'Health insurance premium.'),
  ('LIFE INSURANCE', 'INSURANCE', 'Life insurance premium.'),
  ('AUTOMOIBILE INSURANCE', 'INSURANCE', 'Automobile insurance premium'),
  ('MEDICINES', 'MEDICAL', 'Cost for buying medicines.'),
  ('HOSPITALIZATION', 'MEDICAL', 'Cost for hospitalizations.'),
  ('GYM MEMBERSHIP', 'PERSONAL CARE', 'Gym membership charges.'),
  ('APARRELS', 'PERSONAL CARE', 'Apparels cost - include both online/shop under this category.'),
  ('HOME DECOR', 'PERSONAL CARE', 'Home decoration and essential items.'),
  ('ONLINE SHOPPING (GADGETS)', 'PERSONAL CARE', 'Electronics gadgets which were bought online.'),
  ('ONLINE SHOPPING (OTHERS)', 'PERSONAL CARE', 'All other online shopping items like gifts, etc.'),
  ('SHOPPING (GADGETS)', 'PERSONAL CARE', 'Electronics gadgets which were bought from retail stores.'),
  ('SHOPPING (OTHERS)', 'PERSONAL CARE', 'Other retail shopping.'),
  ('OTT SUBSCRIPTION', 'ENTERTAINMENT', 'OTT subscription charges like Netflix/Prime/etc.'),
  ('MOVIES', 'ENTERTAINMENT', 'Movie outing expenses.'),
  ('VIDEO GAMES', 'ENTERTAINMENT', 'Spends on video games and other in-app game purchases.'),
  ('EVENT TICKET', 'ENTERTAINMENT', 'Events like sports, concert tickets, etc.'),
  ('HOBBIES', 'ENTERTAINMENT', 'Hobbies like books, coins, etc.');
