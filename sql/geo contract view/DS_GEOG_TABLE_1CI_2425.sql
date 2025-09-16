-------------------------------------------------------------------------
-- DENTAL Geographical Contract Activity - Table 1ci (DCP)
-------------------------------------------------------------------------

--DROP TABLE dental_geo_cont_table1ci_2425;

CREATE TABLE dental_geo_cont_table1ci_2425 AS 

WITH 

fact1 AS (

  SELECT
    treatment_year,
--    COALESCE(quarter, 'All')                      AS quarter,
    lad_code                                       as  ons_code,
    lad_name,    
    COALESCE(DCP, '0 - All')                      AS DCP,
    COALESCE(DCP_TYPE, '0 - All')                 AS DCP_type,
    COALESCE(treatment_charge_band_comb, 'Z - Total') AS treatment_charge_band,
    SUM(cot)                                      AS cot

  FROM OST.DS_CONT_ACTIVITY_FACT_2425 fact

  WHERE form_type = 'G'
--  AND treatment_year = '2024/25'

  GROUP BY 
  treatment_year,
  lad_code,
  lad_name,
  GROUPING SETS (
  (lad_name, DCP, DCP_TYPE, treatment_charge_band_comb),
  (lad_name, DCP, DCP_TYPE),
  (lad_name, DCP, treatment_charge_band_comb),
  (lad_name, DCP),
  (lad_name, DCP_TYPE, treatment_charge_band_comb),
  (lad_name, DCP_TYPE),
  (lad_name, treatment_charge_band_comb),
  (lad_name),

  (DCP, DCP_TYPE, treatment_charge_band_comb),
  (DCP, DCP_TYPE),
  (DCP, treatment_charge_band_comb),
  (DCP),

  (DCP_TYPE, treatment_charge_band_comb),
  (DCP_TYPE),

  (treatment_charge_band_comb),
  ()  -- grand total

  )

)

SELECT *
FROM fact1
PIVOT (
  SUM(cot) FOR treatment_charge_band IN (
    'Band 1'                            AS band_1,
    'Band 2'                            AS band_2,
    'Band 2a'                           AS band_2a,
    'Band 2b'                           AS band_2b,
    'Band 2c'                           AS band_2c,
    'Band 3'                            AS band_3,
    'Urgent Treatment'                 AS urgent,
    'Free'                             AS free,
    'Regulation 11 Replacement Appliance' AS reg_11_rep_app,
    'Z - Total'                         AS total
  )
)
where 1=1 
and lad_name is not NULL

ORDER BY
  treatment_year DESC,
  ons_code ASC,
  DCP ASC,
  DCP_type ASC;