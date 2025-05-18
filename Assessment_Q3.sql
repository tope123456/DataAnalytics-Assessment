SELECT 
    pp.id AS plan_id,                 -- Unique ID of the plan
    pp.owner_id,                     -- Owner (user) of the plan
    CASE
        WHEN pp.is_regular_savings = 1 THEN 'Savings'     -- Identify plan type as Savings
        WHEN pp.is_a_fund = 1 THEN 'Investment'           -- Identify plan type as Investment
        ELSE 'Unknown'                                    -- Default to Unknown if not marked
    END AS type,
    
    MAX(s.transaction_date) AS last_transaction_date,     -- Last transaction date per plan

    -- Calculate days since last transaction, relative to latest date in the entire table
    TIMESTAMPDIFF(
        DAY,
        MAX(s.transaction_date),                          -- Last transaction date for this plan
        (SELECT MAX(transaction_date) FROM savings_savingsaccount)  -- Latest transaction date in the table
    ) AS inactivity_days

FROM plans_plan AS pp

-- Join with savings account transactions using plan_id and only confirmed inflow transactions
LEFT JOIN savings_savingsaccount AS s
    ON pp.id = s.plan_id AND s.confirmed_amount > 0

-- Group by necessary fields (everything not aggregated in SELECT)
GROUP BY
    pp.id, pp.owner_id, pp.is_regular_savings, pp.is_a_fund

-- Filter for plans with:
--   - No transactions at all (MAX is NULL)
--   - Last transaction more than 365 days older than the most recent in the system
HAVING 
    MAX(s.transaction_date) IS NULL
    OR MAX(s.transaction_date) < (
        SELECT MAX(transaction_date) FROM savings_savingsaccount
    ) - INTERVAL 365 DAY

-- Order: active accounts with longest inactivity first, NULLs (no transactions) at the bottom
ORDER BY 
    inactivity_days IS NULL,   -- Places rows with NULL inactivity_days (no transactions) last
    inactivity_days DESC;      -- Then sort by inactivity duration (largest to smallest)