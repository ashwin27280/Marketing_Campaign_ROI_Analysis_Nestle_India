--EXECUTIVE KPIs

--1. What is the total amount spent on marketing across all campaigns?
select sum(spend_amount) as tota_marketing_spend
from channel_spend;


--2. What is the total revenue generated from all marketing campaigns?
select round(sum(revenue_generated),2) as tota_revenue_generated
from leads_conversions;

--3. How many leads were generated across all campaigns?
select sum(leads_generated) as tota_leads_generated
from leads_conversions;

--4.How many customers converted?
SELECT
    SUM(conversions) AS total_conversions
FROM leads_conversions;

--5. What is the overall conversion rate?
SELECT
    ROUND(
        (SUM(conversions)::NUMERIC / NULLIF(SUM(leads_generated), 0)) * 100,
        2
    ) AS conversion_rate
FROM leads_conversions;

--6. What is the overall Marketing ROI?
SELECT
ROUND(
(
r.total_revenue-s.total_spend
)
/
s.total_spend
*100
,2) AS marketing_roi
FROM
(
SELECT SUM(revenue_generated) AS total_revenue
FROM leads_conversions
) r
CROSS JOIN
(
SELECT SUM(spend_amount) AS total_spend
FROM channel_spend
) s;

--7. What is the average revenue generated per conversion?
SELECT round(SUM(revenue_generated)/SUM(conversions),2)
AS avg_revenue_per_conversion
FROM leads_conversions;
