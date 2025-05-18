SELECT US.id AS owner_id, concat(US.first_name, ' ' , US.last_name) AS name, 

-- Get savings and investment account counts

savings_summary.savings_count,
investment_summary.investment_count,

 -- Calculate total deposits (sum of savings and investment inflows based on the hints given), convert from kobo to naira, and round to 2 decimal places
 
 ROUND((savings_summary.total_savings_inflow + investment_summary.total_investment_inflow) / 100.0, 2) AS total_deposits
FROM users_customuser AS US

-- Join with subquery that summarizes funded savings accounts per user

JOIN (
      SELECT s.owner_id, COUNT(*)AS savings_count, SUM(s.confirmed_amount) AS total_savings_inflow
      FROM savings_savingsaccount AS s
      JOIN plans_plan AS p
      ON p.id = s.plan_id
      WHERE p.is_regular_savings = 1 AND s.confirmed_amount > 0   -- Filter for savings plans and Only include funded accounts
      
      GROUP BY s.owner_id) AS savings_summary ON US.id = savings_summary.owner_id
JOIN (
      SELECT s.owner_id, COUNT(*)AS investment_count, SUM(s.confirmed_amount) AS total_investment_inflow
      FROM savings_savingsaccount AS s
      JOIN plans_plan AS p
      ON p.id = s.plan_id
      WHERE p.is_a_fund = 1 AND s.confirmed_amount > 0
      GROUP BY s.owner_id) AS investment_summary ON US.id = investment_summary.owner_id
ORDER BY total_deposits DESC;