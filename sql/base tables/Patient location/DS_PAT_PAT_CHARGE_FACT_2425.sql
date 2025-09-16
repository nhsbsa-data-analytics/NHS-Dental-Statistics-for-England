--drop table  ds_pat_pat_charge_fact_2425 cascade constraints purge;

create table  DS_PAT_PAT_CHARGE_FACT_2425 compress for  query high  as

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

/* create lookup to remove form ids with contra entries */
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
--    and treatment_year = '2022/2023'
  group by
    treatment_year
)

/* exemption remmission look up */
,exem_lkup as (
  select
    exem.*
    ,case
      when  er_code = 'C' then 'Child (under 18)'
      when  er_code = 'E' then 'Adult in receipt of income-based Jobseeker''s Allowance (JSA)' -- not typo, escape character
      when  er_code = 'L' then 'Expectant mother'
      when  er_code = 'M' then 'Nursing mother (had a baby in the year before treatment starts)'
      when  er_code = 'N' and er_type = 'E' then 'Aged 18 and in full-time education'
      when  er_code = 'P' then 'Pension Credit guarantee credit (PCgc)'
      when  er_code = 'Q' then 'Evidence of remission not seen'
      when  er_code in ('R', 'Y') then 'In Prison or a Young Offender Institute' -- doesn't seem to be a 'Y' in the table, but have added just incase
      when  er_code = 'S' then 'Adult in receipt of Income Support'
      when  er_code = 'T' then 'Named on a valid NHS Tax Credit Exemption certificate'
      when  er_code = 'U' then 'Adult in receipt of income-related Employment and Support Allowance (ESA)'
      when  er_code = 'V' then 'Named on a HC3 certificate'
      when  er_code = 'W' then 'Named on a HC2 certificate'
      when  er_code = 'X' then 'Adult in receipt of Universal Credit'
      when  er_code = 'N' and er_type = 'N' then 'Paying adult'
    end as exemption_desc
    ,case when  patient_charge_status != 'Child'  then 'Adult'  else patient_charge_status  end as  adult_child_ind
  from
    dim.ds_exempt_rem_dim exem
  where 1 = 1
    and ons_country = 'E92000001' -- only remissions that apply to England
    -- removed as was causing issue with inner join (tax credit scheme end)
    --and end_date is null          -- only active remissions
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
    fact.year_month
    ,fact.treatment_year
    ,fact.date_of_acceptance
    ,fact.date_of_completion
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
    ,form_type
    ,treatment_charge_band
    ,treatment_sub_charge_band
    /* combine sub charge bands to have one column for filtering */
    ,case
      when  treatment_charge_band = 'Band 2'  and treatment_sub_charge_band = 'N/A'     then  'Band 2'
      when  treatment_charge_band = 'Band 2'  and treatment_sub_charge_band = 'a'       then  'Band 2a'
      when  treatment_charge_band = 'Band 2'  and treatment_sub_charge_band = 'b'       then  'Band 2b'
      when  treatment_charge_band = 'Band 2'  and treatment_sub_charge_band = 'c'       then  'Band 2c'
      when  treatment_charge_band = 'Free'    and treatment_sub_charge_band = 'Unknown' then  'Free - Unknown'
      else  treatment_charge_band
    end as  treatment_charge_band_comb
    ,er.er_code
    ,er.description as  er_desc
    ,er.exemption_desc
    ,er.patient_charge_status
    ,er.adult_child_ind
    ,fact.patient_charge_amount
    ,fact.patient_charge_collected
    ,fact.form_count
--    ,sum(fact.patient_charge_amount)    as  patient_charge_amount
--    ,sum(fact.patient_charge_collected) as  patient_charge_collected
  from
    aml.ds_form_visit_fact  fact
   left outer join
    lc
    on  fact.form_id  = lc.form_id
  inner join
    tdim
    on  fact.treatment_year = tdim.treatment_year
  inner join
    exem_lkup er
    on  fact.exemption_remission_code = er.code
    and fact.ons_country              = er.ons_country
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
)

--select * from fact 
--fetch first 10 rows only;

,charge_fact  as  (
  select
    fact.year_month
    ,fact.treatment_year
    ,fact.date_of_acceptance
    ,fact.date_of_completion
    ,fact.postcode -- patient postcode
    ,ctry
    ,laua
    ,ward
    ,pat_region
    ,pat_icb
    ,pat_lsoa11
    ,pat_icb_cdh
    ,pat_icb_nm
    ,imd_decile
    ,imd_rank
    ,ppc_loc_id
    ,ppc_location_v_code
    ,fact.contract_number
    ,formatted_contract_number
    ,provider_name
    ,ppc_address_postcode
    ,commissioner_code
    ,commissioner_name
    ,region_code            
    ,region_name 
    ,lad_code
    ,lad_name
    ,form_type
    ,treatment_charge_band
    ,treatment_sub_charge_band
    ,fact.treatment_charge_band_comb
    ,er_code
    ,er_desc
    ,exemption_desc
    ,patient_charge_status
    ,adult_child_ind 
    ,sum(fact.patient_charge_amount)              as  patient_charge_amount
    ,sum(fact.patient_charge_collected)           as  patient_charge_collected
    ,sum(nvl(cref.patient_charge_amount/100, 0))  as  patient_charge_amount_calc
    ,sum(form_count)                              as  cot
  from
    fact
  left outer join
    ost.ds_treatment_cost_ref_2425 cref
    on  fact.treatment_charge_band_comb = cref.treatment_charge_band_comb
    and fact.date_of_acceptance between cref.start_date and cref.end_date
  where 1 = 1
  group by
    fact.year_month
    ,fact.treatment_year
    ,fact.date_of_acceptance
    ,fact.date_of_completion
    ,fact.postcode -- patient postcode
    ,ctry
    ,laua
    ,ward
    ,pat_region
    ,pat_icb
    ,pat_lsoa11
    ,pat_icb_cdh
    ,pat_icb_nm
    ,imd_decile
    ,imd_rank
    ,ppc_loc_id
    ,ppc_location_v_code
    ,fact.contract_number
    ,formatted_contract_number
    ,provider_name
    ,ppc_address_postcode
    ,commissioner_code
    ,commissioner_name
    ,region_code            
    ,region_name 
    ,lad_code
    ,lad_name
    ,form_type
    ,treatment_charge_band
    ,treatment_sub_charge_band
    ,fact.treatment_charge_band_comb
    ,er_code
    ,er_desc
    ,exemption_desc
    ,patient_charge_status
    ,adult_child_ind 
)

select
  *
from
  charge_fact
;

--select
--  treatment_year
--  ,sum(case when treatment_charge_band_comb = 'Band 1' then patient_charge_amount_calc else 0 end) as band_1
--  ,sum(case when treatment_charge_band = 'Band 2' then patient_charge_amount_calc else 0 end) as band_2_total
--  ,sum(case when treatment_charge_band_comb = 'Band 2' then patient_charge_amount_calc else 0 end) as band_2
--  ,sum(case when treatment_charge_band_comb = 'Band 2a' then patient_charge_amount_calc else 0 end) as band_2a
--  ,sum(case when treatment_charge_band_comb = 'Band 2b' then patient_charge_amount_calc else 0 end) as band_2b
--  ,sum(case when treatment_charge_band_comb = 'Band 2c' then patient_charge_amount_calc else 0 end) as band_2c
--  ,sum(case when treatment_charge_band_comb = 'Band 3' then patient_charge_amount_calc else 0 end) as band_3
--  ,sum(case when treatment_charge_band_comb = 'Urgent Treatment' then patient_charge_amount_calc else 0 end) as urgent
--  ,sum(case when treatment_charge_band_comb in ('Band 1', 'Band 2', 'Band 2a', 'Band 2b', 'Band 2c', 'Band 3', 'Urgent Treatment') then patient_charge_amount_calc else 0 end) as tot_exc_free
--  ,sum(patient_charge_amount_calc) as total
--  
--from
--  charge_fact
--where 1=1
--  and patient_charge_status != 'Non-Exempt'
--group by
--treatment_year
--;

--select
--  treatment_year
--  ,sum(case when treatment_charge_band_comb = 'Band 1' then cot else 0 end) as band_1
--  ,sum(case when treatment_charge_band_comb = 'Band 2' then cot else 0 end) as band_2
--  ,sum(case when treatment_charge_band_comb = 'Band 2a' then cot else 0 end) as band_2a
--  ,sum(case when treatment_charge_band_comb = 'Band 2b' then cot else 0 end) as band_2b
--  ,sum(case when treatment_charge_band_comb = 'Band 2c' then cot else 0 end) as band_2c
--  ,sum(case when treatment_charge_band_comb = 'Band 3' then cot else 0 end) as band_3
--  ,sum(case when treatment_charge_band_comb = 'Urgent Treatment' then cot else 0 end) as urgent
--  ,sum(cot) as total
--  
--from
--  charge_fact
--where 1=1
--  and patient_charge_status != 'Non-Exempt'
--group by
--treatment_year
--;