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

## Analysis Objectives
1. Customer profile and segmentation
2. Account usage and branch activity
3. Transaction patterns
4. Loan performance and repayment behaviour
5. Card usage and product engagement

## SQL Concepts Used
INNER / LEFT joins, GROUP BY, SUM / COUNT / AVG / MIN / MAX, HAVING,
subqueries, CASE, derived tables, COUNT(DISTINCT)

## Key Insights
- 56.3% of loans are Defaulted or In Arrears, holding 73% of the outstanding balance
- Only 33.8% of transactions are Completed; 32.6% fail and 33.7% are pending
- 94% of cards are inactive
- Only 28.6% of customers are fully KYC-verified
- Transaction growth slowed from +30% (2023) to +10% (2024)

## How to Run
1. Run the schema section of `sql/updated_sql_project_Q_s_fixed.sql` in MySQL 8
2. Import the CSV files from `data/` in this order: branches, customers,
   accounts, loans, loan_payments, cards, transactions
3. Run the analysis queries (sections 4.1 to 4.5)

## Repository Structure
- `sql/` : database creation and analysis queries
- `data/` : CSV files
- `images/` : ER diagram
- `docs/` : project report and presentation


## Tools
MySQL 8, MySQL Workbench

