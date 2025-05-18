
This project contains SQL queries developed to provide actionable insights across customer behavior, transaction patterns, product engagement, and lifetime value using data from a savings/investment platform.

---

## 1.  High-Value Customers with Multiple Products

###  Scenario:
Identify customers who have both **savings** and **investment** plans — a key segment for cross-selling opportunities.

###  Approach:
- Join the `plans_plan` table with the `savings_savingsaccount` table using the `plan_id` and `owner_id`, with subquery that summarizes funded savings and investment accounts per user
- Filter savings where `is_regular_savings = 1` and investments where `is_a_fund = 1`.
- Ensure that only plans with inflows (`confirmed_amount > 0`) are counted.
- Calculate total deposits (sum of savings and investment inflows based on the hints given), convert from kobo to naira, and round to 2 decimal places
- Group by customer, count savings and investment plans, and sum the confirmed amounts.

### 📤 Output:
- `owner_id`, `name`, `savings_count`, `investment_count`, `total_deposits`

---

## 2.  Transaction Frequency Analysis

###  Scenario:
Segment customers based on **transaction frequency** to identify behavior patterns (e.g., frequent vs. occasional users).

###  Approach:
- Count the number of transactions per user from `savings_savingsaccount`.
- Calculate the tenure in months from the user's first transaction to the last.
- Derive the average number of transactions per month.
- Categorize customers based on frequency thresholds:
  - High (≥10/month)
  - Medium (3–9/month)
  - Low (≤2/month)
- Group by category and count how many customers fall into each segment.

### 📤 Output:
- `frequency_category`, `customer_count`, `avg_transactions_per_month`

---

## 3.  Account Inactivity Alert

###  Scenario:
Detect active accounts (savings or investment plans) with **no deposits for over 1 year**.

###  Approach:
- Join `plans_plan` with `savings_savingsaccount` using `plan_id`.
- Filter for `confirmed_amount > 0` (i.e., inflow).
- Use `MAX(transaction_date)` per plan to get the last activity.
- Use `TIMESTAMPDIFF` to compute the number of days between the latest transaction in the table and each plan's last activity.
- Use `HAVING` to select only those plans that are inactive for over 365 days or have never had any transaction.

### 📤 Output:
- `plan_id`, `owner_id`, `type`, `last_transaction_date`, `inactivity_days`

---

## 4.  Customer Lifetime Value (CLV) Estimation

###  Scenario:
Estimate **CLV** using a simplified model based on tenure and transaction value.

###  Approach:
- Calculate `tenure_months` as the number of months between the `date_joined` and the latest `transaction_date` per user.
- Sum `confirmed_amount` for each user and assume 0.1% is the profit per transaction.
- Apply the formula which was stated in the question.
- Round CLV to 2 decimal places and sort customers by estimated CLV.

###  Output:
- `customer_id`, `name`, `tenure_months`, `total_transactions`, `estimated_clv`



##  Challenges and Resolutions:

### 1. **Join Direction Errors**
- **Challenge:** In early queries, joins were done using `owner_id` instead of `plan_id`, which led to mismatches between customers and plans.
- **Resolution:** Corrected the join to use `savings_savingsaccount.plan_id = plans_plan.id` as intended.

### 2. **SQL Syntax Differences**
- **Challenge:** Some functions like `DATE_PART()` used in PostgreSQL didn't work in MySQL.
- **Resolution:** Replaced them with MySQL-compatible functions such as `TIMESTAMPDIFF()` and adjusted date calculations accordingly.

### 3. **NULL Handling in Aggregates**
- **Challenge:** Accounts with no transactions returned `NULL` in aggregations, affecting logic in inactivity detection.
- **Resolution:** Used `HAVING MAX(transaction_date) IS NULL` to explicitly handle accounts with zero transaction history.

---

## Conclusion

These SQL reports provide deep insights into customer behavior, helping teams across operations, finance, and marketing make informed, data-driven decisions. Each query is optimized for clarity and efficiency, with clear segmentation logic and robust date handling.
