-------------------------------------------------------------------------
-- DENTAL Geographical Contract Activity - Table 1a
-------------------------------------------------------------------------

DROP TABLE dental_geo_cont_table1a_2425;

CREATE TABLE dental_geo_cont_table1a_2425 AS 

with

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

,fact  as  (
  select
    treatment_year
    ,ons.nhser23cd                                  as  ons_code
    ,fact.region_code                                    as  ods_code
    ,region_name
    ,coalesce(treatment_charge_band_comb, 'Total')  as  treatment_charge_band_comb
    ,sum(cot)                                       as  cot
  from
    ost.ds_cont_activity_fact_2425 fact
  left outer join
    regions ons
    on  fact.region_code = ons.nhser23cdh
  where 1 = 1
 --   and treatment_year  between '2019/2020' and '2024/2025'
    and treatment_year = '2024/2025'
    and form_type = 'G'
    AND quarter != 'unallocated_1' -- unallocated quarters shouldn't appear in table, but code kept to catch anything unusual
    AND quarter != 'unallocated_2'
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
    ,ons.nhser23cd                                    
    ,region_name             
    ,fact.region_code
    ,rollup(treatment_charge_band_comb)
  order by
    treatment_year
    ,region_code
    ,treatment_charge_band_comb
    
)

select 
  treatment_year  as  "Financial year"
  ,ons_code       as  "ONS code"
  ,ods_code       as  "ODS code"
  ,region_name    as  "Region name"
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
  ods_code
;
