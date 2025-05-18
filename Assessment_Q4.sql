SELECT
    u.id AS customer_id,
    CONCAT(u.first_name, ' ', u.last_name) AS name,
    
    -- Tenure in months from signup to latest transaction date
    TIMESTAMPDIFF(MONTH, u.date_joined, MAX(s.transaction_date)) AS tenure_months,

    -- Total confirmed inflow transactions in naira
    SUM(s.confirmed_amount) / 100 AS total_transactions,

    -- Estimated CLV based on formula
    ROUND((
        (SUM(s.confirmed_amount) / 100) / TIMESTAMPDIFF(MONTH, u.date_joined, MAX(s.transaction_date))
    ) * 12 * 0.001, 2) AS estimated_clv

FROM users_customuser u

-- Join savings transactions, Including all users — even those who have no transactions yet
LEFT JOIN savings_savingsaccount s
    ON u.id = s.owner_id AND s.confirmed_amount > 0

GROUP BY u.id, u.first_name, u.last_name, u.date_joined

HAVING tenure_months > 0  -- prevent divide-by-zero errors

ORDER BY estimated_clv DESC;