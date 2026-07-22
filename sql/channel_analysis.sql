--#CHANNEL PERFORMANCE
--1. Which marketing channel generated the highest revenue?
SELECT
    channel,
    ROUND(SUM(revenue_generated),2) AS total_revenue
FROM leads_conversions
GROUP BY channel
ORDER BY total_revenue DESC;

--2. Which marketing channel had the highest marketing spend?
SELECT
    channel,
    ROUND(SUM(spend_amount),2) AS total_spend
FROM channel_spend
GROUP BY channel
ORDER BY total_spend DESC;

--3. Which marketing channel generated the highest ROI?
SELECT
    cs.channel,
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
FROM channel_spend cs
JOIN leads_conversions lc
ON cs.campaign_id = lc.campaign_id
AND cs.channel = lc.channel
GROUP BY cs.channel
ORDER BY roi_percentage DESC;


--4. Which marketing channel generated the most leads?
SELECT
    channel,
    SUM(leads_generated) AS total_leads
FROM leads_conversions
GROUP BY channel
ORDER BY total_leads DESC;

--5. Which marketing channel achieved the highest conversion rate?
SELECT
    channel,
    ROUND(
        SUM(conversions)::numeric
        /
        NULLIF(SUM(leads_generated),0)
        *100,
        2
    ) AS conversion_rate
FROM leads_conversions
GROUP BY channel
ORDER BY conversion_rate DESC;

--6. Which marketing channel had the lowest Cost per Lead (CPL)?
SELECT
    cs.channel,
    ROUND(
        SUM(cs.spend_amount)
        /
        NULLIF(SUM(lc.leads_generated),0),
        2
    ) AS cost_per_lead
FROM channel_spend cs
JOIN leads_conversions lc
ON cs.campaign_id = lc.campaign_id
AND cs.channel = lc.channel
GROUP BY cs.channel
ORDER BY cost_per_lead;

--7. Which marketing channel had the lowest Cost per Acquisition (CPA)?
SELECT
    cs.channel,
    ROUND(
        SUM(cs.spend_amount)
        /
        NULLIF(SUM(lc.conversions),0),
        2
    ) AS cost_per_acquisition
FROM channel_spend cs
JOIN leads_conversions lc
ON cs.campaign_id = lc.campaign_id
AND cs.channel = lc.channel
GROUP BY cs.channel
ORDER BY cost_per_acquisition;