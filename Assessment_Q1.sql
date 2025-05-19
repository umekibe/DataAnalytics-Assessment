-- High-Value Customers with Multiple Products
-- This query identifies customers who have both savings and investment plans
-- sorted by their total deposits

WITH 
-- First, identify customers with at least one funded savings plan (is_regular_savings = 1)
customers_with_savings AS (
    SELECT 
        sa.owner_id,
        COUNT(DISTINCT sa.plan_id) AS savings_count,
        SUM(sa.confirmed_amount)/100 AS total_savings_amount -- Convert from kobo to currency units
    FROM savings_savingsaccount sa
    JOIN plans_plan p ON sa.plan_id = p.id
    WHERE p.is_regular_savings = 1
    AND sa.confirmed_amount > 0
    GROUP BY sa.owner_id
    HAVING COUNT(DISTINCT sa.plan_id) > 0
),

-- Next, identify customers with at least one funded investment plan (is_a_fund = 1)
customers_with_investments AS (
    SELECT 
        sa.owner_id,
        COUNT(DISTINCT sa.plan_id) AS investment_count
    FROM savings_savingsaccount sa
    JOIN plans_plan p ON sa.plan_id = p.id
    WHERE p.is_a_fund = 1
    AND sa.confirmed_amount > 0
    GROUP BY sa.owner_id
    HAVING COUNT(DISTINCT sa.plan_id) > 0
)

-- Finally, join the two CTEs with the users table to get customer details
SELECT 
    u.id AS owner_id,
    CONCAT(u.first_name, ' ', u.last_name) AS name,
    cws.savings_count,
    cwi.investment_count,
    cws.total_savings_amount AS total_deposits
FROM users_customuser u
INNER JOIN customers_with_savings cws ON u.id = cws.owner_id
INNER JOIN customers_with_investments cwi ON u.id = cwi.owner_id
ORDER BY total_deposits DESC;