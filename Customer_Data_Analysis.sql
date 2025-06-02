-------------------------------------------------------------------------------------------------------------------------------------------
-- 1. Customer Demographics: What is the age distribution, gender ratio, and income distribution of the customers?
-------------------------------------------------------------------------------------------------------------------------------------------

-- AGE DISTRIBUTION

SELECT 
    CASE 
        WHEN current_age BETWEEN 18 AND 40 THEN 'Young Adult'
        WHEN current_age BETWEEN 41 AND 69 THEN 'Adult'
        WHEN current_age BETWEEN 70 AND 101 THEN 'Old Adult'
    END AS age_group,
    COUNT(*) AS age_count
FROM users_data
GROUP BY age_group
ORDER BY age_count DESC;

-- GENDER RATIO

SELECT gender, 
		count(*) AS age_count,
		CONCAT(ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM users_data), 1), '%') AS gender_percentage
FROM users_data
GROUP BY gender;

-- INCOME DISTRIBUTION

SELECT 
	CASE 
		WHEN per_capita_income < 10000 THEN 'Low Income'
		WHEN per_capita_income BETWEEN 10000 AND 30000  THEN 'Low Middle Income'
		WHEN per_capita_income BETWEEN 30001 AND 60000  THEN 'Middle Income'
		WHEN per_capita_income BETWEEN 60001 AND 90000  THEN 'Upper Middle Income'
		WHEN per_capita_income BETWEEN 90001 AND 170000  THEN 'High Income'
	END AS income_range,
	COUNT(*) AS customer_count,
	CONCAT(ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM users_data), 1), '%') AS customer_pct
FROM users_data
GROUP BY income_range
ORDER BY customer_count DESC;


-------------------------------------------------------------------------------------------------------------------------------------------
-- 2. Credit Card Ownership: How many credit cards does the average user have? Identify customers with multiple credit cards.
-------------------------------------------------------------------------------------------------------------------------------------------

-- NUMBER OF CREDIT CARDS AN AVERAGE USER HAVE

SELECT AVG(num_credit_cards) AS avg_cred_card_per_user
FROM users_data;

--CUSTOMERS WITH MULTIPLE CREDIT CARDS

SELECT *
FROM users_data
WHERE num_credit_cards > 1;


-------------------------------------------------------------------------------------------------------------------------------------------
-- 3. Credit Risk Analysis: Identify top 5 customers with high total debt compared to their yearly income.
-------------------------------------------------------------------------------------------------------------------------------------------
SELECT main_id AS customer_id,
		total_debt, 
		yearly_income
FROM users_data
WHERE total_debt > yearly_income
ORDER BY total_debt DESC
LIMIT 5;


-------------------------------------------------------------------------------------------------------------------------------------------
-- 4. Card Expiration Analysis: How many cards will expire within the next year?
-------------------------------------------------------------------------------------------------------------------------------------------
WITH latest_expiry AS (
    SELECT MAX(expires) AS max_expiry
    FROM cards_data
)
SELECT COUNT(*) AS expiring_cards
FROM cards_data c
JOIN latest_expiry le
ON c.expires BETWEEN le.max_expiry AND le.max_expiry + INTERVAL '1 Year';


-- HOW MANY CARDS EXPIRED LAST YEAR?

SELECT COUNT(*)
FROM cards_data
WHERE expires BETWEEN '2023-01-01'::DATE AND '2023-01-01'::DATE + INTERVAL '1 Year';


-------------------------------------------------------------------------------------------------------------------------------------------
-- 5. Insights for Marketing: Provide insights on which group of customers might be ideal fortargeted marketing campaigns 
-- (based on credit scores, income, and card types)
-------------------------------------------------------------------------------------------------------------------------------------------
-- CREDIT SCORES

WITH cred_score AS (
	SELECT main_id, credit_score, 
	CASE 
		WHEN credit_score BETWEEN 300 AND 579 THEN 'Poor Credit'
		WHEN credit_score BETWEEN 580 AND 669 THEN 'Fair Credit'
		WHEN credit_score BETWEEN 670 AND 739 THEN 'Good Credit'
		WHEN credit_score BETWEEN 740 AND 799 THEN 'Very Good Credit'
		WHEN credit_score BETWEEN 800 AND 850 THEN 'Excellent Credit'
	END AS cred_score_category
FROM users_data)
	SELECT cred_score_category, COUNT(*) AS user_count
	FROM cred_score
	GROUP BY cred_score_category
	ORDER BY user_count DESC;

SELECT ROUND(CORR(yearly_income, credit_score)::NUMERIC, 2) AS corr_income_credscore
FROM users_data;  --No correlation


--INCOME AND CARD TYPE

SELECT 
	card_type,
	CASE 
		WHEN per_capita_income < 10000 THEN 'Low Income'
		WHEN per_capita_income BETWEEN 10000 AND 30000  THEN 'Low Middle Income'
		WHEN per_capita_income BETWEEN 30001 AND 60000  THEN 'Middle Income'
		WHEN per_capita_income BETWEEN 60001 AND 90000  THEN 'Upper Middle Income'
		WHEN per_capita_income BETWEEN 90001 AND 170000  THEN 'High Income'
	END AS income_range,
	COUNT(*) AS customer_count
FROM users_data u
JOIN cards_data c
ON u.main_id = c.client_id
GROUP BY card_type, income_range
ORDER BY card_type, customer_count DESC;


--CARD TYPE

SELECT card_type, COUNT(*)
FROM cards_data
GROUP BY card_type;



-------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------
SELECT *
FROM users_data;

SELECT *
FROM cards_data;




