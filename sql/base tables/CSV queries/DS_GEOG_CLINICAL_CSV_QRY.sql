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
    ost.ds_cont_clinical_fact
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
      ,COT  as  'Total_Cl'
    )
  )
  where 1 = 1
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

,la_data  as  (
  select
    treatment_year                    as  financial_year
    ,treatment_year || ' ' || quarter as  financial_quarter
    ,'LOCAL_AUTHORITY'                as  geography_type
    ,'N/A'                            as  geography_ods_code
    ,lad_code                         as  geography_ons_code
    ,lad_name                         as  geography_name
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
    ,lad_code                         
    ,lad_name                         
    ,adult_child_ind                 
    ,treatment_charge_band_comb       
    ,measure
  order by
    treatment_year
    ,treatment_year || ' ' || quarter 
    ,lad_code
    ,adult_child_ind
    ,treatment_charge_band_comb       
    ,measure
)

,icb_data as  (    
    select
    treatment_year                    as  financial_year
    ,treatment_year || ' ' || quarter as  financial_quarter
    ,'ICB'                            as  geography_type
    ,commissioner_code                as  geography_ods_code
    ,icbs.icb23cd                     as  geography_ons_code
    ,commissioner_name                as  geography_name
    ,adult_child_ind                  as  age_band
    ,treatment_charge_band_comb       as  dental_treatment_band
    ,measure
    ,sum(value)                       as  value
  from
    piv_fact  fact
  inner join
    icbs
    on  fact.commissioner_code = icbs.icb23cdh
  where 1 = 1
  group by
    treatment_year
    ,treatment_year || ' ' || quarter 
    ,'ICB'                
    ,commissioner_code                            
    ,icbs.icb23cd                          
    ,commissioner_name                         
    ,adult_child_ind                 
    ,treatment_charge_band_comb       
    ,measure
  order by
    treatment_year
    ,treatment_year || ' ' || quarter 
    ,commissioner_name
    ,adult_child_ind
    ,treatment_charge_band_comb       
    ,measure
)

,region_data  as  (    
    select
    treatment_year                    as  financial_year
    ,treatment_year || ' ' || quarter as  financial_quarter
    ,'REGION'                         as  geography_type
    ,region_code                      as  geography_ods_code
    ,reg.nhser23cd                    as  geography_ons_code
    ,region_name                      as  geography_name
    ,adult_child_ind                  as  age_band
    ,treatment_charge_band_comb       as  dental_treatment_band
    ,measure
    ,sum(value)                       as  value
  from
    piv_fact  fact
  inner join
    regions reg
    on  fact.region_code = reg.nhser23cdh
  where 1 = 1
  group by
    treatment_year
    ,treatment_year || ' ' || quarter 
    ,'REGION'                
    ,region_code                            
    ,reg.nhser23cd                          
    ,region_name
    ,adult_child_ind                 
    ,treatment_charge_band_comb       
    ,measure
  order by
    treatment_year
    ,treatment_year || ' ' || quarter
    ,region_code
    ,adult_child_ind
    ,treatment_charge_band_comb
    ,measure
)

,union_tbl  as  (
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
;
