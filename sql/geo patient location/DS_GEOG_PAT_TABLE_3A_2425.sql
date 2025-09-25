-------------------------------------------------------------------------
-- DENTAL Geographical Patient Activity - Table 3a
-------------------------------------------------------------------------

DROP TABLE dental_geo_pat_table3a_2425;

-- use patient postcode column to map to Region
CREATE TABLE dental_geo_pat_table3a_2425 AS 

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

--,ons as  (
--  select
--    distinct
--    nhser23cdh
--    ,nhser23cd
--    ,nhser23nm
--  from
--    ost.ons_codes_lookup_23
--  where 1 = 1
--)

--,regions  as  (
--  select
--    region_code
--    ,region_description as  region_name
--    ,ons.nhser23cd      as  ons_code
--    ,ons.nhser23nm      as  ons_name
--  from
--    dim.ds_regions_dim reg
--  inner join
--    tdim
--    on  reg.year_month  = tdim.year_end
--  left outer join
--    ons
--    on  reg.region_code = ons.nhser23cdh
--  where 1 = 1
--    and ons_country = 'E92000001'
--)


--patient location lookup
,pat_loc as (
  select
    pcds    as pat_pcd
    ,ctry  as pat_ctry
    ,nhser as pat_region
  from
    ost.ons_nspl_aug_24_11cen  nspl
  where 1 = 1
)

,adults as  (
  select
    tdim.treatment_year
--    ,fact.ons_country
--    ,year_month
--    ,ons.ons_code
--    ,fact.region     as  ods_code
--    ,ons.region_name   
    ,pat_loc.pat_ctry as ctry
    ,pat_loc.pat_region as ons_code
    ,sum(patient_count_n) as  adults
  from
    aml.ds_patient_list_24m fact
  inner join
    tdim
    on  fact.year_month = tdim.year_end
--  inner join
--    regions ons
--    on  fact.region  = ons.region_code
    left outer join
    pat_loc
    on UPPER(REPLACE(fact.postcode, ' ', '')) = UPPER(REPLACE(pat_loc.pat_pcd, ' ', ''))
where 1 = 1
--english contracts only
    and fact.ons_country        =   'E92000001'
  and fact.age_at_period_end  >=  18
  group by
    tdim.treatment_year
--    ,year_month
--     ,ons.ons_code
--    ,fact.region 
--    ,ons.region_name   
    ,pat_loc.pat_ctry
    ,pat_loc.pat_region      
)

,children as  (
  select
    tdim.treatment_year
--    ,fact.ons_country
--    ,year_month
--    ,ons.ons_code
--    ,fact.region     as  ods_code
--    ,ons.region_name   
    ,pat_loc.pat_ctry as ctry
    ,pat_loc.pat_region as ons_code
    ,sum(patient_count_n) as  children
  from
    aml.ds_patient_list_12m fact
  inner join
    tdim
    on  fact.year_month = tdim.year_end
--  inner join
--    regions ons
--    on  fact.region  = ons.region_code
  left outer join
    pat_loc
    on UPPER(REPLACE(fact.postcode, ' ', '')) = UPPER(REPLACE(pat_loc.pat_pcd, ' ', ''))
  where 1 = 1
    and fact.ons_country        =   'E92000001'
    and fact.age_at_period_end  <   18
  group by
    tdim.treatment_year
    ,year_month
    ,pat_loc.pat_ctry
    ,pat_loc.pat_region
)

,fact as  (
  select
    a.treatment_year
    ,a.ons_code
    ,a.adults
    ,c.children
  from
    adults  a
  full outer join -- full join instead of inner, to keep null region groups where postcode not matched
    children  c
    on  a.treatment_year  = c.treatment_year
    and a.ons_code        = c.ons_code
  where 1 = 1
)

select
  treatment_year  as  "Financial year"
  ,ons_code       as  "ONS code"
  ,adults         as  "Adults seen"
  ,children       as  "Children seen"
from
    fact
where 1 = 1
order by
  treatment_year
  ,ons_code
;

--check totals against other geo areas
--select sum("Adults seen") as adults,
--       sum("Children seen") as children
--from DENTAL_GEO_PAT_TABLE3A_2425;