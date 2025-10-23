-------------------------------------------------------------------------
-- DENTAL National Activity - Table 1a
-------------------------------------------------------------------------

DROP TABLE dental_national_table1a_2425;

CREATE TABLE dental_national_table1a_2425 AS 
WITH
fact1 AS (  
SELECT treatment_year,    
       COALESCE(quarter, 'All')                                    as quarter,
       COALESCE(treatment_charge_band_comb, 'Z - Total' )      as treatment_charge_band,
       sum(cot)                                              as cot
FROM OST.DS_CONT_ACTIVITY_FACT_2425
WHERE 1=1
AND form_type = 'G'
-- AND uda <> 0
--AND treatment_year BETWEEN '2019/2019' AND '2023/2024'  -- for testing historical data only
AND quarter != 'unallocated_1'                        -- *may need to explore further how/why these apply to COTs*
AND quarter != 'unallocated_2'
GROUP BY treatment_year, ROLLUP(treatment_charge_band_comb, quarter)
ORDER BY treatment_year DESC, quarter ASC, treatment_charge_band
)
--SELECT * FROM fact1;
SELECT * 
FROM fact1
PIVOT ( SUM(cot) FOR treatment_charge_band IN 
            ('Band 1'           as band_1, 
             'Band 2'           as band_2,
             'Band 2a'          as band_2a,
             'Band 2b'          as band_2b,
             'Band 2c'          as band_2c, 
             'Band 3'           as band_3,
             'Urgent Treatment'                      as urgent,
             'Free'                                  as free,
             'Regulation 11 Replacement Appliance'   as reg_11_rep_app,
              'Z - Total'                            as Total
            )
        )    
ORDER BY treatment_year DESC, quarter ASC
; 
 

