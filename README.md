 Retail Banking Transaction Analysis (MySQL)

A SQL project that builds a relational database for a retail bank and analyses
customers, accounts, transactions, loans and cards to find business insights.

## Business Problem
The bank stores its data across seven linked tables but cannot easily see who
its customers are, how products are used, and where risk is concentrated.
This project uses SQL to answer those questions.

## Dataset
- 7 tables, 9,140 records: customers (500), accounts (700), branches (40),
  loans (300), loan_payments (2,000), cards (600), transactions (5,000)
- Reference date: 22 Feb 2025 (latest transaction date)

## Database Design
- Primary keys on every table; foreign keys link accounts, loans, cards,
  transactions and payments to their parent tables
- All relationships are one-to-many
- Constraints: NOT NULL, DEFAULT, CHECK
- Data validation: row counts matched and no orphan rows
