-------------------------------------------------------------------------
-- DENTAL National Activity - Table 2g
-------------------------------------------------------------------------

--script to create new table of DCP UDAs by DCP led/DCP assist/Non DCP, and by DCP type

DROP TABLE dental_national_table2g_2425;

CREATE TABLE dental_national_table2g_2425 AS

WITH fact1 AS (

  SELECT
    treatment_year,
    COALESCE(quarter, 'All')                      AS quarter,
    COALESCE(DCP, '0 - All')                      AS DCP,
    COALESCE(DCP_TYPE, '0 - All')                 AS DCP_type,
    COALESCE(treatment_charge_band_comb, 'Z - Total') AS treatment_charge_band,
    SUM(uda)                                      AS uda

  FROM OST.DS_CONT_ACTIVITY_FACT_2425

  WHERE form_type = 'G'

  GROUP BY 
  treatment_year,
  GROUPING SETS (
  (quarter, DCP, DCP_TYPE, treatment_charge_band_comb),
  (quarter, DCP, DCP_TYPE),
  (quarter, DCP, treatment_charge_band_comb),
  (quarter, DCP),
  (quarter, DCP_TYPE, treatment_charge_band_comb),
  (quarter, DCP_TYPE),
  (quarter, treatment_charge_band_comb),
  (quarter),

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
  SUM(uda) FOR treatment_charge_band IN (
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

ORDER BY
  treatment_year DESC,
  quarter ASC,
  DCP ASC,
  DCP_type ASC;
