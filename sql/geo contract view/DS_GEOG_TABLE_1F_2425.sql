-------------------------------------------------------------------------
-- DENTAL Geographical Contract Activity - Table 1f
-------------------------------------------------------------------------

DROP TABLE dental_geo_cont_table1f_2425;

CREATE TABLE dental_geo_cont_table1f_2425 AS 

with

fact  as  (
  select
    treatment_year
    ,lad_code                                       as  ons_code
    ,lad_name                                       
    ,coalesce(treatment_charge_band_comb, 'Total')  as  treatment_charge_band_comb
    ,sum(cot)                                       as  cot
  from
    ost.ds_cont_activity_fact_2425 fact
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
    ,lad_code
    ,lad_name
    ,rollup(treatment_charge_band_comb)
  order by
    treatment_year
    ,lad_code
    ,treatment_charge_band_comb
    
)

select 
  treatment_year  as  "Financial year"
  ,ons_code       as  "ONS code"
  ,lad_name       as  "Local Authority name"
  ,"Band 1"/"Total" * 100 as  "Band 1"
  ,"Band 2"/"Total" * 100 as  "Band 2"
  ,"Band 2a"/"Total" * 100 as "Band 2a"
  ,"Band 2b"/"Total" * 100 as  "Band 2b"
  ,"Band 2c"/"Total" * 100 as  "Band 2c"
  ,"Band 3"/"Total" * 100 as  "Band 3"
  ,"Urgent"/"Total" * 100 as  "Urgent"
  ,"Free"/"Total" * 100 as  "Free"
  ,"Regulation 11 Replacement Appliance"/"Total" * 100 as  "Regulation 11 Replacement Appliance"
  ,"Total"/"Total" * 100 as  "Total"
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
  ons_code
;
