-------------------------------------------------------------------------
-- DENTAL Geographical Patient Activity - Table 4a
-------------------------------------------------------------------------

DROP TABLE dental_geo_pat_table4a_2425;

CREATE TABLE dental_geo_pat_table4a_2425 AS 

with

fact  as  (
  select
    treatment_year
    ,imd_decile                                     as decile
    ,coalesce(treatment_charge_band_comb, 'Total')  as treatment_charge_band_comb
    ,sum(cot)                                       as cot
  from
    ost.ds_pat_activity_fact_2425 fact
  where 1 = 1
 --   and treatment_year = '2024/2025'
    and treatment_year between '2019/2020' and '2024/2025'
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
    ,imd_decile           
    ,rollup(treatment_charge_band_comb)
  order by
    treatment_year
    ,imd_decile  
    ,treatment_charge_band_comb
    
)

select 
  treatment_year   as  "Financial year"
  ,decile    as  "IMD decile"
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
  treatment_year DESC,
  decile
;