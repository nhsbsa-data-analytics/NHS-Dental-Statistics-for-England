-------------------------------------------------------------------------
-- DENTAL Geographical Patient Activity - Table 1b
-------------------------------------------------------------------------

--DROP TABLE dental_geo_pat_table1b_2425;

CREATE TABLE dental_geo_pat_table1b_2425 AS 

with

--icbs as  (
--  select
--    distinct
--    icb23cdh
--    ,icb23cd
--    ,icb23nm
--  from
--    ost.ons_codes_lookup_23
--  where 1 = 1
--),

fact  as  (
  select
    treatment_year
   --one row where pat_region is NULL but pat_icb is 'N99999999', change icb to NULL where region is NULL
    ,decode(pat_region, NULL, NULL, pat_icb)        as  ons_code
    ,PAT_ICB_CDH                                    as  ods_code
    ,PAT_ICB_NM                                     as  icb_name
    ,coalesce(treatment_charge_band_comb, 'Total')  as  treatment_charge_band_comb
    ,sum(cot)                                       as  cot
  from
    ost.ds_pat_activity_fact_2425 fact
--  left outer join
--    icbs ons
--    on  fact.commissioner_code = ons.icb23cdh
  where 1 = 1
    and treatment_year  = '2024/2025'
    and form_type = 'G'
    and treatment_charge_band_comb  in  (
      'Band 1'
      ,'Band 2'
      ,'Band 2a'
      ,'Band 2b'
      ,'Band 2c'
      ,'Band 3'
      ,'Urgent Treatment'
      ,'Free'
      ,'Regulation 11 Replacement Appliance'
    )
  group by
    treatment_year
    --one row where pat_region is NULL but pat_icb is 'N99999999', change icb to NULL where region is NULL
    ,decode(pat_region, NULL, NULL, pat_icb)                                    
    ,PAT_ICB_CDH
    ,PAT_ICB_NM
    ,rollup(treatment_charge_band_comb)
  order by
    treatment_year
    ,PAT_ICB_CDH
    ,treatment_charge_band_comb
    
)

select 
  treatment_year        as  "Financial year"
  ,ONS_CODE             as  "ONS code"
  ,ODS_CODE          as  "ODS code"
  ,ICB_NAME           as  "ICB name"
  ,"Band 1"
  ,"Band 2"
  ,"Band 2a"
  ,"Band 2b"
  ,"Band 2c"
  ,"Band 3"
  ,"Urgent"
  ,"Free"
  ,"Regulation 11 Replacement Appliance"
  ,"Total"
from 
  fact
pivot(
  sum(cot) for treatment_charge_band_comb  in  (
    'Band 1'                                as  "Band 1"
    ,'Band 2'                               as  "Band 2"
    ,'Band 2a'                              as  "Band 2a"
    ,'Band 2b'                              as  "Band 2b"
    ,'Band 2c'                              as  "Band 2c"
    ,'Band 3'                               as  "Band 3"
    ,'Urgent Treatment'                     as  "Urgent"
    ,'Free'                                 as  "Free"
    ,'Regulation 11 Replacement Appliance'  as  "Regulation 11 Replacement Appliance"
    ,'Total'                                as  "Total"
  )
)
order by
  ODS_CODE
;
