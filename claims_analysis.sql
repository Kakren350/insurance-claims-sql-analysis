CREATE DATABASE insurance_claims;
USE insurance_claims;

SELECT COUNT(*) FROM policies;
SELECT COUNT(*) FROM claims;

describe policies;
describe claims;

-- Day 1: Fix corrupted column name in policies
ALTER TABLE policies CHANGE `ï»¿Policy_ID` Policy_ID VARCHAR(20);
SET SQL_SAFE_UPDATES = 0;
UPDATE policies
SET Annual_Premium = TRIM(REPLACE(REPLACE(REPLACE(Annual_Premium, 'KES', ''),',', ''), '\r', ''));
ALTER TABLE policies MODIFY Annual_Premium DECIMAL(12,2);

describe policies;
SELECT Annual_Premium FROM policies LIMIT 5;
SELECT COUNT(*) FROM policies;

describe policies;

describe claims;
select * from claims limit 5;

-- Day 1: Fix corrupted column name in claims
ALTER TABLE claims CHANGE `ï»¿Claim_ID` Claim_ID VARCHAR(20);
-- Match Policy_ID type with policies table
ALTER TABLE claims MODIFY Policy_ID VARCHAR(20);
SET SQL_SAFE_UPDATES = 0;

-- Clean amounts in claims (remove KES, commas, spaces)
UPDATE claims
SET Incurred_Amount     = TRIM(REPLACE(REPLACE(Incurred_Amount, 'KES', ''), ',', '')),
    Paid_Amount         = TRIM(REPLACE(REPLACE(Paid_Amount, 'KES', ''), ',', '')),
    Recognised_Incurred = TRIM(REPLACE(REPLACE(Recognised_Incurred, 'KES', ''), ',', ''));
    
    -- Look at the cleaned values
SELECT Incurred_Amount, Paid_Amount, Recognised_Incurred FROM claims LIMIT 10;

-- Inspect rows where Recognised_Incurred is a dash
SELECT Claim_ID, Claim_Status, Incurred_Amount, Paid_Amount, Recognised_Incurred
FROM claims
WHERE Recognised_Incurred = '-'
LIMIT 10;

-- Count dash rows by claim status
SELECT Claim_Status, COUNT(*) AS dash_rows
FROM claims
WHERE Recognised_Incurred = '-'
GROUP BY Claim_Status;

-- Replace dash with 0 (all dash rows are Rejected claims)
UPDATE claims
SET Recognised_Incurred = '0'
WHERE Recognised_Incurred = '-';

-- Check for leftover non-numeric values
SELECT Incurred_Amount, Paid_Amount, Recognised_Incurred
FROM claims
WHERE Incurred_Amount NOT REGEXP '^[0-9]+(\\.[0-9]+)?$'
   OR Paid_Amount NOT REGEXP '^[0-9]+(\\.[0-9]+)?$'
   OR Recognised_Incurred NOT REGEXP '^[0-9]+(\\.[0-9]+)?$';
   
   -- Convert amounts to numbers
ALTER TABLE claims
  MODIFY Incurred_Amount DECIMAL(12,2),
  MODIFY Paid_Amount DECIMAL(12,2),
  MODIFY Recognised_Incurred DECIMAL(12,2);
  
DESCRIBE claims;
SELECT COUNT(*) FROM claims;

SELECT SUM(Incurred_Amount) AS total_incurred,
SUM(Paid_Amount) AS total_paid,
SUM(Recognised_incurred) AS total_recognised
FROM claims;

-- Number of claims by policy type
SELECT Policy_Type,
COUNT(*) AS claim_count
FROM claims
GROUP BY Policy_Type
ORDER BY claim_count DESC;

-- Number of policies by policy type
SELECT Policy_Type,
COUNT(*) AS policy_count
FROM policies
GROUP BY Policy_type;

-- Claims frequency by policy type
SELECT P.Policy_type,
count(distinct p.Policy_ID) AS policy_count,
count(c.Claim_ID) AS claim_count,
round(count(c.Claim_ID) / count(distinct p.Policy_ID), 3) AS claims_frequency
from policies p
left join claims c
on p.Policy_ID = c.Policy_ID
group by p.Policy_type
order by claims_frequency desc;

-- claims severity by policy type
select Policy_Type,
count(*) AS claim_count,
round(avg(Incurred_Amount), 2) as avg_incurred,
round(avg(case when Claim_Status <> 'Rejected' then Recognised_Incurred end), 2) as avg_recognised_non_rejected,
sum(Paid_Amount) as total_paid,
sum(Recognised_Incurred) as total_recognised
from claims
group by Policy_Type
order by avg_incurred desc;

-- Loss ratio test by policy type (matches Excel: Motor 44%, Property 25%)
SELECT p.Policy_type,
       p.annual_premium_total,
       p.premium_x_exposure,
       c.total_recognised,
       c.total_incurred,
       ROUND(c.total_recognised / p.annual_premium_total * 100, 1) AS lr_recog_annual,
       ROUND(c.total_recognised / p.premium_x_exposure * 100, 1)   AS lr_recog_exposure,
       ROUND(c.total_incurred   / p.annual_premium_total * 100, 1) AS lr_incurred_annual,
       ROUND(c.total_incurred   / p.premium_x_exposure * 100, 1)   AS lr_incurred_exposure
FROM (SELECT Policy_type,
             SUM(Annual_Premium) AS annual_premium_total,
             SUM(Annual_Premium * Exposure_Years) AS premium_x_exposure
      FROM policies
      GROUP BY Policy_type) p
JOIN (SELECT Policy_Type,
             SUM(Incurred_Amount) AS total_incurred,
             SUM(Recognised_Incurred) AS total_recognised
      FROM claims
      GROUP BY Policy_Type) c
  ON p.Policy_type = c.Policy_Type;
  
  -- Day 2: Outstanding = recognised minus paid
  select Policy_Type,
  sum(Recognised_Incurred) AS total_recognised,
  sum(Paid_Amount) as total_paid,
  sum(Recognised_Incurred) - sum(Paid_Amount) as outstanding
  from claims
  group by Policy_Type
  order by outstanding desc;
  
  -- Biggest claims by incurred amount
  select Claim_ID, Policy_ID, Policy_Type, Claim_Status, Incurred_Amount, Paid_Amount
  from claims
  order by Incurred_Amount desc
  limit 10;
  
  -- Checking if any policy has more than one claim
  select Policy_ID,
  count(*) as claim_count,
  sum(Recognised_Incurred) as total_recognised
  from claims
  group by Policy_ID
  having count(*) > 1
  order by claim_count desc;
  
  -- How the claims split by status
  select Claim_Status,
  count(*) as claim_count,
  sum(Recognised_Incurred) as total_recognised,
  sum(Paid_Amount) as total_paid
  from claims
  group by Claim_Status
  order by claim_count desc;

