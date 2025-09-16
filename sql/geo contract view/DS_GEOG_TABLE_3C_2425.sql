-------------------------------------------------------------------------
-- DENTAL Geographical Contract Activity - Table 3c
-------------------------------------------------------------------------

DROP TABLE dental_geo_cont_table3c_2425;

CREATE TABLE dental_geo_cont_table3c_2425 AS 
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

,la as  (
  select
    year_month
    ,con.contract_number
    ,ons.lad_code
    ,ons.lad_name
  from
    dim.ds_contract_dim con
  inner join
    tdim
    on  con.year_month  = tdim.year_end
  left outer join
    dim.ds_ons_eden_combined_dim ons
    on  con.ppc_address_postcode  = ons.postcode
    and con.ons_country           = ons.country_code
  where 1 = 1
    and con.ons_country = 'E92000001'
)

,adults as  (
  select
    tdim.treatment_year
    ,fact.year_month
    ,ons.lad_code         as  ons_code
    ,ons.lad_name   
    ,sum(patient_count_n) as  adults
  from
    aml.ds_patient_list_24m fact
  inner join
    tdim
    on  fact.year_month = tdim.year_end
  inner join
    la ons
    on  fact.contract_number  = ons.contract_number
    and fact.year_month       = ons.year_month
  where 1 = 1
    and fact.ons_country        =   'E92000001'
    and fact.age_at_period_end  >=  18
  group by
    tdim.treatment_year
    ,fact.year_month
    ,ons.lad_code  
    ,ons.lad_name      
)

,children as  (
    select
    tdim.treatment_year
    ,fact.year_month
    ,ons.lad_code         as  ons_code
    ,ons.lad_name   
    ,sum(patient_count_n) as  children
  from
    aml.ds_patient_list_12m fact
  inner join
    tdim
    on  fact.year_month = tdim.year_end
  inner join
    la ons
    on  fact.contract_number  = ons.contract_number
    and fact.year_month       = ons.year_month
  where 1 = 1
    and fact.ons_country        =   'E92000001'
    and fact.age_at_period_end  <   18
  group by
    tdim.treatment_year
    ,fact.year_month
    ,ons.lad_code  
    ,ons.lad_name      
)

,fact as  (
  select
    a.treatment_year
    ,a.ons_code
    ,a.lad_name
    ,a.adults
    ,c.children
  from
    adults  a
  inner join 
    children  c
    on  a.treatment_year  = c.treatment_year
    and a.ons_code        = c.ons_code
  where 1 = 1
)

select
  treatment_year  as  "Financial year"
  ,ons_code       as  "ONS code"
  ,lad_name       as  "Local Authority name"
  ,adults         as  "Adults seen"
  ,children       as  "Children seen"
from
    fact
where 1 = 1
order by
  treatment_year
  ,ons_code
;
