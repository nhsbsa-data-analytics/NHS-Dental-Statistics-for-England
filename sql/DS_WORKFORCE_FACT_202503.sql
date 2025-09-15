--Script to build activity fact table joined to performer details
--for use in dental workforce tables

--this script is different to ds_workforce_fact_2425
--as limits perf dim lookup to 202503 as latest month
--when getting latest commissioner code associated with a contract

--drop table ds_workforce_fact_202503 cascade constraints purge;

create table ds_workforce_fact_202503 compress for query high as
with

tdim as (
  select
    treatment_year
    ,year_month
    ,target_month
  from
    dim.ds_year_end_reporting_period
  where 1 = 1
    and treatment_year  between '2019/2020' and '2024/2025'
)

,pend as (
  select
    yend.treatment_year
    ,max(yend.target_month)  as  year_end
    ,max(yend.year_month)    as  period_end
  from
    dim.ds_year_end_reporting_period yend
  inner join
    tdim
    on  yend.treatment_year  =  tdim.treatment_year
    and yend.year_month      =  tdim.year_month
  group by
    yend.treatment_year
)

--select * from pend;

,perf as  (
  select
    pend.treatment_year
    ,performer_number
    ,title
    ,substr(forename, 1, 1) as  first_init
    ,surname
    ,date_of_birth
    ,gender
    ,ni_number
    ,gdc_number
    ,foundation_dentist
  from
    dim.ds_performer_dim  pfm
  inner join
    pend
    on  pfm.year_month  = pend.year_end
)

--map 2019/20 to 2023/24 data to latest contract details as of 202403
--so area codes etc can be mapped to ICB and H&J
,cont_1 as (
  select
    year_month
    ,contract_number
    ,commissioner_code
    ,commissioner_name
    ,last_value(commissioner_code) over(partition by contract_number order by year_month ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as ltst_comm_code
    ,last_value(commissioner_name) over(partition by contract_number order by year_month ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as ltst_comm_name
    ,ons_country
    ,provider_number
    ,contract_type
    ,paid_by_bsa
    ,ppc_address_postcode
  from 
    dim.ds_contract_dim
    where year_month <= 202403
)

--map 2024/25 data to latest contract details as of 202503
,cont_2 as (
  select
    year_month
    ,contract_number
    ,commissioner_code
    ,commissioner_name
    ,last_value(commissioner_code) over(partition by contract_number order by year_month ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as ltst_comm_code
    ,last_value(commissioner_name) over(partition by contract_number order by year_month ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as ltst_comm_name
    ,ons_country
    ,provider_number
    ,contract_type
    ,paid_by_bsa
    ,ppc_address_postcode
  from 
    dim.ds_contract_dim
    where year_month <= 202503
)

--select * from perf;

,fact_1 as  (
  select
    fact.treatment_year
    ,perf.performer_number
    ,perf.title
    ,perf.first_init
    ,perf.surname
    ,perf.gender
    ,perf.date_of_birth
    ,perf.ni_number
    ,perf.gdc_number
    ,perf.foundation_dentist
    ,case when cpd.fd_tenure = 1 then 'Y' end as fd
    ,cont_1.commissioner_code
    ,cont_1.ltst_comm_code
    ,cont_1.ltst_comm_name
    ,cont_1.ons_country
    ,cont_1.provider_number
    ,cont_1.contract_number
    ,cont_1.contract_type
    ,cont_1.paid_by_bsa
    ,cont_1.ppc_address_postcode
    ,ons.ccg_code
    ,sum(fact.uda)  as  uda
    ,sum(fact.uoa)  as  uoa    
  from
    aml.ds_form_visit_fact  fact
  inner join
    tdim
    on  fact.treatment_year = tdim.treatment_year
    and fact.year_month     = tdim.year_month
  inner join
    perf
    on  fact.performer_number = perf.performer_number
    and fact.treatment_year   = perf.treatment_year
  -- inner join
  --   dim.ds_contract_dim cont
  --   on  fact.contract_number  = cont.contract_number
  --   and fact.year_month       = cont.year_month
  inner join
    cont_1 
  on  fact.contract_number  = cont_1.contract_number
  and fact.year_month       = cont_1.year_month
  inner join
    dim.ds_cont_perf_dim  cpd
    on  fact.performer_tenure_id  = cpd.performer_tenure_id
    and fact.year_month           = cpd.year_month
  left outer join
    dim.ds_ons_eden_combined_dim ons
    on  cont_1.ppc_address_postcode = ons.postcode 
  where 1 = 1
    and fact.ons_country  in  ('E92000001', 'W92000004')
    and fact.treatment_year between '2019/2020' and '2023/2024'
  group by
    fact.treatment_year
    ,perf.performer_number
    ,perf.title
    ,perf.first_init
    ,perf.surname
    ,perf.gender
    ,perf.date_of_birth
    ,perf.ni_number
    ,perf.gdc_number
    ,perf.foundation_dentist
    ,case when cpd.fd_tenure = 1 then 'Y' end
    ,cont_1.commissioner_code
    ,cont_1.ltst_comm_code
    ,cont_1.ltst_comm_name
    ,cont_1.ons_country
    ,cont_1.provider_number
    ,cont_1.contract_number
    ,cont_1.contract_type
    ,cont_1.paid_by_bsa
    ,cont_1.ppc_address_postcode
    ,ons.ccg_code
)

,fact_2 as  (
  select
    fact.treatment_year
    ,perf.performer_number
    ,perf.title
    ,perf.first_init
    ,perf.surname
    ,perf.gender
    ,perf.date_of_birth
    ,perf.ni_number
    ,perf.gdc_number
    ,perf.foundation_dentist
    ,case when cpd.fd_tenure = 1 then 'Y' end as fd
    ,cont_2.commissioner_code
    ,cont_2.ltst_comm_code
    ,cont_2.ltst_comm_name
    ,cont_2.ons_country
    ,cont_2.provider_number
    ,cont_2.contract_number
    ,cont_2.contract_type
    ,cont_2.paid_by_bsa
    ,cont_2.ppc_address_postcode
    ,ons.ccg_code
    ,sum(fact.uda)  as  uda
    ,sum(fact.uoa)  as  uoa    
  from
    aml.ds_form_visit_fact  fact
  inner join
    tdim
    on  fact.treatment_year = tdim.treatment_year
    and fact.year_month     = tdim.year_month
  inner join
    perf
    on  fact.performer_number = perf.performer_number
    and fact.treatment_year   = perf.treatment_year
  -- inner join
  --   dim.ds_contract_dim cont
  --   on  fact.contract_number  = cont.contract_number
  --   and fact.year_month       = cont.year_month
  inner join
    cont_2 
  on  fact.contract_number  = cont_2.contract_number
  and fact.year_month       = cont_2.year_month
  inner join
    dim.ds_cont_perf_dim  cpd
    on  fact.performer_tenure_id  = cpd.performer_tenure_id
    and fact.year_month           = cpd.year_month
  left outer join
    dim.ds_ons_eden_combined_dim ons
    on  cont_2.ppc_address_postcode = ons.postcode 
  where 1 = 1
    and fact.ons_country  in  ('E92000001', 'W92000004')
    and fact.treatment_year = '2024/2025'
  group by
    fact.treatment_year
    ,perf.performer_number
    ,perf.title
    ,perf.first_init
    ,perf.surname
    ,perf.gender
    ,perf.date_of_birth
    ,perf.ni_number
    ,perf.gdc_number
    ,perf.foundation_dentist
    ,case when cpd.fd_tenure = 1 then 'Y' end
    ,cont_2.commissioner_code
    ,cont_2.ltst_comm_code
    ,cont_2.ltst_comm_name
    ,cont_2.ons_country
    ,cont_2.provider_number
    ,cont_2.contract_number
    ,cont_2.contract_type
    ,cont_2.paid_by_bsa
    ,cont_2.ppc_address_postcode
    ,ons.ccg_code
)

,fact as
(select * from fact_1
union all
select * from fact_2)

select * from fact
where 1=1
--and treatment_year = '2023/2024'
order by
  treatment_year
  ,performer_number
;