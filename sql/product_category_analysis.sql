--PRODUCT CATEGORY ANALYSIS
--1. Which product category generated the highest revenue?
SELECT
    c.product_category,
    ROUND(SUM(lc.revenue_generated),2) AS total_revenue
FROM campaigns c
JOIN leads_conversions lc
ON c.campaign_id = lc.campaign_id
GROUP BY c.product_category
ORDER BY total_revenue DESC;

--2. Which product category received the highest marketing investment?
SELECT
    c.product_category,
    ROUND(SUM(cs.spend_amount),2) AS total_marketing_spend
FROM campaigns c
JOIN channel_spend cs
ON c.campaign_id = cs.campaign_id
GROUP BY c.product_category
ORDER BY total_marketing_spend DESC;

--3. Which product category achieved the highest ROI?
SELECT
    c.product_category,
    ROUND(SUM(lc.revenue_generated),2) AS revenue,
    ROUND(SUM(cs.spend_amount),2) AS spend,
    ROUND(
        (
            SUM(lc.revenue_generated)-SUM(cs.spend_amount)
        )
        /
        NULLIF(SUM(cs.spend_amount),0)
        *100,
        2
    ) AS roi_percentage
FROM campaigns c
JOIN channel_spend cs
ON c.campaign_id = cs.campaign_id
JOIN leads_conversions lc
ON c.campaign_id = lc.campaign_id
AND cs.channel = lc.channel
GROUP BY c.product_category
ORDER BY roi_percentage DESC;

--4. Which product category generated the most leads?
SELECT
    c.product_category,
    SUM(lc.leads_generated) AS total_leads
FROM campaigns c
JOIN leads_conversions lc
ON c.campaign_id = lc.campaign_id
GROUP BY c.product_category
ORDER BY total_leads DESC;

--5. Which product category produced the highest number of conversions?
SELECT
    c.product_category,
    SUM(lc.conversions) AS total_conversions
FROM campaigns c
JOIN leads_conversions lc
ON c.campaign_id = lc.campaign_id
GROUP BY c.product_category
ORDER BY total_conversions DESC;

--6. Which product category achieved the highest conversion rate?
SELECT
    c.product_category,
    ROUND(
        SUM(lc.conversions)::NUMERIC
        /
        NULLIF(SUM(lc.leads_generated),0)
        *100,
        2
    ) AS conversion_rate
FROM campaigns c
JOIN leads_conversions lc
ON c.campaign_id = lc.campaign_id
GROUP BY c.product_category
ORDER BY conversion_rate DESC;

--7. Which product category had the lowest Cost per Acquisition (CPA)?
SELECT
    c.product_category,
    ROUND(
        SUM(cs.spend_amount)
        /
        NULLIF(SUM(lc.conversions),0),
        2
    ) AS cost_per_acquisition
FROM campaigns c
JOIN channel_spend cs
ON c.campaign_id = cs.campaign_id
JOIN leads_conversions lc
ON c.campaign_id = lc.campaign_id
AND cs.channel = lc.channel
GROUP BY c.product_category
ORDER BY cost_per_acquisition;

--8. Which product category generated the highest ROAS?
SELECT
    c.product_category,
    ROUND(SUM(lc.revenue_generated),2) AS revenue,
    ROUND(SUM(cs.spend_amount),2) AS spend,
    ROUND(
        SUM(lc.revenue_generated)
        /
        NULLIF(SUM(cs.spend_amount),0),
        2
    ) AS roas
FROM campaigns c
JOIN channel_spend cs
ON c.campaign_id = cs.campaign_id
JOIN leads_conversions lc
ON c.campaign_id = lc.campaign_id
AND cs.channel = lc.channel
GROUP BY c.product_category
ORDER BY roas DESC;