##NON-PROFIT DONOR & CAMPAIGN MANAGEMENT SYSTEM
## Class: BUS 385 Data Management

CREATE DATABASE IF NOT EXISTS Nonprofit_db;

USE Nonprofit_db;

##Create Constituents Table1
CREATE TABLE constituents(
constituents_id INT PRIMARY KEY,
type VARCHAR(50),
organization_name VARCHAR(100),
organization_type VARCHAR(50),
first_name VARCHAR(50),
last_name VARCHAR(50),
gender VARCHAR(10),
email VARCHAR(100),
phone VARCHAR(20),
address VARCHAR(225),
city VARCHAR(50),
state VARCHAR(10),
postal_code VARCHAR(10),
creation_date Date
);
SHOW TABLES;
DESCRIBE constituents;
ALTER TABLE constituents
CHANGE constituents_id constituent_id INT;
ALTER TABLE constituents
MODIFY phone VARCHAR(30);
DESCRIBE constituents;
## Table 2: Campaigns
CREATE TABLE campaigns(
campaign_id INT PRIMARY KEY,
name VARCHAR(100),
type VARCHAR(50),
start_date DATE,
end_date DATE,
goal_amount DECIMAL(10,2),
description TEXT
);
## Table 3: Donor_metrics
CREATE TABLE donor_metrics(
constituent_id INT PRIMARY KEY,
first_gift_date DATE,
last_gift_date DATE,
lifetime_gifts INT,
lifetime_giving DECIMAL(10,2),
average_gift DECIMAL(10,2),
largest_gift DECIMAL(10,2),
donor_level VARCHAR(50),
retention_status VARCHAR(50),
has_open_pledge BOOLEAN,
household_id VARCHAR(20),
giving_2021 DECIMAL(10,2),
giving_2022 DECIMAL(10,2),
giving_2023 DECIMAL(10,2),
giving_2024 DECIMAL(10,2),
giving_2025 DECIMAL(10,2),
FOREIGN KEY (constituent_id) REFERENCES constituents(constituent_id)
);
describe donor_metrics;

## Table 4: Transaction(Donations)
CREATE TABLE transactions(
transaction_id INT PRIMARY KEY,
constituent_id INT,
campaign_id INT,
fund_id INT,
transaction_date DATE,
donation_amount DECIMAL(10,2),
payment_method VARCHAR(50),
type VARCHAR(50),
status VARCHAR(50),
FOREIGN KEY (constituent_id) REFERENCES constituents(constituent_id),
FOREIGN KEY (campaign_id) REFERENCES campaigns(campaign_id)
);
DESCRIBE transactions;
SELECT * FROM transactions;

## Table 5 : Pledges
CREATE TABLE pledges(
pledges_id INT PRIMARY KEY,
constituent_id INT,
campaign_id INT,
total_amount DECIMAL(10,2),
installment_amount DECIMAL(10,2),
start_date DATE,
frequency VARCHAR(50),
status VARCHAR(50),
FOREIGN KEY (constituent_id)  REFERENCES constituents(constituent_id),
FOREIGN KEY (campaign_id) REFERENCES campaigns(campaign_id)
);
ALTER TABLE pledges
CHANGE pledges_id pledge_id INT;

## Table 6: pledges_payments
CREATE TABLE pledge_payments(
payment_id INT PRIMARY KEY,
pledge_id INT,
pledge_amount DECIMAL(10,2),
payment_date DATE,
FOREIGN KEY (pledge_id) REFERENCES pledges(pledge_id)
);
ALTER TABLE pledge_payments
 ADD COLUMN status VARCHAR(20);
SHOW CREATE TABLE pledge_payments;
DESCRIBE pledge_payments;
SHOW TABLES;

SELECT * FROM constituents;
SELECT * FROM campaigns;
USE Nonprofit_db;
SELECT dm.constituent_id

FROM donor_metrics dm
LEFT JOIN constituents c
ON dm.constituent_id = c.constituent_id
WHERE c.constituent_id IS NULL;
SELECT * FROM donor_metrics;

USE Nonprofit_db;
ALTER TABLE pledges
ADD COLUMN installments INT;
DESCRIBE pledge_payments;

### Basic Data Exploration
-- View all donors
SELECT * FROM constituents;
-- View all campaigns
SELECT * FROM campaigns;
-- View all pledges
SELECT * FROM pledges;
-- View all transactions
SELECT * FROM transactions;
SELECT * FROM pledge_payments;

--- Campaigns list
SELECT 
campaign_id, name, type, goal_amount, start_date, end_date
From campaigns
ORDER BY start_date DESC;

### View donors Level
SELECT constituent_id, donor_level,retention_status,lifetime_giving
FROM donor_metrics
ORDER BY lifetime_giving DESC;

--- ADDING NEW DATA(DATA ENTRY)
-- Add new donor
INSERT INTO constituents(
constituent_id,type, first_name, last_name,gender,email,phone,address, city,state, postal_code, creation_date)
VALUES(5001, 'Individual', 'Anthony', 'Joseph', 'Male', 'anthonyj@gmil.com', '516-567-8956', '45 Hick Rd', 'Hicksville', 'NY', '11801',
CURDATE()
);
USE Nonprofit_db;
--- Add a new Campaign
INSERT INTO campaigns(
campaign_id, name,type,start_date, end_date, goal_amount, description)
VALUES(999, 'Spring Fundraiser 2025', 'Annual Fund',
    '2025-03-01', '2025-06-30', 50000.00,
    'Spring 2025 fundraising campaign targeting major donors.'
);

### log a donation
INSERT INTO transactions(transaction_id,constituent_id, campaign_id,transaction_date, donation_amount,payment_method)
VALUES(9999, 4999, 999, CURDATE(),
    500.00, 'Credit Card'
);

### Add a new pledge
INSERT INTO pledges (
    pledge_id, constituent_id, campaign_id,
    total_amount,installment_amount, start_date,frequency, status) 
    VALUES (587, 489, 18, 4500.00,2134.54, '2026-04-24', 'Quaterly', 'complete'
    );

### 5 Record a pledge payment
INSERT INTO pledge_payments (
    payment_id, pledge_id, pledge_amount, payment_date
) VALUES (
    1125, 530, 750.00, '2026-04-24'
);

### UPDATE STATEMENT
UPDATE constituents
SET email = 'new.john@gmail.com'
WHERE constituent_id = 2;
SELECT *
FROM constituents
WHERE constituent_id = 2;

## Calculate total payments made toward each pledge, treating no payments as zero

SELECT
    p.pledge_id,
    p.total_amount,
    COALESCE(SUM(pp.pledge_amount), 0) AS total_paid,

    CASE
        WHEN COALESCE(SUM(pp.pledge_amount), 0) >= p.total_amount
        THEN 'Closed'
        ELSE 'Open'
    END AS calculated_pledge_status

FROM pledges p
LEFT JOIN pledge_payments pp
       ON p.pledge_id = pp.pledge_id
GROUP BY p.pledge_id, p.total_amount;

##COALESCE means: “If the value is NULL, replace it with 0”
##If a pledge has no payments yet, SUM() returns NULL, We want 0 instead of NULL

### JOINs ACROSS Tables
-- This query summarizes donor activity by calculating total donations, 
-- total amount given, and donor segmentation based on contribution level.
SELECT 
    c.constituent_id,
    c.first_name,
    c.last_name,
    c.email,
    COUNT(t.transaction_id) AS total_donations,
    SUM(COALESCE(t.donation_amount, 0)) AS total_given,
    MAX(t.transaction_date) AS last_donation_date,
    CASE 
        WHEN SUM(t.donation_amount) >= 10000 THEN 'Major Donor'
        WHEN SUM(t.donation_amount) >= 1500 THEN 'Regular Donor'
        ELSE 'Small Donor'
    END AS donor_segment
FROM constituents c
INNER JOIN transactions t 
    ON c.constituent_id = t.constituent_id
GROUP BY 
    c.constituent_id, c.first_name, c.last_name, c.email
ORDER BY total_given DESC;

### -- This query generates a detailed donation activity report by joining transactions
### with donor and campaign data, and classifies each donation into value tiers for fundraising analysis.

SELECT 
    t.transaction_id,
    c.first_name,
    c.last_name,
    cam.name AS campaign_name,
    t.donation_amount,
   t.transaction_date,
    t.payment_method,

    CASE 
        WHEN t.donation_amount >= 500 THEN 'High Value'
        WHEN t.donation_amount >= 100 THEN 'Medium Value'
        ELSE 'Low Value'
    END AS donation_level

FROM transactions t
INNER JOIN constituents c 
    ON t.constituent_id = c.constituent_id
INNER JOIN campaigns cam 
    ON t.campaign_id = cam.campaign_id
ORDER BY t.transaction_date DESC;

## Descriptive Analysis
##-- This query summarizes campaign performance by calculating total donations, 
## number of donations, and average donation amount for each campaign.
SELECT 
    cam.name AS campaign_name,
    cam.goal_amount,
    SUM(COALESCE(t.donation_amount, 0)) AS total_raised,
    COUNT(t.transaction_id) AS number_of_donations,
    AVG(t.donation_amount) AS average_donation
FROM campaigns cam
LEFT JOIN transactions t 
    ON cam.campaign_id = t.campaign_id
GROUP BY cam.campaign_id, cam.name, cam.goal_amount
ORDER BY total_raised DESC;
USE Nonprofit_db;
## Retrieves the top 10 donors ranked by lifetime giving using precomputed donor metrics.
SELECT 
    c.first_name,
    c.last_name,
    dm.donor_level,
    dm.lifetime_giving,
    dm.lifetime_gifts,
    dm.average_gift
FROM donor_metrics dm
INNER JOIN constituents c 
    ON dm.constituent_id = c.constituent_id
ORDER BY dm.lifetime_giving DESC
LIMIT 10;

##otal donations per state

SELECT 
    c.state,
    COUNT(DISTINCT c.constituent_id)    AS number_of_donors,
    SUM(t.donation_amount)              AS total_donations
FROM constituents c
INNER JOIN transactions t 
    ON c.constituent_id = t.constituent_id
GROUP BY c.state
ORDER BY total_donations DESC;

## Organization-wide year-over-year giving totals (2021–2025)
SELECT
    SUM(COALESCE(giving_2021, 0)) AS total_2021,
    SUM(COALESCE(giving_2022, 0)) AS total_2022,
    SUM(COALESCE(giving_2023, 0)) AS total_2023,
    SUM(COALESCE(giving_2024, 0)) AS total_2024,
    SUM(COALESCE(giving_2025, 0)) AS total_2025
FROM donor_metrics;

## Find the campaign that raised the most money
SELECT name, goal_amount
FROM campaigns
WHERE campaign_id = (
    SELECT campaign_id
    FROM transactions
    GROUP BY campaign_id
    ORDER BY SUM(donation_amount) DESC
    LIMIT 1
);


## Campaign Performance Report: Goal vs. Actual Raised
SELECT 
    cam.name AS campaign_name,
    cam.type,
    cam.goal_amount,
    COALESCE(SUM(t.donation_amount), 0) AS total_raised,
    (cam.goal_amount - COALESCE(SUM(t.donation_amount), 0)) AS gap,
    ROUND(
        (COALESCE(SUM(t.donation_amount), 0) / NULLIF(cam.goal_amount, 0)) * 100,
        2
    ) AS percent_of_goal
FROM campaigns cam
LEFT JOIN transactions t 
    ON cam.campaign_id = t.campaign_id
GROUP BY cam.campaign_id, cam.name, cam.type, cam.goal_amount
ORDER BY percent_of_goal DESC;
