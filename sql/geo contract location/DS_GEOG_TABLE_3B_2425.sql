-------------------------------------------------------------------------
-- DENTAL Geographical Contract Activity - Table 3b
-------------------------------------------------------------------------

--changed join on line 51 from inner to left join, to avoid dropping H and J's with no children

DROP TABLE dental_geo_cont_table3b_2425;

CREATE TABLE dental_geo_cont_table3b_2425 AS 


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
    icb23cdh
    ,icb23cd
    ,icb23nm
  from
    ost.ons_codes_lookup_23
  where 1 = 1
)
--select * from dim.ds_commissioners_dim;
,icbs  as  (
  select
    commissioner_code   as  icb_code
    ,commissioner_name  as  icb_name
    ,commissioner_type
    ,ons.icb23cd        as  ons_code
    ,ons.icb23nm        as  ons_name
  from
    dim.ds_commissioners_dim icb
  inner join
    tdim
    on  icb.year_month  = tdim.year_end
  left outer join
    ons
    on  icb.commissioner_code = ons.icb23cdh
  where 1 = 1
    and ons_country = 'E92000001'
)

,adults as  (
  select
    tdim.treatment_year
    ,year_month
    ,ons.ons_code
    ,fact.commissioner_code     as  ods_code
    ,ons.icb_name   
    ,sum(patient_count_n) as  adults
  from
    aml.ds_patient_list_24m fact
  inner join
    tdim
    on  fact.year_month = tdim.year_end
  inner join
    icbs ons
    on  fact.commissioner_code  = ons.icb_code
  where 1 = 1
    and fact.ons_country        =   'E92000001'
    and fact.age_at_period_end  >=  18
  group by
    tdim.treatment_year
    ,year_month
    ,ons.ons_code
    ,fact.commissioner_code    
    ,ons.icb_name      
)

,children as  (
  select
    tdim.treatment_year
    ,year_month
    ,ons.ons_code
    ,fact.commissioner_code     as  ods_code
    ,ons.icb_name   
    ,sum(patient_count_n) as  children
  from
    aml.ds_patient_list_12m fact
  inner join
    tdim
    on  fact.year_month = tdim.year_end
  inner join
    icbs ons
    on  fact.commissioner_code  = ons.icb_code
  where 1 = 1
    and fact.ons_country        =   'E92000001'
    and fact.age_at_period_end  <   18
  group by
    tdim.treatment_year
    ,year_month
    ,ons.ons_code
    ,fact.commissioner_code    
    ,ons.icb_name
)

,fact as  (
  select
    a.treatment_year
    ,a.ons_code
    ,a.ods_code
    ,a.icb_name
    ,a.adults
    ,c.children
  from
    adults  a
  left join 
    children  c
    on  a.treatment_year  = c.treatment_year
    and a.ods_code        = c.ods_code
  where 1 = 1
)

select
  treatment_year  as  "Financial year"
  ,ons_code       as  "ONS code"
  ,ods_code       as  "ODS code"
  ,icb_name       as  "ICB name"
  ,adults         as  "Adults seen"
  ,children       as  "Children seen"
from
    fact
where 1 = 1
order by
  treatment_year
  ,icb_name
;
