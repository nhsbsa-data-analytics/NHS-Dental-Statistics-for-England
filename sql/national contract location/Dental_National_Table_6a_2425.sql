-------------------------------------------------------------------------------------------------------
-- DENTAL National Activity Table 6a
--------------------------------------------------------------------------------------------------------

DROP TABLE dental_national_table6a_2425;

CREATE TABLE dental_national_table6a_2425 AS
WITH 
fact1 AS (
SELECT treatment_year                        as treatment_year,  
       treatment_charge_band_comb       as treatment_charge_band,
       SUM(patient_charge_amount)            as money
FROM OST.DS_CONT_PAT_CHARGE_FACT_2425
WHERE 1=1 
GROUP BY treatment_year, treatment_charge_band_comb
ORDER BY treatment_year DESC
)
SELECT * 
FROM fact1
PIVOT ( SUM(money) FOR treatment_charge_band IN 
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

