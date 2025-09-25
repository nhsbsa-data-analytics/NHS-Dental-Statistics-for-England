-------------------------------------------------------------------------
-- DENTAL Geographical Contract Activity - Table 1ai (DCP)
-------------------------------------------------------------------------

--current approach works but creates a duplicate null row for each region
--which is currently removed at end 
--but query should be amended to avoid creating null region

--DROP TABLE dental_geo_cont_table1ai_2425;

CREATE TABLE dental_geo_cont_table1ai_2425 AS 

WITH 

regions as  (
  select
    distinct
    nhser23cdh
    ,nhser23cd
    ,nhser23nm
  from
    ost.ons_codes_lookup_23
  where 1 = 1
)

,fact1 AS (

  SELECT
    treatment_year,
--    COALESCE(quarter, 'All')                      AS quarter,
    ons.nhser23cd                                  as  ons_code,
    fact.region_code                                    as  ods_code,
    region_name,
    COALESCE(DCP, '0 - All')                      AS DCP,
    COALESCE(DCP_TYPE, '0 - All')                 AS DCP_type,
    COALESCE(treatment_charge_band_comb, 'Z - Total') AS treatment_charge_band,
    SUM(cot)                                      AS cot

  FROM OST.DS_CONT_ACTIVITY_FACT_2425 fact
  left outer join
    regions ons
    on  fact.region_code = ons.nhser23cdh

  WHERE form_type = 'G'

  GROUP BY 
  treatment_year,
  ons.nhser23cd,
  fact.region_code,
  GROUPING SETS (
  (region_name, DCP, DCP_TYPE, treatment_charge_band_comb),
  (region_name, DCP, DCP_TYPE),
  (region_name, DCP, treatment_charge_band_comb),
  (region_name, DCP),
  (region_name, DCP_TYPE, treatment_charge_band_comb),
  (region_name, DCP_TYPE),
  (region_name, treatment_charge_band_comb),
  (region_name),

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
where 1=1 and region_name is not NULL

ORDER BY
  treatment_year DESC,
  ods_code ASC,
  DCP ASC,
  DCP_type ASC;