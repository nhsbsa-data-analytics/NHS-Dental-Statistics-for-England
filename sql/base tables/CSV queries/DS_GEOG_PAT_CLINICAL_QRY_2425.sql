--drop table DS_GEOG_PAT_CLINICAL_QRY_2425 cascade constraints purge;

create table DS_GEOG_PAT_CLINICAL_QRY_2425 compress for  query high  as

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

,piv_fact  as  (
  select
    *
  from
    ost.ds_pat_clinical_fact_2425
  unpivot(
    value for measure in  (  
      SCALE_POLISH_COUNT as 'Cl_ScalePolish'
      ,FV_COUNT as 'Cl_Fluoride'
      ,FS_COUNT as 'Cl_Fissure'
      ,RADIOGRAPHS_COUNT as 'Cl_Radiographs'
      ,ENDO_TRT_COUNT as 'Cl_Endodontic'
      ,PERM_FILL_COUNT as 'Cl_Fillings'
      ,EXTRA_GEN_COUNT as 'Cl_Extractions'
      ,CROWNS_COUNT as 'Cl_Crowns'
      ,UPPER_ACRYLIC_COUNT as 'Cl_UDent_Ac'
      ,LOWER_ACRYLIC_COUNT as 'Cl_LDent_Ac'
      ,UPPER_METAL_COUNT as 'Cl_UDent_Met'
      ,LOWER_METAL_COUNT as 'Cl_LDent_Met'
      ,DENTURE_COUNT as 'Cl_Denture'
      ,VENEERS_COUNT as 'Cl_Veneers'
      ,INLAYS_COUNT as 'Cl_Inlays'
      ,BRIDGES_COUNT as 'Cl_Bridges'
      ,AMS_COUNT as 'Cl_AMS'
      ,DOMICILIARY_COUNT as 'Cl_DomVisit'
      ,SEDATION_COUNT as 'Cl_Sedation'
      ,NO_CLNICAL_COUNT as 'Cl_NoCDS'
      ,FS as 'Te_Fissure'
      ,RADIOGRAPHS as 'Num_Radiographs'
      ,ENDO_TRT as 'Te_Endodontic'
      ,PERM_FILL as 'Te_Fillings'
      ,EXTRA_GEN as 'Te_Extractions'
      ,CROWNS as 'Te_Crowns'
      ,VENEERS as 'Te_Veneers'
      ,INLAYS as 'Te_Inlays'
      ,BRIDGES as 'Num_BridgeUnits'
      ,EXAM_COUNT as 'Examination'
      ,ANTI_COUNT as 'Antibiotic'
      ,OTHER_COUNT as 'Other_Treatments'
      ,NON_MOLAR_COUNT as 'Cl_Non_Molar_Endodontic'
      ,MOLAR_COUNT as 'Cl_Molar_Endodontic'
      ,NON_MOLAR_TEETH as 'Teeth_Non_Molar_Endodontic'
      ,MOLAR_TEETH as 'Teeth_Molar_Endodontic'
      ,CUSTOM_HARD_BITE as 'Cl_Custom_Oclusal_Hard_Bite'
      ,CUSTOM_SOFT_BITE as 'Cl_Custom_Oclusal_Soft_Bite'
      ,DENTURE_ADD_REL_REB as 'Cl_Denture_Adds_Reline_Rebase'
      ,ADV_PERIO_COUNT as 'Cl_Adv_perio_RSD'
      ,ADV_PERIO_SEXTANTS as 'Adv_perio_RSD_sextants'
      ,COT  as  'Total_Cl'
    )
  )
  where 1 = 1
--  and treatment_year = '2023/2024'
--  and year_month in ('202304',
--                     '202305',
--                     '202306')
    and treatment_charge_band_comb  in  (
      'Band 1'
      ,'Band 2'
      ,'Band 2a'
      ,'Band 2b'
      ,'Band 2c'
      ,'Band 3'
      ,'Urgent Treatment'
      ,'Free'
    )
)

--,ward_data as (
--  select
--    treatment_year                    as  financial_year
--    ,treatment_year || ' ' || quarter as  financial_quarter
--    ,'WARD'                           as  geography_type
--    ,'N/A'                            as  geography_ods_code
--    ,ward                             as  geography_ons_code
--    ,'WARD NAME'                      as  geography_name
--    ,adult_child_ind                  as  age_band
--    ,treatment_charge_band_comb       as  dental_treatment_band
--    ,measure
--    ,sum(value)                       as  value
--  from
--    piv_fact
--  where 1 = 1
--  group by
--    treatment_year
--    ,treatment_year || ' ' || quarter 
--    ,'WARD'                
--    ,'N/A'                            
--    ,ward 
--    ,'WARD NAME'
--    ,adult_child_ind                 
--    ,treatment_charge_band_comb       
--    ,measure
--  order by
--    treatment_year
--    ,treatment_year || ' ' || quarter 
--    ,ward
--    ,adult_child_ind
--    ,treatment_charge_band_comb       
--    ,measure
--)

,la_data  as  (
  select
    treatment_year                    as  financial_year
    ,treatment_year || ' ' || quarter as  financial_quarter
    ,'LOCAL_AUTHORITY'                as  geography_type
    ,'N/A'                            as  geography_ods_code
    ,laua                             as  geography_ons_code
    ,'LA NAME'                        as  geography_name
    ,adult_child_ind                  as  age_band
    ,treatment_charge_band_comb       as  dental_treatment_band
    ,measure
    ,sum(value)                       as  value
  from
    piv_fact
  where 1 = 1
  group by
    treatment_year
    ,treatment_year || ' ' || quarter 
    ,'LOCAL_AUTHORITY'                
    ,'N/A'                            
    ,laua 
    ,'LA NAME'
    ,adult_child_ind                 
    ,treatment_charge_band_comb       
    ,measure
  order by
    treatment_year
    ,treatment_year || ' ' || quarter 
    ,laua
    ,adult_child_ind
    ,treatment_charge_band_comb       
    ,measure
)

,icb_data as  (    
    select
    treatment_year                    as  financial_year
    ,treatment_year || ' ' || quarter as  financial_quarter
    ,'ICB'                            as  geography_type
    ,pat_icb_cdh                      as  geography_ods_code
    ,pat_icb                          as  geography_ons_code
    ,pat_icb_nm                       as  geography_name
    ,adult_child_ind                  as  age_band
    ,treatment_charge_band_comb       as  dental_treatment_band
    ,measure
    ,sum(value)                       as  value
  from
    piv_fact  fact
  where 1 = 1
  group by
    treatment_year
    ,treatment_year || ' ' || quarter 
    ,'ICB'                
    ,pat_icb_cdh                            
    ,pat_icb                           
    ,pat_icb_nm                          
    ,adult_child_ind                 
    ,treatment_charge_band_comb       
    ,measure
  order by
    treatment_year
    ,treatment_year || ' ' || quarter 
    ,pat_icb
    ,adult_child_ind
    ,treatment_charge_band_comb       
    ,measure
)

,region_data  as  (    
    select
    treatment_year                    as  financial_year
    ,treatment_year || ' ' || quarter as  financial_quarter
    ,'REGION'                         as  geography_type
    ,'Unknown'                        as  geography_ods_code
    ,pat_region                       as  geography_ons_code
    ,'REGION NAME'                    as  geography_name
    ,adult_child_ind                  as  age_band
    ,treatment_charge_band_comb       as  dental_treatment_band
    ,measure
    ,sum(value)                       as  value
  from
    piv_fact  fact
  where 1 = 1
  group by
    treatment_year
    ,treatment_year || ' ' || quarter 
    ,'REGION'                
    ,pat_region  
    ,'REGION NAME'
    ,adult_child_ind                 
    ,treatment_charge_band_comb       
    ,measure
  order by
    treatment_year
    ,treatment_year || ' ' || quarter
    ,pat_region
    ,adult_child_ind
    ,treatment_charge_band_comb
    ,measure
)

,union_tbl  as  (
--  select  * from  ward_data
--  union all
  select  * from  la_data
  union all
  select  * from  icb_data
  union all
  select  * from  region_data
)

select
  financial_year
  ,financial_quarter
  ,geography_type
  ,geography_ods_code
  ,geography_ons_code
  ,geography_name
  ,age_band
  ,dental_treatment_band
  ,measure
  ,value
from
  union_tbl
  where 1=1
;