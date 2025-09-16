with

icbs  as  (
  select  /*+  materialize */
    distinct
    icb23cd
    ,icb23cdh
    ,icb23nm
  from
    ost.ons_codes_lookup_23
)

,regions  as  (
  select /*+  materialize */
    distinct
    nhser23cd
    ,nhser23cdh
    ,nhser23nm
  from
    ost.ons_codes_lookup_23
)

,la_data  as  (
  select
    treatment_year      as  financial_year
    ,'LOCAL_AUTHORITY'  as  geography_type
    ,'N/A'              as  geography_ods_code
    ,lad_code           as  geography_ons_code
    ,lad_name           as  geography_name
    ,sum(uoa)           as  uoa
  from
    ost.ds_cont_ortho_fact
  where 1 = 1
  group by
    treatment_year
    ,'LOCAL_AUTHORITY'
    ,'N/A'
    ,lad_code
    ,lad_name
  order by
    treatment_year
    ,lad_code
)

,icb_data as  (
  select
    treatment_year              as  financial_year
    ,'ICB'                      as  geography_type
    ,commissioner_code          as  geography_ods_code
    ,icbs.icb23cd               as  geography_ons_code
    ,commissioner_name          as  geography_name
    ,sum(uoa)                   as  uoa
  from
    ost.ds_cont_ortho_fact fact
  inner join
    icbs
    on  fact.commissioner_code = icbs.icb23cdh
  where 1 = 1
  group by
    treatment_year              
    ,'ICB'                      
    ,commissioner_code         
    ,icbs.icb23cd              
    ,commissioner_name          
  order by
    treatment_year
    ,commissioner_name  
)

,region_data  as  (
    select
    treatment_year              as  financial_year
    ,'REGION'                   as  geography_type
    ,region_code                as  geography_ods_code
    ,reg.nhser23cd              as  geography_ons_code
    ,region_name                as  geography_name
    ,sum(uoa)                   as  uoa
  from
    ost.ds_cont_ortho_fact fact
  inner join
    regions reg
    on  fact.region_code = reg.nhser23cdh
  where 1 = 1
  group by
    treatment_year              
    ,'REGION'                      
    ,region_code         
    ,reg.nhser23cd              
    ,region_name          
  order by
    treatment_year
    ,region_code
)

,union_tbl  as  (
  select  * from  la_data
  union all
  select  * from  icb_data
  union all
  select  * from  region_data
)

select * from union_tbl
;
