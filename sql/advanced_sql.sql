--ADVANCED SQL ANALYSIS

--1. Find campaigns with ROI above the overall company average using a CTE.
WITH campaign_roi AS
(
    SELECT
        c.campaign_name,
        ROUND(SUM(cs.spend_amount),2) AS total_spend,
        ROUND(SUM(lc.revenue_generated),2) AS total_revenue,
        ROUND(
            (
                SUM(lc.revenue_generated)-SUM(cs.spend_amount)
            )
            /
            NULLIF(SUM(cs.spend_amount),0)
            *100,
            2
        ) AS roi
    FROM campaigns c
    JOIN channel_spend cs
        ON c.campaign_id = cs.campaign_id
    JOIN leads_conversions lc
        ON c.campaign_id = lc.campaign_id
       AND cs.channel = lc.channel
    GROUP BY c.campaign_name
)

SELECT *
FROM campaign_roi
WHERE roi >
(
    SELECT AVG(roi)
    FROM campaign_roi
)
ORDER BY roi DESC;

--2Create a summary showing each campaign's marketing spend, revenue, and ROI.
--##Build a campaign performance summary using layered CTEs.
WITH spend_cte AS
(
    SELECT
        campaign_id,
        SUM(spend_amount) AS total_spend
    FROM channel_spend
    GROUP BY campaign_id
),

revenue_cte AS
(
    SELECT
        campaign_id,
        SUM(revenue_generated) AS total_revenue
    FROM leads_conversions
    GROUP BY campaign_id
)

SELECT
    c.campaign_name,
    s.total_spend,
    r.total_revenue,
    ROUND(
        (
            r.total_revenue-s.total_spend
        )
        /
        NULLIF(s.total_spend,0)
        *100,
        2
    ) AS roi_percentage
FROM campaigns c
JOIN spend_cte s
ON c.campaign_id=s.campaign_id
JOIN revenue_cte r
ON c.campaign_id=r.campaign_id
ORDER BY roi_percentage DESC;

--3.Rank every campaign from best ROI to worst ROI.
--(Rank campaigns by ROI using RANK())
WITH campaign_roi AS
(
    SELECT
        c.campaign_name,
        ROUND(
            (
                SUM(lc.revenue_generated)-SUM(cs.spend_amount)
            )
            /
            NULLIF(SUM(cs.spend_amount),0)
            *100,
            2
        ) AS roi
    FROM campaigns c
    JOIN channel_spend cs
        ON c.campaign_id=cs.campaign_id
    JOIN leads_conversions lc
        ON c.campaign_id=lc.campaign_id
       AND cs.channel=lc.channel
    GROUP BY c.campaign_name
)

SELECT
    campaign_name,
    roi,
    RANK() OVER(ORDER BY roi DESC) AS campaign_rank
FROM campaign_roi;

--4.Which campaign performed best within each product category?
WITH campaign_roi AS
(
    SELECT
        c.product_category,
        c.campaign_name,
        ROUND(
            (
                SUM(lc.revenue_generated)-SUM(cs.spend_amount)
            )
            /
            NULLIF(SUM(cs.spend_amount),0)
            *100,
            2
        ) AS roi
    FROM campaigns c
    JOIN channel_spend cs
        ON c.campaign_id=cs.campaign_id
    JOIN leads_conversions lc
        ON c.campaign_id=lc.campaign_id
       AND cs.channel=lc.channel
    GROUP BY c.product_category,c.campaign_name
)

SELECT *
FROM
(
    SELECT *,
           ROW_NUMBER() OVER(
               PARTITION BY product_category
               ORDER BY roi DESC
           ) AS rn
    FROM campaign_roi
) t
WHERE rn=1;


--5. How has cumulative revenue grown as campaigns were launched?
SELECT
    c.start_date,
    SUM(lc.revenue_generated) AS revenue,
    SUM(SUM(lc.revenue_generated))
        OVER(
            ORDER BY c.start_date
        ) AS cumulative_revenue
FROM campaigns c
JOIN leads_conversions lc
ON c.campaign_id=lc.campaign_id
GROUP BY c.start_date
ORDER BY c.start_date;

--6. How did revenue change from one campaign launch period to the next?
--(Calculate revenue growth between campaign start dates using LAG()...)
WITH monthly_revenue AS
(
    SELECT
        DATE_TRUNC('month', c.start_date) AS month,
        SUM(lc.revenue_generated) AS revenue
    FROM campaigns c
    JOIN leads_conversions lc
    ON c.campaign_id=lc.campaign_id
    GROUP BY DATE_TRUNC('month', c.start_date)
)

SELECT
    month,
    revenue,
    LAG(revenue)
        OVER(
            ORDER BY month
        ) AS previous_month,
    ROUND(
        (
            revenue-
            LAG(revenue)
            OVER(ORDER BY month)
        )
        /
        NULLIF(
            LAG(revenue)
            OVER(ORDER BY month),
            0
        )
        *100,
        2
    ) AS revenue_growth_percentage
FROM monthly_revenue;

--7. Categorize campaigns based on their ROI performance.
--(Classify campaigns as High, Medium, and Low performers using CASE.)

WITH campaign_roi AS
(
    SELECT
        c.campaign_name,
        ROUND(
            (
                SUM(lc.revenue_generated)-SUM(cs.spend_amount)
            )
            /
            NULLIF(SUM(cs.spend_amount),0)
            *100,
            2
        ) AS roi
    FROM campaigns c
    JOIN channel_spend cs
        ON c.campaign_id=cs.campaign_id
    JOIN leads_conversions lc
        ON c.campaign_id=lc.campaign_id
       AND cs.channel=lc.channel
    GROUP BY c.campaign_name
)

SELECT
    campaign_name,
    roi,
    CASE
        WHEN roi >= 100 THEN 'High Performer'
        WHEN roi >= 50 THEN 'Medium Performer'
        ELSE 'Low Performer'
    END AS performance_category
FROM campaign_roi
ORDER BY roi DESC;

--8. Which campaigns generated more revenue than the company average?
--//Identify campaigns with revenue above the company average using a subquery.
SELECT
    c.campaign_name,
    SUM(lc.revenue_generated) AS total_revenue
FROM campaigns c
JOIN leads_conversions lc
ON c.campaign_id=lc.campaign_id
GROUP BY c.campaign_name
HAVING SUM(lc.revenue_generated) >
(
    SELECT AVG(revenue)
    FROM
    (
        SELECT
            SUM(revenue_generated) AS revenue
        FROM leads_conversions
        GROUP BY campaign_id
    ) avg_revenue
)
ORDER BY total_revenue DESC;