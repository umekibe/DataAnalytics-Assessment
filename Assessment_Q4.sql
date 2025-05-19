/*
CUSTOMER LIFETIME VALUE (CLV) ESTIMATION 

*/

WITH customer_transactions AS (
    SELECT 
        u.id AS customer_id,
        CONCAT(COALESCE(u.first_name, ''), ' ', COALESCE(u.last_name, '')) AS name,
        u.date_joined,
        COUNT(s.id) AS total_transactions,
        SUM(s.amount) AS total_transaction_amount
    FROM 
        users_customuser u
    JOIN 
        savings_savingsaccount s ON u.id = s.owner_id
    WHERE 
        Lower(s.transaction_status) LIKE '%success%' -- only successful transactions
    GROUP BY 
        u.id, u.first_name, u.last_name, u.date_joined
)

SELECT 
    customer_id,
    CASE 
        WHEN name = ' ' THEN 'Unknown' 
        ELSE TRIM(name) 
    END AS name,
    TIMESTAMPDIFF(MONTH, date_joined, CURRENT_DATE()) AS tenure_months, -- to find months since signup
    total_transactions,
    ROUND((total_transactions / NULLIF(TIMESTAMPDIFF(MONTH, date_joined, CURRENT_DATE()), 0)) * 
          12 * 
          (0.001 * (total_transaction_amount / NULLIF(total_transactions, 0))), 2) AS estimated_clv -- NULLIF() to prevent division by zero errors
FROM 
    customer_transactions
ORDER BY 
    estimated_clv DESC;