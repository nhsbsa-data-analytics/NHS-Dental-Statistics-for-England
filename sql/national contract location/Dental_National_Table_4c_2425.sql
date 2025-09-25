-------------------------------------------------------------------------
-- DENTAL National Activity Table 4c
-------------------------------------------------------------------------

DROP TABLE dental_national_table4c_2425;

CREATE TABLE dental_national_table4c_2425 AS
WITH
pat_list AS (
SELECT year_month,
       patient_count_n,
       LAST_DAY(TO_DATE(year_month, 'YYYYMM' ))  as year_month_last_day,
       CASE  WHEN age_at_period_end BETWEEN  0 AND  4 THEN 'age_0_4'
             WHEN age_at_period_end BETWEEN  5 AND  9 THEN 'age_5_9'
             WHEN age_at_period_end BETWEEN 10 AND 14 THEN 'age_10_14'
             WHEN age_at_period_end BETWEEN 15 AND 17 THEN 'age_15_17'
             WHEN age_at_period_end >= 18             THEN 'age_18_plus' -- not strictly needed
       END AS age_group
FROM AML.ds_patient_list_12m
WHERE 1=1
AND ons_country  = 'E92000001'
AND age_at_period_end < 18
--AND year_month BETWEEN 201809 AND 202407   ---  for testing only
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
PIVOT ( SUM(p_count) FOR age_group IN      ---  SUM is used here only because pivot requires an aggregate function.  It can be used here becuase there is only one value summed over.
            ('age_0_4'      as age_0_4,
             'age_5_9'      as age_5_9,
             'age_10_14'    as age_10_14,
             'age_15_17'    as age_15_17,
             'Total'        as Total  
            )
       )
ORDER BY year_month_last_day DESC
;

