-------------------------------------------------------------------------
-- DENTAL Geographical Patient Activity - Table 1d 
-------------------------------------------------------------------------

DROP TABLE dental_geo_pat_table1d_2425;

CREATE TABLE dental_geo_pat_table1d_2425 AS 

with

fact  as  (
  select
    treatment_year
    ,ward                                      as  ons_code
    ,coalesce(treatment_charge_band_comb, 'Total')  as  treatment_charge_band_comb
    ,sum(cot)                                       as  cot
  from
    ost.ds_pat_activity_fact_2425 fact
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
    ,ward
    ,rollup(treatment_charge_band_comb)
  order by
    treatment_year
    ,ward
    ,treatment_charge_band_comb
    
)

select 
  treatment_year  as  "Financial year"
  ,ons_code       as  "ONS code"
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
  ons_code
;

select count(distinct "ONS code") from dental_geo_pat_table1d_2425
where 1=1
and "ONS code" like 'E%';