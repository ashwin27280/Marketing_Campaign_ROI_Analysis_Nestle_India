create table campaigns(
campaign_id	int primary key,
campaign_name	varchar(100),
product_category	varchar(100),
brand	varchar(100),
start_date	date,
end_date	date,
total_budget	int,
region	varchar(100),
season_tag	varchar(100),
campaign_duration int
);

create table channel_spend(
spend_id	int primary key,
campaign_id	int,
channel	varchar(100),
platform	varchar(100),
spend_amount	int,
impressions	NUMERIC,
clicks	NUMERIC,
grps NUMERIC,

foreign key(campaign_id)
references campaigns(campaign_id)
);

CREATE TABLE leads_conversions (
    record_id int PRIMARY KEY,
    campaign_id int,
    channel VARCHAR(50),
    leads_generated INT,
    conversions INT,
    revenue_generated NUMERIC,

    FOREIGN KEY (campaign_id)
    REFERENCES campaigns(campaign_id)
);

CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    campaign_id INT,
    acquisition_channel VARCHAR(50),
    first_purchase_value NUMERIC(12,2),
    repeat_purchase_count INTEGER,
    total_ltv NUMERIC(12,2),

    FOREIGN KEY (campaign_id)
    REFERENCES campaigns(campaign_id)
);
