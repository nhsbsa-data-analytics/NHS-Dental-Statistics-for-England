--------------------------------------------------------------------------------
-- DENTAL Geographical Contract Activity - Table 1b (DCP)
--------------------------------------------------------------------------------

--DROP TABLE dental_geo_cont_table1bi_2425;

CREATE TABLE dental_geo_cont_table1bi_2425 AS 

WITH 

icbs as  (
  select
    distinct
    icb23cdh
    ,icb23cd
    ,icb23nm
  from
    ost.ons_codes_lookup_23
  where 1 = 1
)

,fact1 AS (

  SELECT
    treatment_year,
--    COALESCE(quarter, 'All')                      AS quarter,
    ons.icb23cd                                    as  ons_code,
    fact.commissioner_code                         as  ods_code,
    commissioner_name                              as  icb_name,
    COALESCE(DCP, '0 - All')                      AS DCP,
    COALESCE(DCP_TYPE, '0 - All')                 AS DCP_type,
    COALESCE(treatment_charge_band_comb, 'Z - Total') AS treatment_charge_band,
    SUM(cot)                                      AS cot

  FROM OST.DS_CONT_ACTIVITY_FACT_2425 fact
  left outer join
    icbs ons
    on  fact.commissioner_code = ons.icb23cdh

  WHERE form_type = 'G'

  GROUP BY 
  treatment_year,
  ons.icb23cd,
  fact.commissioner_code,
  GROUPING SETS (
  (commissioner_name, DCP, DCP_TYPE, treatment_charge_band_comb),
  (commissioner_name, DCP, DCP_TYPE),
  (commissioner_name, DCP, treatment_charge_band_comb),
  (commissioner_name, DCP),
  (commissioner_name, DCP_TYPE, treatment_charge_band_comb),
  (commissioner_name, DCP_TYPE),
  (commissioner_name, treatment_charge_band_comb),
  (commissioner_name),

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
and icb_name is not NULL
-- and ods_code not like  'HJ%' -- if wanting to remove H and J commissioners

ORDER BY
  treatment_year DESC,
  ods_code ASC,
  DCP ASC,
  DCP_type ASC;