/*
ACCOUNT INACTIVITY ALERT 
Identifies savings accounts with no successful transactions in 365+ days
Uses confirmed columns from both tables
*/

SELECT 
    s.plan_id,
    s.owner_id,
    CASE 
        WHEN pp.is_a_fund = 1 THEN 'Investment'
        WHEN pp.is_regular_savings = 1 THEN 'Savings'
        ELSE 'Other'
    END AS type,
    MAX(s.transaction_date) AS last_transaction_date,
    DATEDIFF(CURRENT_DATE(), MAX(s.transaction_date)) AS inactivity_days
FROM 
    savings_savingsaccount s
JOIN 
    plans_plan pp ON s.plan_id = pp.id
WHERE 
    s.transaction_status = 'success'
    AND s.transaction_date IS NOT NULL
    AND pp.is_deleted = 0 -- Active plans only
GROUP BY 
    s.plan_id, s.owner_id, type
HAVING 
    inactivity_days > 365
ORDER BY 
    inactivity_days DESC;