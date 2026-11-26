-- ============================================================
-- Retail Banking Transaction Analysis  |  MySQL 8.0
-- Sprint 2: Database design from the ER diagram
-- ============================================================
CREATE DATABASE retail_banking;
USE retail_banking;

-- 1. Parent tables first (no foreign keys)
CREATE TABLE branches (
    branch_id       VARCHAR(10)  NOT NULL,
    branch_name     VARCHAR(100) NOT NULL,
    city            VARCHAR(50)  NOT NULL,
    state           VARCHAR(30)  NOT NULL,
    region          VARCHAR(30)  NOT NULL,
    opening_date    DATE,
    employee_count  INT          NOT NULL DEFAULT 0,
    PRIMARY KEY (branch_id),
    CONSTRAINT chk_branch_emp CHECK (employee_count >= 0)
);

select * from branches;

CREATE TABLE customers (
    customer_id    VARCHAR(20)   NOT NULL,
    first_name     VARCHAR(50)   NOT NULL,
    last_name      VARCHAR(50)   NOT NULL,
    date_of_birth  DATE          NOT NULL,
    gender         VARCHAR(20),
    city           VARCHAR(50),
    state          VARCHAR(30),
    customer_since DATE          NOT NULL,
    kyc_status     VARCHAR(20)   NOT NULL DEFAULT 'Pending',
    segment        VARCHAR(30)   NOT NULL,
    annual_income  DECIMAL(12,2),
    credit_score   INT,
    is_active      VARCHAR(3)    NOT NULL DEFAULT 'Yes',
    PRIMARY KEY (customer_id),
    CONSTRAINT chk_cust_score  CHECK (credit_score BETWEEN 300 AND 850),
    CONSTRAINT chk_cust_active CHECK (is_active IN ('Yes','No'))
);

-- 2. Child tables
CREATE TABLE accounts (
    account_id       VARCHAR(20)   NOT NULL,
    customer_id      VARCHAR(20)   NOT NULL,
    branch_id        VARCHAR(10)   NOT NULL,
    account_type     VARCHAR(30)   NOT NULL,
    open_date        DATE          NOT NULL,
    close_date       DATE          NULL,
    current_balance  DECIMAL(15,2) NOT NULL DEFAULT 0.00,
    interest_rate    DECIMAL(5,2)  NOT NULL DEFAULT 0.00,
    overdraft_limit  DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    status           VARCHAR(20)   NOT NULL DEFAULT 'Active',
    PRIMARY KEY (account_id),
    CONSTRAINT fk_acc_customer FOREIGN KEY (customer_id) REFERENCES customers (customer_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_acc_branch   FOREIGN KEY (branch_id)   REFERENCES branches (branch_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT chk_acc_status  CHECK (status IN ('Active','Closed'))
);
select count(*) from accounts;


SHOW GLOBAL VARIABLES LIKE 'local_infile';



select * from accounts;

CREATE TABLE loans (
    loan_id             VARCHAR(20)   NOT NULL,
    customer_id         VARCHAR(20)   NOT NULL,
    branch_id           VARCHAR(10)   NOT NULL,
    loan_type           VARCHAR(30)   NOT NULL,
    principal_amount    DECIMAL(15,2) NOT NULL,
    interest_rate       DECIMAL(5,2)  NOT NULL,
    tenure_months       INT           NOT NULL,
    disbursement_date   DATE          NOT NULL,
    maturity_date       DATE          NOT NULL,
    emi_amount          DECIMAL(12,2) NOT NULL,
    outstanding_balance DECIMAL(15,2) NOT NULL DEFAULT 0.00,
    loan_status         VARCHAR(30)   NOT NULL DEFAULT 'Active',
    purpose             VARCHAR(50),
    PRIMARY KEY (loan_id),
    CONSTRAINT fk_loan_customer FOREIGN KEY (customer_id) REFERENCES customers (customer_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_loan_branch   FOREIGN KEY (branch_id)   REFERENCES branches (branch_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT chk_loan_amount  CHECK (principal_amount > 0)
);

CREATE TABLE loan_payments (
    payment_id        VARCHAR(20)   NOT NULL,
    loan_id           VARCHAR(20)   NOT NULL,
    payment_date      DATE          NOT NULL,
    scheduled_amount  DECIMAL(12,2) NOT NULL,
    paid_amount       DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    principal_paid    DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    interest_paid     DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    penalty           DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    days_late         INT           NOT NULL DEFAULT 0,
    payment_method    VARCHAR(30),
    status            VARCHAR(20)   NOT NULL DEFAULT 'Pending',
    PRIMARY KEY (payment_id),
    CONSTRAINT fk_pay_loan FOREIGN KEY (loan_id) REFERENCES loans (loan_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT chk_pay_late CHECK (days_late >= 0)
);

CREATE TABLE cards (
    card_id              VARCHAR(20)   NOT NULL,
    account_id           VARCHAR(20)   NOT NULL,
    card_type            VARCHAR(20)   NOT NULL,
    issue_date           DATE          NOT NULL,
    expiry_date          DATE          NOT NULL,
    credit_limit         DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    outstanding_balance  DECIMAL(12,2) NOT NULL DEFAULT 0.00,
    reward_points        INT           NOT NULL DEFAULT 0,
    is_active            VARCHAR(3)    NOT NULL DEFAULT 'Yes',
    network              VARCHAR(20),
    PRIMARY KEY (card_id),
    CONSTRAINT fk_card_account FOREIGN KEY (account_id) REFERENCES accounts (account_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT chk_card_active CHECK (is_active IN ('Yes','No'))
);

CREATE TABLE transactions (
    transaction_id    VARCHAR(20)   NOT NULL,
    account_id        VARCHAR(20)   NOT NULL,
    transaction_date  DATE          NOT NULL,
    transaction_time  TIME,
    transaction_type  VARCHAR(30)   NOT NULL,
    amount            DECIMAL(15,2) NOT NULL,
    channel           VARCHAR(30),
    description       VARCHAR(50),
    balance_after     DECIMAL(15,2),
    status            VARCHAR(20)   NOT NULL DEFAULT 'Completed',
    PRIMARY KEY (transaction_id),
    CONSTRAINT fk_txn_account FOREIGN KEY (account_id) REFERENCES accounts (account_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT chk_txn_amount CHECK (amount > 0)
);



select * from branches;
SELECT COUNT(*) FROM branches;
select * from customers;
SELECT COUNT(*) FROM customers;
select * from loans;
select * from accounts;
SELECT COUNT(*) FROM accounts;
select * from cards;
select * from loan_payments;
select * from  transactions;







SHOW CREATE TABLE accounts;
SHOW WARNINGS;
SELECT @@sql_mode;


-- ============================================================
-- Sprint 2.2: Data import (CSV files exported from sql_project.xlsx)
-- Load in dependency order: branches, customers, accounts, loans,
-- loan_payments, cards, transactions.  Example (repeat per table):
-- ============================================================
-- SET GLOBAL local_infile = 1;
-- LOAD DATA LOCAL INFILE 'branches.csv' INTO TABLE branches
--   FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
--   LINES TERMINATED BY '\n' IGNORE 1 LINES;
--
-- accounts.csv has empty close_date cells; convert them to NULL:
-- LOAD DATA LOCAL INFILE 'accounts.csv' INTO TABLE accounts
--   FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
--   LINES TERMINATED BY '\n' IGNORE 1 LINES
--   (account_id, customer_id, branch_id, account_type, open_date, @close_date,
--    current_balance, interest_rate, overdraft_limit, status)
--   SET close_date = NULLIF(@close_date, '');

-- ============================================================
-- Verification queries
-- ============================================================
SELECT 'customers' AS table_name, COUNT(*) AS row_count FROM customers
UNION ALL SELECT 'accounts', COUNT(*) FROM accounts
UNION ALL SELECT 'branches', COUNT(*) FROM branches
UNION ALL SELECT 'loans', COUNT(*) FROM loans
UNION ALL SELECT 'loan_payments', COUNT(*) FROM loan_payments
UNION ALL SELECT 'cards', COUNT(*) FROM cards
UNION ALL SELECT 'transactions', COUNT(*) FROM transactions;

-- Orphan-row checks (every result should be 0)
SELECT 'accounts without customer' AS check_name, COUNT(*) AS orphans
FROM accounts a LEFT JOIN customers c ON c.customer_id = a.customer_id WHERE c.customer_id IS NULL
UNION ALL SELECT 'accounts without branch', COUNT(*)
FROM accounts a LEFT JOIN branches b ON b.branch_id = a.branch_id WHERE b.branch_id IS NULL
UNION ALL SELECT 'loans without customer', COUNT(*)
FROM loans l LEFT JOIN customers c ON c.customer_id = l.customer_id WHERE c.customer_id IS NULL
UNION ALL SELECT 'loan_payments without loan', COUNT(*)
FROM loan_payments p LEFT JOIN loans l ON l.loan_id = p.loan_id WHERE l.loan_id IS NULL
UNION ALL SELECT 'cards without account', COUNT(*)
FROM cards c LEFT JOIN accounts a ON a.account_id = c.account_id WHERE a.account_id IS NULL
UNION ALL SELECT 'transactions without account', COUNT(*)
FROM transactions t LEFT JOIN accounts a ON a.account_id = t.account_id WHERE a.account_id IS NULL;


-- ============================================================
-- SPRINT 3: BASIC ANALYSIS
-- ============================================================

-- 3.1 Total number of customers
SELECT COUNT(*) AS total_customers FROM customers;

-- 3.2 Total number of accounts
SELECT COUNT(*) AS total_accounts FROM accounts;

-- 3.3 Different account types
SELECT account_type, COUNT(*) AS accounts
FROM accounts
GROUP BY account_type
ORDER BY accounts DESC;

-- 3.4 Currently active customers
SELECT COUNT(*) AS active_customers
FROM customers
WHERE is_active = 'Yes';

-- 3.5 Different transaction types
SELECT transaction_type, COUNT(*) AS transactions
FROM transactions
GROUP BY transaction_type
ORDER BY transactions DESC;

-- 3.6 Total amount of completed transactions
SELECT COUNT(*) AS completed_txns, ROUND(SUM(amount),2) AS total_completed_amount
FROM transactions
WHERE status = 'Completed';

-- 3.7 Different loan types
SELECT loan_type, COUNT(*) AS loans
FROM loans
GROUP BY loan_type
ORDER BY loans DESC;

-- 3.8 Total number of loans
SELECT COUNT(*) AS total_loans FROM loans;

-- 3.9 Different card types
SELECT card_type, COUNT(*) AS cards
FROM cards
GROUP BY card_type;

-- 3.10 Total outstanding loan balance
SELECT ROUND(SUM(outstanding_balance),2) AS total_outstanding_balance
FROM loans;


-- ============================================================
-- SPRINT 4.1: CUSTOMER PROFILE AND SEGMENTATION
-- ============================================================

-- 4.1.1 Segment profile: size, income, credit score, activity and tenure
SELECT segment,
       COUNT(*) AS customers,
       ROUND(AVG(annual_income),0) AS avg_income,
       ROUND(AVG(credit_score),0) AS avg_credit_score,
       ROUND(SUM(is_active = 'Yes') * 100.0 / COUNT(*),1) AS pct_active,
       ROUND(AVG(DATEDIFF((SELECT MAX(transaction_date) FROM transactions), customer_since)) / 365.25,1) AS avg_tenure_yrs
FROM customers
GROUP BY segment
ORDER BY customers DESC;

-- 4.1.2 Demographics: age band by gender
SELECT CASE WHEN age < 30 THEN '1. Under 30'
            WHEN age < 40 THEN '2. 30-39'
            WHEN age < 50 THEN '3. 40-49'
            WHEN age < 60 THEN '4. 50-59'
            ELSE '5. 60+' END AS age_band,
       COUNT(*) AS customers,
       SUM(gender = 'Male') AS male,
       SUM(gender = 'Female') AS female,
       SUM(gender = 'Non-binary') AS non_binary,
       ROUND(AVG(annual_income),0) AS avg_income
FROM (SELECT *, DATEDIFF((SELECT MAX(transaction_date) FROM transactions), date_of_birth) / 365.25 AS age FROM customers) c
GROUP BY age_band
ORDER BY age_band;

-- 4.1.3 Top 10 states by customers
SELECT state, COUNT(*) AS customers,
       ROUND(AVG(annual_income),0) AS avg_income,
       ROUND(AVG(credit_score),0) AS avg_credit_score
FROM customers
GROUP BY state
ORDER BY customers DESC, state
LIMIT 10;

-- 4.1.4 Top 10 cities by customers
SELECT city, state, COUNT(*) AS customers,
       ROUND(AVG(annual_income),0) AS avg_income
FROM customers
GROUP BY city, state
ORDER BY customers DESC, city
LIMIT 10;

-- 4.1.5 Income band vs credit score
SELECT CASE WHEN annual_income < 75000 THEN '1. Under 75K'
            WHEN annual_income < 150000 THEN '2. 75K-150K'
            WHEN annual_income < 225000 THEN '3. 150K-225K'
            ELSE '4. 225K+' END AS income_band,
       COUNT(*) AS customers,
       ROUND(AVG(credit_score),0) AS avg_credit_score,
       MIN(credit_score) AS min_score, MAX(credit_score) AS max_score
FROM customers
GROUP BY income_band
ORDER BY income_band;

-- 4.1.6 Credit-score band distribution
SELECT CASE WHEN credit_score < 580 THEN '1. Poor (<580)'
            WHEN credit_score < 670 THEN '2. Fair (580-669)'
            WHEN credit_score < 740 THEN '3. Good (670-739)'
            WHEN credit_score < 800 THEN '4. Very Good (740-799)'
            ELSE '5. Exceptional (800+)' END AS score_band,
       COUNT(*) AS customers,
       ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM customers),1) AS pct_of_customers
FROM customers
GROUP BY score_band
ORDER BY score_band;

-- 4.1.7 KYC status vs customer activity
SELECT kyc_status, COUNT(*) AS customers,
       SUM(is_active = 'Yes') AS active,
       SUM(is_active = 'No') AS inactive,
       ROUND(SUM(is_active = 'Yes') * 100.0 / COUNT(*),1) AS pct_active
FROM customers
GROUP BY kyc_status
ORDER BY customers DESC;

-- 4.1.8 KYC verification rate by segment
SELECT segment, COUNT(*) AS customers,
       SUM(kyc_status = 'Verified') AS verified,
       SUM(kyc_status = 'Failed') AS failed,
       ROUND(SUM(kyc_status = 'Verified') * 100.0 / COUNT(*),1) AS pct_verified,
       ROUND(SUM(kyc_status = 'Failed') * 100.0 / COUNT(*),1) AS pct_failed
FROM customers
GROUP BY segment
ORDER BY pct_verified DESC;

-- 4.1.9 Tenure cohorts: customers by joining year and retention
SELECT YEAR(customer_since) AS joined_year,
       COUNT(*) AS customers,
       SUM(is_active = 'Yes') AS still_active,
       ROUND(SUM(is_active = 'Yes') * 100.0 / COUNT(*),1) AS pct_active
FROM customers
GROUP BY joined_year
ORDER BY joined_year;

-- 4.1.10 Risk flag: high income but weak credit score (>=150K income, score < 600)
SELECT segment, COUNT(*) AS customers
FROM customers
WHERE annual_income >= 150000 AND credit_score < 600
GROUP BY segment
ORDER BY customers DESC;


-- ============================================================
-- SPRINT 4.2: ACCOUNT USAGE AND BRANCH ACTIVITY
-- ============================================================

-- 4.2.1 Account type summary
SELECT account_type,
       COUNT(*) AS accounts,
       SUM(status = 'Active') AS active,
       ROUND(SUM(status = 'Closed') * 100.0 / COUNT(*),1) AS pct_closed,
       ROUND(SUM(current_balance),0) AS total_balance,
       ROUND(AVG(CASE WHEN status = 'Active' THEN current_balance END),0) AS avg_active_balance,
       ROUND(AVG(interest_rate),2) AS avg_interest_rate,
       ROUND(AVG(overdraft_limit),0) AS avg_overdraft_limit
FROM accounts
GROUP BY account_type
ORDER BY total_balance DESC;

-- 4.2.2 Interest-rate range by account type
SELECT account_type, MIN(interest_rate) AS min_rate,
       ROUND(AVG(interest_rate),2) AS avg_rate, MAX(interest_rate) AS max_rate
FROM accounts
GROUP BY account_type
ORDER BY avg_rate DESC;

-- 4.2.3 Active vs closed accounts
SELECT status, COUNT(*) AS accounts,
       ROUND(SUM(current_balance),0) AS total_balance,
       ROUND(AVG(interest_rate),2) AS avg_interest_rate,
       ROUND(AVG(CASE WHEN close_date IS NOT NULL THEN DATEDIFF(close_date, open_date) END) / 365.25,1) AS avg_life_yrs,
       SUM(close_date > (SELECT MAX(transaction_date) FROM transactions)) AS close_date_after_ref_date
FROM accounts
GROUP BY status;

-- 4.2.4 Number of accounts held per customer
SELECT accounts_held, COUNT(*) AS customers
FROM (SELECT customer_id, COUNT(*) AS accounts_held FROM accounts GROUP BY customer_id) t
GROUP BY accounts_held
ORDER BY accounts_held;

-- 4.2.5 Customers holding 4 or more accounts
SELECT a.customer_id, c.segment, COUNT(*) AS accounts,
       ROUND(SUM(a.current_balance),0) AS total_balance
FROM accounts a
JOIN customers c ON c.customer_id = a.customer_id
GROUP BY a.customer_id, c.segment
HAVING COUNT(*) >= 4
ORDER BY accounts DESC, total_balance DESC;

-- 4.2.6 Customers with no account
SELECT COUNT(*) AS customers_without_account,
       SUM(c.is_active = 'Yes') AS of_which_active
FROM customers c
LEFT JOIN accounts a ON a.customer_id = c.customer_id
WHERE a.account_id IS NULL;

-- 4.2.7 Top 10 branches by total balance
SELECT b.branch_id, b.branch_name, b.region,
       COUNT(a.account_id) AS accounts,
       SUM(a.status = 'Active') AS active_accounts,
       ROUND(SUM(a.current_balance),0) AS total_balance,
       b.employee_count
FROM branches b
JOIN accounts a ON a.branch_id = b.branch_id
GROUP BY b.branch_id, b.branch_name, b.region, b.employee_count
ORDER BY total_balance DESC
LIMIT 10;

-- 4.2.8 Region summary: accounts, balances and staffing
SELECT b.region, COUNT(DISTINCT b.branch_id) AS branches,
       COUNT(a.account_id) AS accounts,
       ROUND(SUM(a.current_balance),0) AS total_balance,
       ROUND(SUM(a.current_balance) / COUNT(a.account_id),0) AS balance_per_account
FROM branches b
JOIN accounts a ON a.branch_id = b.branch_id
GROUP BY b.region
ORDER BY total_balance DESC;

-- 4.2.9 Bottom 5 branches by account count
SELECT b.branch_id, b.branch_name, COUNT(a.account_id) AS accounts,
       ROUND(COALESCE(SUM(a.current_balance),0),0) AS total_balance
FROM branches b
LEFT JOIN accounts a ON a.branch_id = b.branch_id
GROUP BY b.branch_id, b.branch_name
ORDER BY accounts ASC, b.branch_id
LIMIT 5;

-- 4.2.10 Accounts opened and closed per year
SELECT y.yr, COALESCE(o.opened,0) AS opened, COALESCE(c.closed,0) AS closed
FROM (SELECT YEAR(open_date) AS yr FROM accounts
      UNION SELECT YEAR(close_date) FROM accounts WHERE close_date IS NOT NULL) y
LEFT JOIN (SELECT YEAR(open_date) AS yr, COUNT(*) AS opened FROM accounts GROUP BY 1) o ON o.yr = y.yr
LEFT JOIN (SELECT YEAR(close_date) AS yr, COUNT(*) AS closed FROM accounts WHERE close_date IS NOT NULL GROUP BY 1) c ON c.yr = y.yr
ORDER BY y.yr;

-- 4.2.11 Transaction activity by account type
SELECT a.account_type, COUNT(DISTINCT a.account_id) AS accounts,
       COUNT(t.transaction_id) AS transactions,
       ROUND(COUNT(t.transaction_id) * 1.0 / COUNT(DISTINCT a.account_id),1) AS txns_per_account,
       ROUND(AVG(t.amount),0) AS avg_txn_amount
FROM accounts a
LEFT JOIN transactions t ON t.account_id = a.account_id
GROUP BY a.account_type
ORDER BY txns_per_account DESC;

-- 4.2.12 Accounts with no transactions
SELECT a.account_id, a.account_type, a.status, a.open_date, a.current_balance
FROM accounts a
LEFT JOIN transactions t ON t.account_id = a.account_id
WHERE t.transaction_id IS NULL;


-- ============================================================
-- SPRINT 4.3: TRANSACTION PATTERNS
-- ============================================================

-- 4.3.1 Transaction type summary
SELECT transaction_type, COUNT(*) AS transactions,
       ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM transactions),1) AS pct_of_txns,
       ROUND(SUM(amount),0) AS total_amount,
       ROUND(AVG(amount),0) AS avg_amount
FROM transactions
GROUP BY transaction_type
ORDER BY transactions DESC;

-- 4.3.2 Transaction status mix
SELECT status, COUNT(*) AS transactions,
       ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM transactions),1) AS pct_of_txns,
       ROUND(SUM(amount),0) AS total_amount
FROM transactions
GROUP BY status;

-- 4.3.3 Channel summary
SELECT channel, COUNT(*) AS transactions,
       ROUND(SUM(amount),0) AS total_amount,
       ROUND(AVG(amount),0) AS avg_amount,
       ROUND(SUM(status = 'Failed') * 100.0 / COUNT(*),1) AS pct_failed
FROM transactions
GROUP BY channel
ORDER BY transactions DESC;

-- 4.3.4 Transaction type by channel (counts)
SELECT transaction_type,
       SUM(channel = 'Online') AS online,
       SUM(channel = 'Branch') AS branch,
       SUM(channel = 'Mobile') AS mobile,
       SUM(channel = 'ATM') AS atm,
       SUM(channel = 'POS') AS pos,
       SUM(channel = 'Wire Transfer') AS wire
FROM transactions
GROUP BY transaction_type
ORDER BY transaction_type;

-- 4.3.5 Common transaction descriptions
SELECT description, COUNT(*) AS transactions,
       ROUND(SUM(amount),0) AS total_amount,
       ROUND(AVG(amount),0) AS avg_amount
FROM transactions
GROUP BY description
ORDER BY transactions DESC;

-- 4.3.6 Amount distribution (all transactions)
SELECT CASE WHEN amount < 1000 THEN '1. Under 1K'
            WHEN amount < 5000 THEN '2. 1K-5K'
            WHEN amount < 10000 THEN '3. 5K-10K'
            ELSE '4. 10K+' END AS amount_band,
       COUNT(*) AS transactions,
       ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM transactions),1) AS pct
FROM transactions
GROUP BY amount_band
ORDER BY amount_band;

-- 4.3.7 Yearly trend: volume and completed value
SELECT YEAR(transaction_date) AS yr, COUNT(*) AS transactions,
       SUM(status = 'Completed') AS completed,
       ROUND(SUM(CASE WHEN status = 'Completed' THEN amount END),0) AS completed_amount
FROM transactions
GROUP BY yr
ORDER BY yr;

-- 4.3.8 Time-of-day pattern
SELECT CASE WHEN HOUR(transaction_time) < 6 THEN '1. Night (00-05)'
            WHEN HOUR(transaction_time) < 12 THEN '2. Morning (06-11)'
            WHEN HOUR(transaction_time) < 18 THEN '3. Afternoon (12-17)'
            ELSE '4. Evening (18-23)' END AS time_of_day,
       COUNT(*) AS transactions,
       ROUND(AVG(amount),0) AS avg_amount
FROM transactions
GROUP BY time_of_day
ORDER BY time_of_day;

-- 4.3.9 Top 10 accounts by completed transaction value
SELECT t.account_id, a.account_type, a.status,
       COUNT(*) AS completed_txns, ROUND(SUM(t.amount),0) AS completed_value
FROM transactions t
JOIN accounts a ON a.account_id = t.account_id
WHERE t.status = 'Completed'
GROUP BY t.account_id, a.account_type, a.status
ORDER BY completed_value DESC
LIMIT 10;

-- 4.3.10 Activity by customer segment
SELECT c.segment, COUNT(t.transaction_id) AS transactions,
       COUNT(DISTINCT c.customer_id) AS customers_transacting,
       ROUND(COUNT(t.transaction_id) * 1.0 / COUNT(DISTINCT c.customer_id),1) AS txns_per_customer,
       ROUND(AVG(t.amount),0) AS avg_amount
FROM transactions t
JOIN accounts a ON a.account_id = t.account_id
JOIN customers c ON c.customer_id = a.customer_id
GROUP BY c.segment
ORDER BY txns_per_customer DESC;

-- 4.3.11 Fees and interest by account type (completed only)
SELECT a.account_type,
       ROUND(SUM(CASE WHEN t.transaction_type = 'Fee' THEN t.amount END),0) AS fees,
       ROUND(SUM(CASE WHEN t.transaction_type = 'Interest' THEN t.amount END),0) AS interest,
       ROUND(SUM(CASE WHEN t.transaction_type = 'Fee' THEN t.amount END) * 1.0 /
             SUM(CASE WHEN t.transaction_type = 'Interest' THEN t.amount END),2) AS fee_to_interest_ratio
FROM transactions t
JOIN accounts a ON a.account_id = t.account_id
WHERE t.status = 'Completed'
GROUP BY a.account_type
ORDER BY fees DESC;

-- 4.3.12 Balance impact: balance_after consistency
SELECT COUNT(DISTINCT account_id) AS accounts_with_txns,
       SUM(CASE WHEN n > 1 THEN 1 ELSE 0 END) AS accounts_with_changing_balance_after
FROM (SELECT account_id, COUNT(DISTINCT balance_after) AS n
      FROM transactions GROUP BY account_id) s;

-- 4.3.13 Balance impact: transactions larger than the balance left after them
SELECT transaction_type, COUNT(*) AS txns,
       SUM(amount > balance_after) AS amount_exceeds_balance_after,
       ROUND(SUM(amount > balance_after) * 100.0 / COUNT(*),1) AS pct
FROM transactions
WHERE status = 'Completed'
GROUP BY transaction_type
ORDER BY pct DESC;

-- 4.3.14 Balance impact: average balance_after by account type
SELECT a.account_type, ROUND(AVG(t.balance_after),0) AS avg_balance_after,
       ROUND(AVG(a.current_balance),0) AS avg_current_balance
FROM transactions t
JOIN accounts a ON a.account_id = t.account_id
GROUP BY a.account_type
ORDER BY avg_balance_after DESC;


-- ============================================================
-- SPRINT 4.4: LOAN PERFORMANCE AND REPAYMENT
-- ============================================================

-- 4.4.1 Loan type summary
SELECT loan_type, COUNT(*) AS loans,
       ROUND(SUM(principal_amount),0) AS total_principal,
       ROUND(SUM(outstanding_balance),0) AS total_outstanding,
       ROUND(SUM(outstanding_balance) * 100.0 / SUM(principal_amount),1) AS pct_outstanding,
       ROUND(AVG(interest_rate),2) AS avg_rate,
       ROUND(AVG(tenure_months),0) AS avg_tenure_months
FROM loans
GROUP BY loan_type
ORDER BY total_outstanding DESC;

-- 4.4.2 Loan status by loan type (counts and default rate)
SELECT loan_type, COUNT(*) AS loans,
       SUM(loan_status = 'Active') AS active,
       SUM(loan_status = 'In Arrears') AS in_arrears,
       SUM(loan_status = 'Defaulted') AS defaulted,
       SUM(loan_status = 'Closed') AS closed,
       ROUND(SUM(loan_status = 'Defaulted') * 100.0 / COUNT(*),1) AS pct_defaulted,
       ROUND(SUM(loan_status IN ('Defaulted','In Arrears')) * 100.0 / COUNT(*),1) AS pct_troubled
FROM loans
GROUP BY loan_type
ORDER BY pct_troubled DESC;

-- 4.4.3 Loan status summary
SELECT loan_status, COUNT(*) AS loans,
       ROUND(SUM(principal_amount),0) AS principal,
       ROUND(SUM(outstanding_balance),0) AS outstanding,
       ROUND(AVG(interest_rate),2) AS avg_rate
FROM loans
GROUP BY loan_status
ORDER BY outstanding DESC;

-- 4.4.4 Loan purpose summary
SELECT purpose, COUNT(*) AS loans,
       ROUND(AVG(principal_amount),0) AS avg_principal,
       ROUND(SUM(outstanding_balance),0) AS total_outstanding,
       ROUND(SUM(loan_status IN ('Defaulted','In Arrears')) * 100.0 / COUNT(*),1) AS pct_troubled
FROM loans
GROUP BY purpose
ORDER BY total_outstanding DESC;

-- 4.4.5 Loans past maturity that are not closed
SELECT loan_status, COUNT(*) AS loans,
       ROUND(SUM(outstanding_balance),0) AS outstanding
FROM loans
WHERE maturity_date < (SELECT MAX(transaction_date) FROM transactions) AND loan_status <> 'Closed'
GROUP BY loan_status;

-- 4.4.6 Loans maturing within 12 months of the reference date
SELECT loan_type, COUNT(*) AS loans, ROUND(SUM(outstanding_balance),0) AS outstanding
FROM loans
WHERE maturity_date BETWEEN (SELECT MAX(transaction_date) FROM transactions) AND DATE_ADD((SELECT MAX(transaction_date) FROM transactions), INTERVAL 12 MONTH)
  AND loan_status <> 'Closed'
GROUP BY loan_type
ORDER BY outstanding DESC;

-- 4.4.7 Repayment status of all scheduled payments
SELECT status, COUNT(*) AS payments,
       ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM loan_payments),1) AS pct,
       ROUND(SUM(scheduled_amount),0) AS scheduled,
       ROUND(SUM(paid_amount),0) AS paid,
       ROUND(SUM(penalty),0) AS penalties
FROM loan_payments
GROUP BY status
ORDER BY payments DESC;

-- 4.4.8 Late payments: severity of delay
SELECT CASE WHEN days_late <= 7 THEN '1-7 days'
            WHEN days_late <= 14 THEN '8-14 days'
            WHEN days_late <= 30 THEN '15-30 days'
            ELSE '31+ days' END AS delay_band,
       COUNT(*) AS late_payments,
       ROUND(AVG(penalty),0) AS avg_penalty,
       ROUND(SUM(penalty),0) AS total_penalty
FROM loan_payments
WHERE days_late > 0
GROUP BY delay_band
ORDER BY MIN(days_late);

-- 4.4.9 Repayment behaviour by loan type
SELECT l.loan_type, COUNT(*) AS payments,
       ROUND(SUM(p.status = 'Paid') * 100.0 / COUNT(*),1) AS pct_on_time,
       ROUND(SUM(p.status = 'Late') * 100.0 / COUNT(*),1) AS pct_late,
       ROUND(SUM(p.status = 'Missed') * 100.0 / COUNT(*),1) AS pct_missed,
       ROUND(AVG(CASE WHEN p.status = 'Late' THEN p.days_late END),1) AS avg_days_late,
       ROUND(SUM(p.penalty),0) AS total_penalty
FROM loan_payments p
JOIN loans l ON l.loan_id = p.loan_id
GROUP BY l.loan_type
ORDER BY pct_missed DESC;

-- 4.4.10 Payment method behaviour
SELECT payment_method, COUNT(*) AS payments,
       ROUND(SUM(status = 'Paid') * 100.0 / COUNT(*),1) AS pct_paid_on_time,
       ROUND(SUM(status = 'Late') * 100.0 / COUNT(*),1) AS pct_late,
       ROUND(SUM(status = 'Missed') * 100.0 / COUNT(*),1) AS pct_missed,
       ROUND(AVG(CASE WHEN days_late > 0 THEN days_late END),1) AS avg_days_late
FROM loan_payments
GROUP BY payment_method
ORDER BY payments DESC;

-- 4.4.11 Top 10 loans by penalties charged
SELECT p.loan_id, l.loan_type, l.loan_status,
       SUM(p.status = 'Late') AS late_payments,
       SUM(p.status = 'Missed') AS missed_payments,
       ROUND(SUM(p.penalty),0) AS total_penalty
FROM loan_payments p
JOIN loans l ON l.loan_id = p.loan_id
GROUP BY p.loan_id, l.loan_type, l.loan_status
ORDER BY total_penalty DESC
LIMIT 10;

-- 4.4.12 Branch loan performance (top 10 by outstanding balance)
SELECT b.branch_id, b.branch_name, COUNT(*) AS loans,
       ROUND(SUM(l.outstanding_balance),0) AS outstanding,
       ROUND(SUM(l.loan_status IN ('Defaulted','In Arrears')) * 100.0 / COUNT(*),1) AS pct_troubled_loans,
       ROUND(AVG(pm.pct_late_or_missed),1) AS avg_pct_late_or_missed_payments
FROM loans l
JOIN branches b ON b.branch_id = l.branch_id
JOIN (SELECT loan_id,
             SUM(status IN ('Late','Missed')) * 100.0 / COUNT(*) AS pct_late_or_missed
      FROM loan_payments GROUP BY loan_id) pm ON pm.loan_id = l.loan_id
GROUP BY b.branch_id, b.branch_name
ORDER BY outstanding DESC
LIMIT 10;

-- 4.4.13 Branches with the highest share of troubled loans (min. 8 loans)
SELECT b.branch_id, b.branch_name, b.region, COUNT(*) AS loans,
       SUM(l.loan_status IN ('Defaulted','In Arrears')) AS troubled_loans,
       ROUND(SUM(l.loan_status IN ('Defaulted','In Arrears')) * 100.0 / COUNT(*),1) AS pct_troubled
FROM loans l
JOIN branches b ON b.branch_id = l.branch_id
GROUP BY b.branch_id, b.branch_name, b.region
HAVING COUNT(*) >= 8
ORDER BY pct_troubled DESC, loans DESC
LIMIT 5;

-- 4.4.14 Loan performance by customer segment
SELECT c.segment, COUNT(*) AS loans,
       ROUND(AVG(c.credit_score),0) AS avg_credit_score,
       ROUND(SUM(l.loan_status IN ('Defaulted','In Arrears')) * 100.0 / COUNT(*),1) AS pct_troubled,
       ROUND(SUM(l.outstanding_balance),0) AS outstanding
FROM loans l
JOIN customers c ON c.customer_id = l.customer_id
GROUP BY c.segment
ORDER BY pct_troubled DESC;

-- 4.4.15 Credit score by loan status
SELECT l.loan_status, COUNT(*) AS loans,
       ROUND(AVG(c.credit_score),0) AS avg_credit_score,
       ROUND(AVG(c.annual_income),0) AS avg_income
FROM loans l
JOIN customers c ON c.customer_id = l.customer_id
GROUP BY l.loan_status
ORDER BY avg_credit_score;

-- 4.4.16 Data check: payments that exceed the scheduled amount by more than 1%
SELECT status, COUNT(*) AS payments_over_scheduled,
       ROUND(MAX(paid_amount / scheduled_amount),1) AS max_multiple_of_scheduled
FROM loan_payments
WHERE paid_amount > scheduled_amount * 1.01
GROUP BY status;


-- ============================================================
-- SPRINT 4.5: CARD USAGE AND PRODUCT ENGAGEMENT
-- ============================================================

-- 4.5.1 Card type summary
SELECT card_type, COUNT(*) AS cards,
       SUM(is_active = 'Yes') AS active_cards,
       ROUND(SUM(is_active = 'Yes') * 100.0 / COUNT(*),1) AS pct_active,
       ROUND(AVG(credit_limit),0) AS avg_credit_limit,
       ROUND(SUM(outstanding_balance),0) AS total_outstanding,
       ROUND(AVG(reward_points),0) AS avg_reward_points
FROM cards
GROUP BY card_type;

-- 4.5.2 Active vs expired cards at the reference date
SELECT is_active,
       COUNT(*) AS cards,
       SUM(expiry_date < (SELECT MAX(transaction_date) FROM transactions)) AS expired,
       SUM(expiry_date >= (SELECT MAX(transaction_date) FROM transactions)) AS not_expired
FROM cards
GROUP BY is_active;

-- 4.5.3 Cards expiring in the 6 months after the reference date
SELECT card_type, COUNT(*) AS cards_expiring_soon,
       SUM(is_active = 'Yes') AS of_which_active
FROM cards
WHERE expiry_date BETWEEN (SELECT MAX(transaction_date) FROM transactions) AND DATE_ADD((SELECT MAX(transaction_date) FROM transactions), INTERVAL 6 MONTH)
GROUP BY card_type;

-- 4.5.4 Credit-card utilisation bands
SELECT CASE WHEN outstanding_balance * 1.0 / credit_limit < 0.25 THEN '1. Under 25%'
            WHEN outstanding_balance * 1.0 / credit_limit < 0.50 THEN '2. 25-49%'
            WHEN outstanding_balance * 1.0 / credit_limit < 0.75 THEN '3. 50-74%'
            ELSE '4. 75%+' END AS utilisation_band,
       COUNT(*) AS credit_cards,
       ROUND(SUM(outstanding_balance),0) AS outstanding
FROM cards
WHERE card_type = 'Credit'
GROUP BY utilisation_band
ORDER BY utilisation_band;

-- 4.5.5 Credit cards: outstanding balance by card status
SELECT is_active, COUNT(*) AS credit_cards,
       ROUND(SUM(credit_limit),0) AS total_limit,
       ROUND(SUM(outstanding_balance),0) AS total_outstanding
FROM cards
WHERE card_type = 'Credit'
GROUP BY is_active;

-- 4.5.6 Credit-limit and balance totals (credit cards)
SELECT COUNT(*) AS credit_cards,
       ROUND(SUM(credit_limit),0) AS total_limit,
       ROUND(SUM(outstanding_balance),0) AS total_outstanding,
       ROUND(SUM(outstanding_balance) * 100.0 / SUM(credit_limit),1) AS overall_utilisation_pct,
       ROUND(AVG(credit_limit),0) AS avg_limit
FROM cards
WHERE card_type = 'Credit';

-- 4.5.7 Network comparison
SELECT network, COUNT(*) AS cards,
       SUM(is_active = 'Yes') AS active_cards,
       SUM(card_type = 'Credit') AS credit_cards,
       ROUND(AVG(reward_points),0) AS avg_reward_points,
       ROUND(AVG(CASE WHEN card_type = 'Credit' THEN credit_limit END),0) AS avg_credit_limit
FROM cards
GROUP BY network
ORDER BY cards DESC;

-- 4.5.8 Reward points: active vs inactive cards
SELECT is_active, COUNT(*) AS cards,
       ROUND(AVG(reward_points),0) AS avg_points,
       SUM(reward_points) AS total_points
FROM cards
GROUP BY is_active;

-- 4.5.9 Top 5 cards by reward points
SELECT c.card_id, c.card_type, c.network, c.is_active, c.reward_points, a.account_type
FROM cards c
JOIN accounts a ON a.account_id = c.account_id
ORDER BY c.reward_points DESC
LIMIT 5;

-- 4.5.10 Cards per account
SELECT cards_on_account, COUNT(*) AS accounts
FROM (SELECT account_id, COUNT(*) AS cards_on_account FROM cards GROUP BY account_id) t
GROUP BY cards_on_account
ORDER BY cards_on_account;

-- 4.5.11 Cards by linked account type and status
SELECT a.account_type, COUNT(*) AS cards,
       SUM(a.status = 'Closed') AS cards_on_closed_accounts,
       SUM(c.card_type = 'Credit') AS credit_cards
FROM cards c
JOIN accounts a ON a.account_id = c.account_id
GROUP BY a.account_type
ORDER BY cards DESC;

-- 4.5.12 Active cards linked to closed accounts
SELECT COUNT(*) AS active_cards_on_closed_accounts
FROM cards c
JOIN accounts a ON a.account_id = c.account_id
WHERE c.is_active = 'Yes' AND a.status = 'Closed';

-- 4.5.13 Product holding per customer (accounts, cards, loans)
SELECT CASE WHEN n_cards > 0 AND n_loans > 0 THEN 'Accounts + Cards + Loans'
            WHEN n_cards > 0 THEN 'Accounts + Cards'
            WHEN n_loans > 0 THEN 'Accounts + Loans'
            ELSE 'Accounts only' END AS product_mix,
       COUNT(*) AS customers
FROM (SELECT c.customer_id,
             (SELECT COUNT(*) FROM cards cd JOIN accounts a ON a.account_id = cd.account_id WHERE a.customer_id = c.customer_id) AS n_cards,
             (SELECT COUNT(*) FROM loans l WHERE l.customer_id = c.customer_id) AS n_loans
      FROM customers c
      WHERE EXISTS (SELECT 1 FROM accounts a WHERE a.customer_id = c.customer_id)) t
GROUP BY product_mix
ORDER BY customers DESC;

-- 4.5.14 Product penetration by segment (share of customers holding each product)
SELECT c.segment, COUNT(*) AS customers,
       ROUND(SUM(EXISTS (SELECT 1 FROM accounts a WHERE a.customer_id = c.customer_id)) * 100.0 / COUNT(*),1) AS pct_with_account,
       ROUND(SUM(EXISTS (SELECT 1 FROM cards cd JOIN accounts a ON a.account_id = cd.account_id WHERE a.customer_id = c.customer_id)) * 100.0 / COUNT(*),1) AS pct_with_card,
       ROUND(SUM(EXISTS (SELECT 1 FROM loans l WHERE l.customer_id = c.customer_id)) * 100.0 / COUNT(*),1) AS pct_with_loan
FROM customers c
GROUP BY c.segment
ORDER BY pct_with_loan DESC;

-- 4.5.15 Customers with a loan but no account
SELECT COUNT(DISTINCT l.customer_id) AS loan_customers_without_account,
       ROUND(SUM(l.outstanding_balance),0) AS outstanding_exposure
FROM loans l
WHERE NOT EXISTS (SELECT 1 FROM accounts a WHERE a.customer_id = l.customer_id);

-- 4.5.16 Customers holding all three products: average credit score and income
SELECT ROUND(AVG(c.credit_score),0) AS avg_credit_score,
       ROUND(AVG(c.annual_income),0) AS avg_income,
       COUNT(*) AS customers
FROM customers c
WHERE EXISTS (SELECT 1 FROM accounts a WHERE a.customer_id = c.customer_id)
  AND EXISTS (SELECT 1 FROM cards cd JOIN accounts a ON a.account_id = cd.account_id WHERE a.customer_id = c.customer_id)
  AND EXISTS (SELECT 1 FROM loans l WHERE l.customer_id = c.customer_id);
