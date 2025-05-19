# DataAnalytics-Assessment
## Q1. High-Value Customers with Multiple Products Solution
For this query, I needed to identify customers who have both savings plans and investment plans, and then sort them by their total deposits.

### My Approach

* First, I identified customers with funded savings plans with is_regular_savings = 1
* Second, I identified customers with funded investment plans with is_a_fund = 1
* Finally, I joined these results with the users_customuser table to get customer details, ensuring that only customers who appear in both CTEs (Common Table Expressions) are included in the final result.

### Notes

* I converted kobo to currency units by dividing by 100 (confirmed_amount/100)
* I added filter for confirmed_amount > 0 to ensure we're only counting funded plans
* I used COUNT(DISTINCT sa.plan_id) for savings to ensure we're counting unique plans, not just transactions
* For the total deposits calculation, I summed the amounts from the savings accounts
* Added proper joins between savings_savingsaccount and plans_plan tables to connect transaction data with plan types.

### Challenges
* Customer name returned `null`.
  
### Key Changes Made
* Changed the name selection in the final SELECT statement from:
```
sql
u.name
 ```
* To a concatenation of first and last name:
 ```
sql
CONCAT(u.first_name, ' ', u.last_name) AS name
 ```
* This ensures that we'll always have a proper full name for each customer, even if the name field itself is null.
* The concatenation joins the first name and last name with a space in between, creating a properly formatted full name.

This query identifies customers who have both regular savings plans (is_regular_savings = 1) and investment/fund plans (is_a_fund = 1), with the results sorted by total deposits in descending order.  


## Q2. Transaction Frequency Analysis Solution
This query analyzes customer transaction patterns and categorizes them based on their monthly transaction frequency.

### My Approach
I created a multi-step analysis using Common Table Expressions (CTEs):

**Customer Transactions CTE:** First, I calculated the number of transactions each customer makes per month by:

* Grouping transactions by customer ID and transaction month
* Only counting successful transactions where confirmed_amount > 0
* Using DATE_FORMAT to extract year and month from the transaction date


**Average Monthly Transactions CTE:** Next, I calculated the average number of transactions per month for each customer across all their active months.  

**Categorized Customers CTE:** Then, I categorized customers based on the criteria:

**High Frequency**: ≥10 transactions per month  
**Medium Frequency:** 3-9 transactions per month  
**Low Frequency:** ≤2 transactions per month  


<ins>Final Aggregation:</ins> Finally, I aggregated the results by category, calculating:

* Count of customers in each category
* Average number of transactions per month within each category
* Rounding the average to 1 decimal place for readability


**Sorting:** I ordered the results to ensure categories appear in the logical order: High → Medium → Low  



## Q3. Account Inactivity Alert
This SQL query identifies savings accounts that haven't had any successful transactions in over a year (365+ days). 

### My Approach

I'm joined two tables:

* savings_savingsaccount (aliased as s): Contains transaction records
* plans_plan (aliased as pp): Contains plan configurations and types


**Success Criteria:** I was only interested in accounts where:

* The most recent transaction has a "success" status
* There's at least one recorded transaction date
* The plan is active (not deleted)


**Account Classification:** I categorized accounts based on flags in the plans_plan table:

***"Investment"*** if is_a_fund = 1
***"Savings"*** if is_regular_savings = 1
***"Other"*** for any other type


**Inactivity Calculation:** For each account, I:

* Found the most recent transaction date
* Calculated days of inactivity by comparing with the current date
* Filtered for only those exceeding 365 days of inactivity

**Results Organization:** The results are ordered by inactivity period (descending), showing the longest-inactive accounts first.

The query efficiently identifies dormant accounts in the last 365 days.  


## Q4. Customer Lifetime Value (CLV) Estimation

This SQL query to calculate Customer Lifetime Value (CLV) based on account tenure and transaction volume.   

### My Approach
 
In the first part, I created a Common Table Expression (CTE) called customer_transactions to aggregate all transaction data by customer.  

<ins>Key aspects:</ins>

* I joined the users table with the savings_savingsaccount table to get all transactions
* I only considered successful transactions with Lower(s.transaction_status) LIKE '%success%'
* I used COALESCE with the name fields to handle NULL values
* I aggregated to get the total number of transactions and total amount per customer

### Key Considerations
I incorporated several pre-emptive error handling techniques:

* **NULLIF()** to prevent division by zero errors for both tenure months and total transactions
* **TRIM()** and a CASE statement to handle empty names, replacing them with "Unknown"
* **ROUND()** to limit the CLV to 2 decimal places for readability

The results are ordered by estimated_clv DESC to highlight the most valuable customers first, which is crucial for business prioritization.
