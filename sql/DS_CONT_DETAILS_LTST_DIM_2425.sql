-- script to get latest dental contractor details for use in contract-location activity fact table build
-- latest details needed to get Health and Justice (H&J) commissioners

--drop table ds_cont_details_ltst_dim_2425 cascade constraints purge;

create table  ds_cont_details_ltst_dim_2425  compress for  query high  as

with

tdim  as  (
  select  
    treatment_year
    ,min(year_month)    as  period_start
    ,max(year_month)    as  period_end
    ,min(target_month)  as  year_start
    ,max(target_month)  as  year_end
  from
    dim.ds_year_end_reporting_period
  where 1 = 1
    and treatment_year  between '2019/2020' and '2024/2025'
  group by
    treatment_year
)

,ons_com  as  (
    select
    distinct
    icb23cdh
    ,icb23cd
    ,icb23nm
  from
    ost.ons_codes_lookup_23
  where 1 = 1
)

,ons_reg  as  (
    select
    distinct
    nhser23cdh
    ,nhser23cd
    ,nhser23nm
  from
    ost.ons_codes_lookup_23
  where 1 = 1
)

,m_con as  (
  select
    contract_number
    ,max(year_month)  as  m_ym
  from
    dim.ds_contract_dim
  where 1 = 1
    and year_month  <= (select max(year_end) from  tdim)
    and ons_country = 'E92000001'
  group by
    contract_number
)

--select count(*) from m_con; --23,360

,ltst_con as  (
  select
    m_ym                    as  ltst_ym
    ,con.contract_number
    ,substr(to_char(con.contract_number), 1, 6) || '/' || substr(to_char(con.contract_number), 7, 4) as formatted_contract_number
    ,provider_name
    ,commissioner_code      
    ,region                 as  region_code
    ,ppc_address_postcode
    ,ppc_location_v_code
    ,ppc_loc_id
  from
    dim.ds_contract_dim con
  inner join
    m_con m
    on  con.contract_number = m.contract_number
    and con.year_month      = m.m_ym
  
)

--select count(*) from ltst_con; --

,org  as  (
  select
    ltst_ym
    ,contract_number
    ,formatted_contract_number
    ,provider_name
    ,ppc_address_postcode
    ,ppc_location_v_code
    ,ppc_loc_id
    ,con.commissioner_code
    ,ons_com.icb23cd            as  icb_code_ons
    ,com.commissioner_name
    ,con.region_code
    ,ons_reg.nhser23cd          as  region_code_ons
    ,reg.region_description     as  region_name
    ,la.lad_code
    ,la.lad_name
  from
    ltst_con  con
  inner join
    dim.ds_commissioners_dim  com
    on  con.commissioner_code = com.commissioner_code
    and com.year_month  = (select max(year_end) from  tdim)
  inner join
    dim.ds_regions_dim        reg
    on  con.region_code = reg.region_code
    and reg.year_month  = (select max(year_end) from  tdim)
  left outer join
    dim.ds_ons_eden_combined_dim  la
    on  con.ppc_address_postcode  = la.postcode
  left outer join
    ons_com
    on  con.commissioner_code = ons_com.icb23cdh
  left outer join
    ons_reg
    on  con.region_code = nhser23cdh
  
)
--select count(*) from org; -- (should match count from line 79)

select * from org
;

--grant access to other members of statistics team, if required
