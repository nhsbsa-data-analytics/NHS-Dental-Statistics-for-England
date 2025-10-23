-------------------------------------------------------------------------
-- DENTAL National Activity Table 4a
-------------------------------------------------------------------------

DROP TABLE dental_national_table4a_2425;

CREATE TABLE dental_national_table4a_2425 AS
WITH
pat_list AS (
SELECT year_month,
       patient_count_n,
       LAST_DAY(TO_DATE(year_month, 'YYYYMM' ))  as year_month_last_day,
       CASE  WHEN age_at_period_end < 18              THEN 'age_child' -- not strictly needed
             WHEN age_at_period_end BETWEEN 18 AND 64 THEN 'age_18_64'
             WHEN age_at_period_end BETWEEN 65 AND 74 THEN 'age_65_74'
             WHEN age_at_period_end BETWEEN 75 AND 84 THEN 'age_75_84'
             WHEN age_at_period_end >= 85             THEN 'age_85_plus'
       END AS age_group
FROM AML.ds_patient_list_24m
WHERE 1=1
AND ons_country  = 'E92000001'
AND age_at_period_end >= 18
--AND year_month BETWEEN 201809 AND 202307  -- for testing only
AND substr(year_month,5,6) IN (03,06,09,12)
),
result_long AS (
SELECT year_month_last_day          as year_month_last_day,
       COALESCE(age_group, 'Total') as age_group, 
       SUM(patient_count_n)         as p_count
FROM pat_list
GROUP BY year_month_last_day, ROLLUP(age_group)
ORDER BY year_month_last_day DESC, age_group
)
SELECT *
FROM result_long
PIVOT ( SUM(p_count) FOR age_group IN      
            ('age_18_64'       as age_18_64,
             'age_65_74'       as age_65_74,
             'age_75_84'       as age_75_84,
             'age_85_plus'     as age_85_plus,
             'Total'          as Total  
            )
       )
ORDER BY year_month_last_day DESC
;  

