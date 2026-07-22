--CUSTOMER ANALYSIS
--1. Which acquisition channel acquired the most customers?
SELECT
    acquisition_channel,
    COUNT(customer_id) AS total_customers
FROM customers
GROUP BY acquisition_channel
ORDER BY total_customers DESC;


--2. Which acquisition channel generated the highest Customer Lifetime Value (LTV)?
SELECT
    acquisition_channel,
    ROUND(SUM(total_ltv),2) AS total_customer_ltv
FROM customers
GROUP BY acquisition_channel
ORDER BY total_customer_ltv DESC;


--3. Which acquisition channel generated the highest average first purchase value?
SELECT
    acquisition_channel,
    ROUND(AVG(first_purchase_value),2) AS avg_first_purchase_value
FROM customers
GROUP BY acquisition_channel
ORDER BY avg_first_purchase_value DESC;

--4. Which acquisition channel generated the highest repeat purchase rate?
SELECT
    acquisition_channel,
    ROUND(
        COUNT(
            CASE
                WHEN repeat_purchase_count > 0 THEN 1
            END
        )::NUMERIC
        /
        COUNT(customer_id)
        *100,
        2
    ) AS repeat_purchase_rate
FROM customers
GROUP BY acquisition_channel
ORDER BY repeat_purchase_rate DESC;

--5. What percentage of customers made repeat purchases?
SELECT
    ROUND(
        COUNT(
            CASE
                WHEN repeat_purchase_count > 0 THEN 1
            END
        )::NUMERIC
        /
        COUNT(customer_id)
        *100,
        2
    ) AS repeat_purchase_percentage
FROM customers;