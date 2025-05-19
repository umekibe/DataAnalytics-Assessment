-- Transaction Frequency Analysis
-- This query categorizes customers based on their average monthly transaction frequency

WITH 
-- Calculate transactions per customer per month
customer_transactions AS (
    SELECT
        sa.owner_id,
        -- Extract year and month from transaction date
        DATE_FORMAT(sa.transaction_date, '%Y-%m') AS transaction_month,
        COUNT(*) AS transactions_count
    FROM
        savings_savingsaccount sa
    WHERE
        sa.confirmed_amount > 0  -- Only count transactions with confirmed amounts
        AND sa.transaction_status like '%success%' -- Only count successful transactions
    GROUP BY
        sa.owner_id,
        DATE_FORMAT(sa.transaction_date, '%Y-%m')
),

-- Calculate average monthly transactions per customer
avg_monthly_transactions AS (
    SELECT
        owner_id,
        AVG(transactions_count) AS avg_transactions_per_month
    FROM
        customer_transactions
    GROUP BY
        owner_id
),

-- Categorize customers by transaction frequency
categorized_customers AS (
    SELECT
        CASE
            WHEN avg_transactions_per_month >= 10 THEN 'High Frequency'
            WHEN avg_transactions_per_month >= 3 THEN 'Medium Frequency'
            ELSE 'Low Frequency'
        END AS frequency_category,
        owner_id,
        avg_transactions_per_month
    FROM
        avg_monthly_transactions
)

-- Aggregate results by category
SELECT
    frequency_category,
	COUNT(*) AS customer_count,
    ROUND(AVG(avg_transactions_per_month), 1) AS avg_transactions_per_month
FROM
    categorized_customers
GROUP BY
    frequency_category
ORDER BY
    CASE 
        WHEN frequency_category = 'High Frequency' THEN 1
        WHEN frequency_category = 'Medium Frequency' THEN 2
        WHEN frequency_category = 'Low Frequency' THEN 3
    END;