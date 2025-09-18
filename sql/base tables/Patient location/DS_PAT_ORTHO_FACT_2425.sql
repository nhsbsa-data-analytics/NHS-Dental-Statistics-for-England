--note from 2023/24 table construction: some differences with previous NHSE data
-- most likely to do with submission periods for covid and legacy issues with older data

--PERFORMER_NUMBER column and DCP columns not (yet) added, unlike main 2425 activity fact
-- as ortho activity less relevant to DCP hygienist and therapist roles

--drop table ds_pat_ortho_fact_2425 purge;

create table  ds_pat_ortho_fact_2425  compress for  query high  as

with

/* identify contra records */
lkp_contra as (
  select
    form_id
    ,count(form_id)   as  form_id_count
    ,sum(form_count)  as  form_count_sum
  from
    aml.ds_form_visit_fact  fact
  where 1 = 1
  group by
    form_id
)

/* create lookup to remove form ids with contra entries 
  don't know if UOA has contras but want to be consistent*/
,lc as  (
  select  /*+ materialize */
    form_id
  from
    lkp_contra
  where 1 = 1
    /* find forms that have more than one entry and also remove contras that 
    don't have corresponding original form */
    and form_id_count   >=  2
    and form_count_sum  <=  0
)

,tdim as  (
  select
    treatment_year
    ,min(year_month)  as  period_start
    ,max(year_month)  as  period_end
  from
    dim.ds_year_end_reporting_period
  where 1 = 1
    and treatment_year  between '2019/2020' and '2024/2025'
  group by
    treatment_year
)

--patient location lookup
,pat_loc as (
  select
    pcd
    ,ctry
    ,laua
    ,ward
    ,nhser as pat_region
    ,icb as pat_icb
    ,lsoa11 as pat_lsoa11
    ,icb23cdh as pat_icb_cdh
    ,icb23nm as pat_icb_nm
    ,imd_decile
    ,imd_rank
  from
    ost.ons_nspl_aug_24_11cen  nspl
  where 1 = 1
)

,fact as  (
  select
    fact.treatment_year
    ,fact.year_month
    ,fact.postcode -- patient postcode
    ,p.ctry
    ,p.laua
    ,p.ward
    ,p.pat_region
    ,p.pat_icb
    ,p.pat_lsoa11
    ,p.pat_icb_cdh
    ,p.pat_icb_nm
    ,p.imd_decile
    ,p.imd_rank
    ,con.ppc_loc_id
    ,con.ppc_location_v_code
    ,fact.contract_number
    ,substr(to_char(con.contract_number), 1, 6) || '/' || substr(to_char(con.contract_number), 7, 4) as formatted_contract_number
    ,con.provider_name
    ,con.ppc_address_postcode
    ,con.commissioner_code
    ,con.commissioner_name
    ,con.region             as  region_code
    ,reg.region_description as  region_name
    ,ons.lad_code
    ,ons.lad_name
    ,sum(uoa) as  uoa
  from
    aml.ds_form_visit_fact  fact
  left outer join
    lc
    on  fact.form_id  = lc.form_id
  inner join
    tdim
    on  fact.treatment_year = tdim.treatment_year
  inner join
    dim.ds_contract_dim     con
    on  fact.contract_number  = con.contract_number
    and fact.ons_country      = con.ons_country
    and tdim.period_end       = con.year_month
  inner join
    dim.ds_regions_dim  reg
    on  con.region      =  reg.region_code
    and con.ons_country = reg.ons_country
    and con.year_month  = reg.year_month
  left outer join
    dim.ds_ons_eden_combined_dim  ons
    on  con.ppc_address_postcode  = ons.postcode
    and fact.ons_country          = ons.country_code
  left join 
    pat_loc p
    on UPPER(REPLACE(fact.postcode, ' ', '')) = UPPER(REPLACE(p.pcd, ' ', ''))
  where 1 = 1
    and fact.ons_country  =   'E92000001'
    and lc.form_id        is  null
    and fact.year_month between tdim.period_start and tdim.period_end
  group by
    fact.treatment_year
    ,fact.year_month
    ,fact.postcode -- patient postcode
    ,p.ctry
    ,p.laua
    ,p.ward
    ,p.pat_region
    ,p.pat_icb
    ,p.pat_lsoa11
    ,p.pat_icb_cdh
    ,p.pat_icb_nm
    ,p.imd_decile
    ,p.imd_rank
    ,con.ppc_loc_id
    ,con.ppc_location_v_code
    ,fact.contract_number
    ,substr(to_char(con.contract_number), 1, 6) || '/' || substr(to_char(con.contract_number), 7, 4)
    ,con.provider_name
    ,con.ppc_address_postcode
    ,con.commissioner_code
    ,con.commissioner_name
    ,con.region             
    ,reg.region_description 
    ,ons.lad_code
    ,ons.lad_name     
)

select
  *
from
  fact
where 1 = 1
order by
  year_month
  ,contract_number
;
