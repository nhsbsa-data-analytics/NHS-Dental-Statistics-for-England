-------------------------------------------------------------------------
-- DENTAL Geographical Contract Activity - Table 3a
-------------------------------------------------------------------------

DROP TABLE dental_geo_cont_table3a_2425;

CREATE TABLE dental_geo_cont_table3a_2425 AS 

with

tdim  as  (
  select
    treatment_year
    ,min(year_month)    as  period_start
    ,max(year_month)    as  period_end
    ,max(target_month)  as  year_end
  from 
    dim.ds_year_end_reporting_period
  where 1 = 1
    and treatment_year  = '2024/2025'
  group by
    treatment_year
)

,ons as  (
  select
    distinct
    nhser23cdh
    ,nhser23cd
    ,nhser23nm
  from
    ost.ons_codes_lookup_23
  where 1 = 1
)

,regions  as  (
  select
    region_code
    ,region_description as  region_name
    ,ons.nhser23cd      as  ons_code
    ,ons.nhser23nm      as  ons_name
  from
    dim.ds_regions_dim reg
  inner join
    tdim
    on  reg.year_month  = tdim.year_end
  left outer join
    ons
    on  reg.region_code = ons.nhser23cdh
  where 1 = 1
    and ons_country = 'E92000001'
)

--select * from regions;

,adults as  (
  select
    tdim.treatment_year
    ,year_month
    ,ons.ons_code
    ,fact.region     as  ods_code
    ,ons.region_name   
    ,sum(patient_count_n) as  adults
  from
    aml.ds_patient_list_24m fact
  inner join
    tdim
    on  fact.year_month = tdim.year_end
  inner join
    regions ons
    on  fact.region  = ons.region_code
  where 1 = 1
    and fact.ons_country        =   'E92000001'
    and fact.age_at_period_end  >=  18
  group by
    tdim.treatment_year
    ,year_month
    ,ons.ons_code
    ,fact.region    
    ,ons.region_name      
)

,children as  (
  select
    tdim.treatment_year
    ,year_month
    ,ons.ons_code
    ,fact.region     as  ods_code
    ,ons.region_name   
    ,sum(patient_count_n) as  children
  from
    aml.ds_patient_list_12m fact
  inner join
    tdim
    on  fact.year_month = tdim.year_end
  inner join
    regions ons
    on  fact.region  = ons.region_code
  where 1 = 1
    and fact.ons_country        =   'E92000001'
    and fact.age_at_period_end  <   18
  group by
    tdim.treatment_year
    ,year_month
    ,ons.ons_code
    ,fact.region    
    ,ons.region_name
)

,fact as  (
  select
    a.treatment_year
    ,a.ons_code
    ,a.ods_code
    ,a.region_name
    ,a.adults
    ,c.children
  from
    adults  a
  inner join 
    children  c
    on  a.treatment_year  = c.treatment_year
    and a.ods_code        = c.ods_code
  where 1 = 1
)

select
  treatment_year  as  "Financial year"
  ,ons_code       as  "ONS code"
  ,ods_code       as  "ODS code"
  ,region_name    as  "Region name"
  ,adults         as  "Adults seen"
  ,children       as  "Children seen"
from
    fact
where 1 = 1
order by
  treatment_year
  ,ods_code
;
