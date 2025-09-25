-------------------------------------------------------------------------------------------------------
-- DENTAL National Activity Table 6c
--------------------------------------------------------------------------------------------------------

DROP TABLE dental_national_table6c_2425;

CREATE TABLE dental_national_table6c_2425 AS
WITH 
fact1 AS (
SELECT treatment_year                        as treatment_year,  
       treatment_charge_band_comb       as treatment_charge_band,
       COALESCE(exemption_desc, '0 - All') as exemption_desc,
       SUM(PATIENT_CHARGE_AMOUNT_CALC)            as money
FROM OST.DS_CONT_PAT_CHARGE_FACT_2425
WHERE 1=1 
AND patient_charge_status != 'Non-Exempt'
GROUP BY treatment_year, rollup(treatment_charge_band_comb, exemption_desc)
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

