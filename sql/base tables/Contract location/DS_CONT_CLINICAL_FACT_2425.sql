-- script to create main contact-location clinical treatments fact for dental stats publication
-- updates for 2024/25:
-- * remove filter of active remissions as tax credit exemption data has changed after scheme end
-- * add advanced perio RSD to clinical treatments list

--dependencies:
--aml.ds_form_visit_fact
--dim.ds_year_end_reporting_period
--dim.ds_exempt_rem_dim
--dim.ds_contract_dim
--dim.ds_regions_dim
--dim.ds_ons_eden_combined_dim

--drop table ds_cont_clinical_fact_2425 cascade constraints purge;

create table  ds_cont_clinical_fact_2425 compress for  query high  as

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

,ye_dim as  (
  select
    ye.*
    ,case
      when  financial_month between 1   and 3   then 'Q1'
      when  financial_month between 4   and 6   then 'Q2'
      when  financial_month between 7   and 9   then 'Q3'
      when  financial_month between 10  and 15  then 'Q4'
    end as  quarter
    ,last_day(to_date(to_char(target_month) || '01', 'yyyymmdd')) as  last_dom
  from
    dim.ds_year_end_reporting_period  ye
  where 1 = 1
    and treatment_year  between '2019/2020' and '2024/2025'
--    and treatment_year  = '2024/2025'
) 

,tdim as  (
  select  /*+ materialize */
    treatment_year
    ,year_month
    ,target_month
    ,quarter
    ,last_dom
    ,first_value(year_month) over(partition by treatment_year order by year_month)  as period_start
    ,last_value(year_month) over(partition by treatment_year order by year_month rows between unbounded preceding and unbounded following) as period_end
    ,first_value(target_month) over(partition by quarter, treatment_year order by year_month) as quarter_start
    ,last_value(target_month) over(partition by quarter, treatment_year order by year_month rows between unbounded preceding and unbounded following) as quarter_end
    ,last_value(last_dom) over(partition by quarter, treatment_year order by year_month rows between unbounded preceding and unbounded following) as last_doq
  from
    ye_dim
)

,q_dim  as  (
  select
    distinct
    treatment_year
    ,quarter
    ,period_start
    ,period_end
    ,quarter_start
    ,quarter_end
    ,last_doq
  from
    tdim
  where 1 = 1
)
--select * from q_dim;

,y_dim  as  (
  select
    distinct
    treatment_year
    ,period_start
    ,period_end
  from
    tdim
)

/* exemption remmission look up */
,exem_lkup as (
  select  /*+ materialize */
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
    -- removed as was causing issue with inner join
    --and end_date is null          -- only active remissions
)

--select * from exem_lkup;

,fact as  (
  select
    fact.year_month
    ,fact.treatment_year
    ,treatment_month
    ,date_of_completion
    ,date_of_acceptance
    ,cast(to_char(coalesce(date_of_completion, date_of_acceptance), 'yyyymm') as NUMBER) as completion_month
    ,period_start
    ,period_end
    ,quarter_start
    ,quarter_end
    ,last_doq
    ,con.ppc_location_v_code
    ,con.contract_number
    ,substr(to_char(con.contract_number), 1, 6) || '/' || substr(to_char(con.contract_number), 7, 4) as formatted_contract_number
    ,con.provider_name
    ,con.commissioner_code
    ,con.commissioner_name
    ,con.region             as  region_code
    ,reg.region_description as  region_name
    ,ons.lad_code
    ,ons.lad_name
    ,er.er_code
    ,er.description as  er_desc
    ,er.exemption_desc
    ,er.patient_charge_status
    ,er.adult_child_ind
    ,fact.treatment_charge_band
    ,fact.treatment_sub_charge_band
    ,case
      when  treatment_charge_band = 'Band 2'  and treatment_sub_charge_band = 'N/A'     then  'Band 2'
      when  treatment_charge_band = 'Band 2'  and treatment_sub_charge_band = 'a'       then  'Band 2a'
      when  treatment_charge_band = 'Band 2'  and treatment_sub_charge_band = 'b'       then  'Band 2b'
      when  treatment_charge_band = 'Band 2'  and treatment_sub_charge_band = 'c'       then  'Band 2c'
      when  treatment_charge_band = 'Free'    and treatment_sub_charge_band = 'Unknown' then  'Free - Unknown'
      else  treatment_charge_band
    end as  treatment_charge_band_comb
    ,sum(form_count)            as  cot
    ,sum(scale_polish_count)    as  scale_polish_count
    ,sum(fv_count)              as  fv_count
    ,sum(fs_count)              as  fs_count
    ,sum(radiographs_count)     as  radiographs_count
    ,sum(endo_trt_count)        as  endo_trt_count
    ,sum(perm_fill_count)       as  perm_fill_count
    ,sum(extra_gen_count)       as  extra_gen_count
    ,sum(crowns_count)          as  crowns_count
    ,sum(upper_acrylic_count)   as  upper_acrylic_count
    ,sum(lower_acrylic_count)   as  lower_acrylic_count
    ,sum(upper_metal_count)     as  upper_metal_count
    ,sum(lower_metal_count)     as  lower_metal_count
    ,sum(
      case
        when  least(upper_acrylic_count, lower_acrylic_count, upper_metal_count, lower_metal_count) = 0
        then  greatest(upper_acrylic_count, lower_acrylic_count, upper_metal_count, lower_metal_count)
        else  least(upper_acrylic_count, lower_acrylic_count, upper_metal_count, lower_metal_count)
      end
    ) as  denture_count
    ,sum(veneers_count)         as  veneers_count
    ,sum(inlays_count)          as  inlays_count
    ,sum(bridges_count)         as  bridges_count
    ,sum(adv_man_serv_count1 + adv_man_serv_count2) as  ams_count
    ,sum(domiciliary_count)     as  domiciliary_count
    ,sum(sedation_count)        as  sedation_count
    ,sum(no_clinical_count)     as  no_clnical_count
    ,sum(fs)                    as  fs
    ,sum(radiographs)           as  radiographs
    ,sum(endo_trt)              as  endo_trt
    ,sum(perm_fill)             as  perm_fill
    ,sum(extra_gen)             as  extra_gen
    ,sum(crowns)                as  crowns
    ,sum(veneers)               as  veneers
    ,sum(inlays)                as  inlays
    ,sum(bridges)               as  bridges
    ,sum(exemination_count)     as  exam_count
    ,sum(antibiotics_count)     as  anti_count
    ,sum(other_treatment_count) as  other_count
    ,sum(non_molar_count)       as  non_molar_count
    ,sum(molar_count)           as  molar_count
    ,sum(non_molar)             as  non_molar_teeth
    ,sum(molar)                 as  molar_teeth
    ,sum(cust_occ_app_hard_count)   as  custom_hard_bite
    ,sum(cust_occ_app_soft_count)   as  custom_soft_bite
    ,sum(denture_add_rel_reb_count) as  denture_add_rel_reb
    ,sum(adv_perio_count)       as adv_perio_count -- (-1, 0, 1 to indicate if adv perio appears on form)
    ,sum(adv_perio)                      as adv_perio_sextants --number of sextant items
  from
    aml.ds_form_visit_fact  fact
  left outer join
    lc
    on  fact.form_id  = lc.form_id
  inner join
    tdim
    on  fact.treatment_year = tdim.treatment_year
    and fact.year_month     = tdim.year_month
--  inner join
--    y_dim y
--    on  fact.year_month between y.period_start and y.period_end
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
  where 1 = 1
    and lc.form_id  is  null
    and fact.ons_country  = 'E92000001'
  group by
    fact.year_month
    ,fact.treatment_year
    ,treatment_month
    ,date_of_completion
    ,date_of_acceptance
    ,cast(to_char(coalesce(date_of_completion, date_of_acceptance), 'yyyymm') as NUMBER)
    ,period_start
    ,period_end
    ,quarter_start
    ,quarter_end
    ,last_doq
    ,con.ppc_location_v_code
    ,con.contract_number
    ,substr(to_char(con.contract_number), 1, 6) || '/' || substr(to_char(con.contract_number), 7, 4) 
    ,con.provider_name
    ,con.commissioner_code
    ,con.commissioner_name
    ,con.region             
    ,reg.region_description
    ,ons.lad_code
    ,ons.lad_name
    ,er.er_code
    ,er.description
    ,er.exemption_desc
    ,er.patient_charge_status
    ,er.adult_child_ind
    ,fact.treatment_charge_band
    ,fact.treatment_sub_charge_band
    ,case
      when  treatment_charge_band = 'Band 2'  and treatment_sub_charge_band = 'N/A'     then  'Band 2'
      when  treatment_charge_band = 'Band 2'  and treatment_sub_charge_band = 'a'       then  'Band 2a'
      when  treatment_charge_band = 'Band 2'  and treatment_sub_charge_band = 'b'       then  'Band 2b'
      when  treatment_charge_band = 'Band 2'  and treatment_sub_charge_band = 'c'       then  'Band 2c'
      when  treatment_charge_band = 'Free'    and treatment_sub_charge_band = 'Unknown' then  'Free - Unknown'
      else  treatment_charge_band
    end 
)

,filtered_fact  as  (
  select
    case
      when  completion_month between period_start and period_start + 2  
            or (year_month between period_start and period_start  +2 and completion_month < period_start)
          then 'Q1'
      when  completion_month between period_start + 3 and period_start + 5  
            or (year_month between period_start + 3 and period_start + 5 and completion_month < period_start)
          then 'Q2'
      when  completion_month between period_start + 6 and period_start + 8  
            or (year_month between period_start + 6 and period_start + 8 and completion_month < period_start)
          then 'Q3'
      when  completion_month between period_end - 5 and period_end - 3  
            or (year_month between period_end - 5 and period_end - 3 and completion_month < period_start)
          then 'Q4'
    end as quarter
    ,fact.*
  from
    fact
  where 1 = 1
    and fact.year_month between period_start and period_end 
)

select
  *
from
  filtered_fact
where 1 = 1
  and quarter is not null
order by
  treatment_year
  ,quarter
  ,contract_number
;

-- grant access to other stats team members, if required

/* test queries */
--select
--treatment_year
--,quarter
--,sum(case when treatment_charge_band_comb = 'Band 1' then cot else 0 end) as band_1
--,sum(case when treatment_charge_band_comb = 'Band 2' then cot else 0 end) as band_2
--,sum(case when treatment_charge_band_comb = 'Band 2a' then cot else 0 end) as band_2a
--,sum(case when treatment_charge_band_comb = 'Band 2b' then cot else 0 end) as band_2b
--,sum(case when treatment_charge_band_comb = 'Band 2c' then cot else 0 end) as band_2c
--,sum(case when treatment_charge_band_comb = 'Band 3' then cot else 0 end) as band_3
--,sum(case when treatment_charge_band_comb = 'Urgent Treatment' then cot else 0 end) as urgent
--
--,sum(cot) as total
--from
--filtered_fact
--where 1=1
--and er_code != 'C'
--and treatment_charge_band_comb in ('Band 1', 'Band 2', 'Band 2a', 'Band 2b', 'Band 2c', 'Band 3', 'Urgent Treatment')
--group by
--treatment_year
--,quarter
--order by treatment_year desc, quarter
--;