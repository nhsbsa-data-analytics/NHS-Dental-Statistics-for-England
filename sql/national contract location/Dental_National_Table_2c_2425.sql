-------------------------------------------------------------------------
-- DENTAL National Activity - Table 2c
-------------------------------------------------------------------------

DROP TABLE dental_national_table2c_2425;

CREATE TABLE dental_national_table2c_2425 AS
WITH
fact1 AS (
SELECT treatment_year                                             as treatment_year,    
       COALESCE(patient_charge_status, '0 - All')                         as charge_status,
       COALESCE(treatment_charge_band_comb, 'Z - Total' )     as treatment_charge_band,
       SUM(UDA)                                                   as uda
FROM OST.DS_CONT_ACTIVITY_FACT_2425
--FROM dental_national_activity_fact_inc_contras -- for comparison with NHSE publication
WHERE 1=1
AND form_type = 'G' 
AND quarter NOT IN ( 'unallocated_1', 'unallocated_2')   -- unallocated quarters shouldn't appear in table, but code kept to catch anything unusual
GROUP BY treatment_year, ROLLUP(treatment_charge_band_comb, patient_charge_status)
ORDER BY treatment_year DESC, treatment_charge_band
)
--SELECT * FROM fact1;
SELECT * FROM fact1
PIVOT ( SUM(UDA) FOR treatment_charge_band IN 
            ('Band 1'           as band_1, 
             'Band 2'           as band_2,
             'Band 2a'          as band_2a,
             'Band 2b'          as band_2b,
             'Band 2c'          as band_2c, 
             'Band 3'           as band_3,
             'Urgent Treatment'                          as urgent,
             'Free'                                      as free,
             'Regulation 11 Replacement Appliance'       as reg_11_rep_app,
              'Z - Total' as Total
            )
       )
ORDER BY treatment_year DESC, charge_status ASC
;  



