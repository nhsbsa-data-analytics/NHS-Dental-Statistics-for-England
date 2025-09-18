-------------------------------------------------------------------------
-- DENTAL Geographical Patient Activity - Table 3b
-------------------------------------------------------------------------

DROP TABLE dental_geo_pat_table3b_2425;

-- use patient postcode column to map to ICB
CREATE TABLE dental_geo_pat_table3b_2425 AS 

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

--table fix needed for postcode BT9 6SU in adult 24m patient list
--this postcode is a "large user" address usually associated with an organisation
--region code, LA code, and Ward code are all NULL in NSPL Aug 24 11 census
--but has 'N99999999' code in NSPL ICB column
--remove from "Other" and move to "Unknown"
--also avoids issue where child row (of 21 total children) was being duplicated
--during join

--patient location lookup
,pat_loc as (
  select
    pcds      as pat_pcd
    ,ctry     as pat_ctry
    ,icb      as pat_icb
    ,icb23cdh as pat_icb_cdh
    ,icb23nm  as pat_icb_nm
  from
    ost.ons_nspl_aug_24_11cen  nspl
  where 1 = 1
  and pcds != 'BT9 6SU'
)

,adults as  (
  select
    tdim.treatment_year
    ,pat_loc.pat_ctry     as ctry
    ,pat_loc.pat_icb      as ons_code
    ,pat_loc.pat_icb_cdh  as ods_code
    ,pat_loc.pat_icb_nm   as icb_nm
    ,sum(patient_count_n) as adults
  from
    aml.ds_patient_list_24m fact
  inner join
    tdim
    on  fact.year_month = tdim.year_end
    left join
    pat_loc
    on UPPER(REPLACE(fact.postcode, ' ', '')) = UPPER(REPLACE(pat_loc.pat_pcd, ' ', ''))
where 1 = 1
  and fact.ons_country        =   'E92000001' -- want to still see patients outside England
  and fact.age_at_period_end  >=  18
  group by
    tdim.treatment_year
    ,pat_loc.pat_ctry
    ,pat_loc.pat_icb 
    ,pat_loc.pat_icb_cdh
    ,pat_loc.pat_icb_nm
)

,children as  (
  select
    tdim.treatment_year
    ,pat_loc.pat_ctry     as ctry
    ,pat_loc.pat_icb      as ons_code
    ,pat_loc.pat_icb_cdh  as ods_code
    ,pat_loc.pat_icb_nm   as icb_nm
    ,sum(patient_count_n) as children
  from
    aml.ds_patient_list_12m fact
  inner join
    tdim
    on  fact.year_month = tdim.year_end
  left join
    pat_loc
    on UPPER(REPLACE(fact.postcode, ' ', '')) = UPPER(REPLACE(pat_loc.pat_pcd, ' ', ''))
  where 1 = 1
    and fact.ons_country        =   'E92000001'
    and fact.age_at_period_end  <   18
  group by
    tdim.treatment_year
    ,year_month
    ,pat_loc.pat_ctry
    ,pat_loc.pat_icb
    ,pat_loc.pat_icb_cdh
    ,pat_loc.pat_icb_nm
)

,fact as  (
  select
    a.treatment_year
    ,a.ons_code
    ,a.ods_code
    ,a.icb_nm
    ,a.adults
    ,c.children
  from
    adults  a
  full outer join -- full join instead of inner, to keep null ICB groups where postcode not matched
    children  c
    on  a.treatment_year  = c.treatment_year
    and a.ons_code        = c.ons_code
  where 1 = 1
)

select
  treatment_year  as  "Financial year"
  ,ons_code       as  "ONS code"
  ,ods_code       as  "ODS code"
  ,icb_nm         as  "ICB name"
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
--from DENTAL_GEO_PAT_TABLE3B_2425;

