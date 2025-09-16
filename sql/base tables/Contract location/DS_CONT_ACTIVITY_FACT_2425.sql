-- script to create main contact-location activity fact for dental stats publication
-- updates for 2024/25:
-- * remove filter of active remissions as tax credit exemption data has changed after scheme end
-- * add columns to get dental care professional (DCP) flag and DCP type
-- code added to fix 2 postcodes behaving unexpectedly

--drop table ds_cont_activity_fact_2425 purge;
create table  ds_cont_activity_fact_2425 compress for  query high  as

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

/* build reporting time dim */
,rep_year as (
  select  /*+ materialize */
    yerp.*
    ,case
      when  financial_month between 1   and 3   then 'Q1'
      when  financial_month between 4   and 6   then 'Q2'
      when  financial_month between 7   and 9   then 'Q3'
      when  financial_month between 10  and 15  then 'Q4'
    end as  quarter
  from
    dim.ds_year_end_reporting_period  yerp
  where 1 = 1
    and treatment_year between '2019/2020' and '2024/2025'
--    and treatment_year = '2024/2025'
)

,tdim as  (
  select
    rep_year.*
    ,first_value(year_month) over(partition by treatment_year order by year_month)  as period_start
    ,last_value(year_month) over(partition by treatment_year order by year_month rows between unbounded preceding and unbounded following) as period_end
    ,first_value(year_month) over(partition by quarter, treatment_year order by year_month) as quarter_start
    ,last_value(year_month) over(partition by quarter, treatment_year order by year_month rows between unbounded preceding and unbounded following) as quarter_end
  from
    rep_year
  where 1 = 1
)

--,q_select as (
--  select  distinct
--    treatment_year
--    ,quarter
--    ,quarter_start
--    ,quarter_end
--  from
--    tdim
--  where 1 = 1
--)

,y_select as (
  select /*+ materialize */
    distinct
    treatment_year
    ,period_start
    ,period_end
  from
    tdim
  where 1 = 1
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
      
  from
    dim.ds_exempt_rem_dim exem
  where 1 = 1
    and ons_country = 'E92000001' -- only remissions that apply to England
    -- removed as was causing issue with inner join
    --and end_date is null          -- only active remissions
)


,fact as  (
  select
    fact.year_month
    ,fact.treatment_year
    ,treatment_month
    ,date_of_completion
    ,date_of_acceptance
    ,cast(to_char(coalesce(date_of_completion, date_of_acceptance), 'yyyymm') as NUMBER) as completion_month
    ,y.period_start
    ,y.period_end
    ,fact.contract_number
    ,substr(to_char(con.contract_number), 1, 6) || '/' || substr(to_char(con.contract_number), 7, 4)  as  formatted_contract_number
    -- columns to filter dental care professional (DCP) activity and assists 
    ,fact.performer_number
    ,fact.dcp_dir_flag
    ,fact.dcp_dir_ind
    ,fact.dcp_ind
    ,fact.dcp_reg_num
    ,fact.fd_performer
    ,con.provider_name
    ,con.ppc_address_postcode
    ,con.ppc_loc_id
    ,con.ppc_location_v_code
    ,con.commissioner_code
    ,con.commissioner_name
    ,con.icb_code_ons
    ,con.region_code
    ,con.region_name
    ,con.region_code_ons
    ,con.lad_code
    ,con.lad_name
    
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
--    ,fact.exemption_remission_code
    ,er.er_code
    ,er.description as  er_desc
    ,er.exemption_desc
    ,er.patient_charge_status
    /* aggregated facts */
    ,sum(uda)         as  uda
    ,sum(form_count)  as  cot
  
  from
    aml.ds_form_visit_fact fact
  left outer join
    lc
    on  fact.form_id  = lc.form_id
  /* filtering joins to assign quarter */
  inner join
    y_select  y
      on  fact.treatment_year = y.treatment_year
  inner join
    exem_lkup er
    on  fact.exemption_remission_code = er.code
    and fact.ons_country              = er.ons_country
  inner join  
    ost.ds_cont_details_ltst_dim_2425  con
    on  fact.contract_number  = con.contract_number
  -- inner join
  --   dim.ds_contract_dim con
  --   on  fact.contract_number  = con.contract_number
  --   and fact.ons_country      = con.ons_country
  --   and y.period_end          = con.year_month
  -- left outer join
  --   dim.ds_ons_eden_combined_dim  ons
  --   on  con.ppc_address_postcode  = ons.postcode
  --   and fact.ons_country          = ons.country_code
  -- inner join
  --   dim.ds_regions_dim  reg
  --   on  con.region      =  reg.region_code
  --   and con.ons_country = reg.ons_country
  --   and con.year_month  = reg.year_month
  
  /* limit to England and remove contras */
  where 1=1
    and fact.ons_country  =   'E92000001'
    and lc.form_id        is  null  
    
  group by
    fact.year_month
    ,fact.treatment_year
    ,treatment_month
    ,date_of_completion
    ,date_of_acceptance
    ,cast(to_char(coalesce(date_of_completion, date_of_acceptance), 'yyyymm') as NUMBER)
    ,y.period_start
    ,y.period_end
    ,fact.contract_number
    ,substr(to_char(con.contract_number), 1, 6) || '/' || substr(to_char(con.contract_number), 7, 4)  
    -- columns to filter dental care professional (DCP) activity and assists 
    ,fact.performer_number
    ,fact.dcp_dir_flag
    ,fact.dcp_dir_ind
    ,fact.dcp_ind
    ,fact.dcp_reg_num
    ,fact.fd_performer
    ,con.provider_name
    ,con.ppc_address_postcode
    ,con.ppc_loc_id
    ,con.ppc_location_v_code
    ,con.commissioner_code
    ,con.commissioner_name
    ,con.icb_code_ons
    ,con.region_code
    ,con.region_name
    ,con.region_code_ons
    ,con.lad_code
    ,con.lad_name
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
    end
--    ,fact.exemption_remission_code
    ,er.er_code
    ,er.description
    ,er.exemption_desc
    ,er.patient_charge_status

)

,filtered_fact as  (
  select
    fact.* 
    ,case
      when completion_month between period_start and period_start + 2 then 'Q1'
      when completion_month between period_start + 3 and period_start + 5 then 'Q2'
      when completion_month between period_start + 6 and period_start + 8 then 'Q3'
      when (
        case
          when completion_month < period_start and year_month < period_start + 100 then year_month
          when completion_month < period_start and year_month between period_end - 2 and period_end then period_end -3
          else completion_month
        end
        ) between period_end -5 and period_end - 3 then 'Q4'
      end as quarter
  from
    fact
  where 1 = 1
    /* apply restrictions on what udas are counted in line with UDA extract */
    and fact.year_month between period_start and period_end --year_month in 15 month submission window
),

-- build dcp columns
-- subset for DCP_DIR_FLAG  = 1
flag_1 as (
select * from filtered_fact
where DCP_DIR_FLAG = 1
),
-- subset for DCP_DIR_FLAG  = 0
flag_0 as (
select * from filtered_fact
where DCP_DIR_FLAG = 0
),
-- joins for each subset
joined_1 as (
select j1.*, j2.*
from flag_1 j1
left join dim.ds_clinician_type_dim j2
on j1.DCP_DIR_IND  = j2.TREATMENT_9182_VALUE
),
joined_0 as (
select j1.*, j2.*
from flag_0 j1
-- filter out duplicate TREATMENT_9178_VALUE before joining
left join (
    select *
    from dim.ds_clinician_type_dim
    where TYPE_DESCR != 'Dental Technician'
) j2
on j1.DCP_IND  = j2.TREATMENT_9178_VALUE
),
-- union
union_table as(
select * from joined_1
union all
select * from joined_0),
-- build fact with dcp column and dcp type column
fact_table as (
select t.* 
,case
    when DCP_DIR_FLAG = 1 then 'DCP-led'
    when DCP_DIR_FLAG = 0 and type_id != -1 then 'DCP-assisted'
    when DCP_DIR_FLAG = 0 and type_id = -1 then 'Non-DCP led and not DCP assisted'
    else NULL
end as DCP
,case
    when TYPE_DESCR = 'Clinical Dental Technician' then 'Other'
    when TYPE_DESCR = 'No DCP on Form' then 'None'
    when TYPE_DESCR = 'Dental Hygienist' then 'Dental Hygienist'
    when TYPE_DESCR = 'Dental Therapist' then 'Dental Therapist'
    when TYPE_DESCR = 'Dental Nurse' then 'Other'
    else 'Other'
end as DCP_TYPE
from union_table t
)
-- build summary
select 
YEAR_MONTH
,TREATMENT_YEAR
,TREATMENT_MONTH
,DATE_OF_COMPLETION
,DATE_OF_ACCEPTANCE
,COMPLETION_MONTH
,PERIOD_START
,PERIOD_END
,CONTRACT_NUMBER
,FORMATTED_CONTRACT_NUMBER
,PERFORMER_NUMBER
,DCP_DIR_FLAG
,DCP_DIR_IND
,DCP_IND
,DCP_REG_NUM
,FD_PERFORMER
,PROVIDER_NAME
,PPC_ADDRESS_POSTCODE
,PPC_LOC_ID
,PPC_LOCATION_V_CODE
,COMMISSIONER_CODE
,COMMISSIONER_NAME
,ICB_CODE_ONS
,REGION_CODE
,REGION_NAME
,REGION_CODE_ONS
,LAD_CODE
,LAD_NAME
,FORM_TYPE
,TREATMENT_CHARGE_BAND
,TREATMENT_SUB_CHARGE_BAND
,TREATMENT_CHARGE_BAND_COMB
,ER_CODE
,ER_DESC
,EXEMPTION_DESC
,PATIENT_CHARGE_STATUS
,UDA
,COT
,QUARTER
,DCP
,DCP_TYPE
from fact_table
where 1 = 1
  and quarter is not null;
  
-- Postcode fix for 2 known errors that make 2 postcodes not map to LA

update DS_CONT_ACTIVITY_FACT_2425
set PPC_ADDRESS_POSTCODE = case PPC_ADDRESS_POSTCODE 
               when 'ME1  2EL' then 'ME1 2EL'
               when 'SW5 4UL' then 'SW6 4UL'
               END
where ppc_address_postcode in ('ME1  2EL','SW5 4UL');   

update DS_CONT_ACTIVITY_FACT_2425
set LAD_CODE = case PPC_ADDRESS_POSTCODE 
               when 'ME1 2EL' then 'E06000035'
               when 'SW6 4UL' then 'E09000013'
               end
where ppc_address_postcode in ('ME1 2EL','SW6 4UL');   

update DS_CONT_ACTIVITY_FACT_2425
set LAD_NAME = case PPC_ADDRESS_POSTCODE 
               when 'ME1 2EL' then 'Medway'
               when 'SW6 4UL' then 'Hammersmith and Fulham'
               end
where ppc_address_postcode in ('ME1 2EL','SW6 4UL');