--CAMPAIGN PERFORMANCE ANALYSIS
--15. Which campaigns generated the highest revenue?
SELECT
    c.campaign_name,
    ROUND(SUM(lc.revenue_generated),2) AS total_revenue
FROM campaigns c
JOIN leads_conversions lc
ON c.campaign_id = lc.campaign_id
GROUP BY c.campaign_name
ORDER BY total_revenue DESC;

--16. Which campaigns had the highest marketing spend?
SELECT
    c.campaign_name,
    ROUND(SUM(cs.spend_amount),2) AS total_spend
FROM campaigns c
JOIN channel_spend cs
ON c.campaign_id = cs.campaign_id
GROUP BY c.campaign_name
ORDER BY total_spend DESC;

--17. Which campaigns generated the highest number of conversions?
SELECT
    c.campaign_name,
    SUM(lc.conversions) AS total_conversions
FROM campaigns c
JOIN leads_conversions lc
ON c.campaign_id = lc.campaign_id
GROUP BY c.campaign_name
ORDER BY total_conversions DESC;

--18. Which campaigns achieved the highest ROI?
SELECT
    c.campaign_name,
    ROUND(SUM(lc.revenue_generated),2) AS revenue,
    ROUND(SUM(cs.spend_amount),2) AS spend,
    ROUND(
        (
            SUM(lc.revenue_generated) -
            SUM(cs.spend_amount)
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
GROUP BY c.campaign_name
ORDER BY roi_percentage DESC;

--19. Which campaigns spent above the average marketing budget?
SELECT
    c.campaign_name,
    ROUND(SUM(cs.spend_amount),2) AS total_spend
FROM campaigns c
JOIN channel_spend cs
ON c.campaign_id = cs.campaign_id
GROUP BY c.campaign_name
HAVING SUM(cs.spend_amount) >
(
    SELECT AVG(total_spend)
    FROM
    (
        SELECT
            SUM(spend_amount) AS total_spend
        FROM channel_spend
        GROUP BY campaign_id
    ) avg_campaign
)
ORDER BY total_spend DESC;

--20. Which campaigns generated below-average revenue despite high spending?
WITH campaign_summary AS
(
    SELECT
        c.campaign_name,
        SUM(cs.spend_amount) AS total_spend,
        SUM(lc.revenue_generated) AS total_revenue
    FROM campaigns c
    JOIN channel_spend cs
        ON c.campaign_id = cs.campaign_id
    JOIN leads_conversions lc
        ON c.campaign_id = lc.campaign_id
       AND cs.channel = lc.channel
    GROUP BY c.campaign_name
)

SELECT
    campaign_name,
    ROUND(total_spend,2) AS total_spend,
    ROUND(total_revenue,2) AS total_revenue
FROM campaign_summary
WHERE total_spend >
(
    SELECT AVG(total_spend)
    FROM campaign_summary
)
AND total_revenue <
(
    SELECT AVG(total_revenue)
    FROM campaign_summary
)
ORDER BY total_spend DESC;