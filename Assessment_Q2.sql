SELECT 
-- Using case to categorize the frequency range 
  CASE 
    WHEN ROUND(tf.total_transactions / tf.active_months, 1) >= 10 THEN 'High Frequency'
    WHEN ROUND(tf.total_transactions / tf.active_months, 1) BETWEEN 3 AND 9 THEN 'Medium Frequency'
    ELSE 'Low Frequency'
  END AS frequency_category,
  COUNT(*) AS customer_count,
  ROUND(AVG(tf.total_transactions / tf.active_months), 1) AS avg_transactions_per_month
FROM (
  -- Subquery is used to calculate total transactions and active months per user
  SELECT 
    s.owner_id,
    COUNT(*) AS total_transactions,
    
    -- assuming a continuous engagement and a general time-based estimate
    
    TIMESTAMPDIFF(
    MONTH, MIN(transaction_date), 
    MAX(transaction_date)) 
    + 1 AS active_months 
  FROM savings_savingsaccount AS s
  GROUP BY s.owner_id
) AS tf
GROUP BY frequency_category
ORDER BY 
  CASE 
    WHEN frequency_category = 'High Frequency' THEN 1
    WHEN frequency_category = 'Medium Frequency' THEN 2
    ELSE 3
  END;