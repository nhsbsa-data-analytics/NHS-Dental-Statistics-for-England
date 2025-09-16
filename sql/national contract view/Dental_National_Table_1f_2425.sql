-------------------------------------------------------------------------------------------------------
-- DENTAL National Activity Table 1f
--------------------------------------------------------------------------------------------------------

DROP TABLE dental_national_table1f_2425;

CREATE TABLE dental_national_table1f_2425 AS
WITH 
fact1 AS (
SELECT treatment_year                                         as treatment_year,  
       COALESCE(treatment_charge_band_comb, 'Z - Total' ) as treatment_charge_band,
       COALESCE(exemption_desc, '0 - All')                as exemption_desc,
       SUM(cot)                                           as cot
FROM OST.DS_CONT_ACTIVITY_FACT_2425
WHERE 1=1
AND form_type = 'G'
-- AND uda <> 0
--AND treatment_year BETWEEN '2019/2019' AND '2023/2024'  -- for testing only
AND quarter != 'unallocated_1'                       
AND quarter != 'unallocated_2' -- unallocated quarters shouldn't appear in table, but code kept to catch anything unusual
GROUP BY treatment_year, rollup(treatment_charge_band_comb, exemption_desc)
ORDER BY treatment_year DESC
)
SELECT * 
FROM fact1
PIVOT ( SUM(cot) FOR treatment_charge_band IN 
            ('Band 1'                               as Band_1, 
             'Band 2'                               as Band_2,
             'Band 2a'                              as Band_2a,
             'Band 2b'                              as Band_2b,
             'Band 2c'                              as Band_2c, 
             'Band 3'                               as Band_3,
             'Urgent Treatment'                     as Urgent,
             'Free'                                 as Free,
             'Regulation 11 Replacement Appliance'  as Reg_11_rep_app
             )
       )
ORDER BY treatment_year DESC
;