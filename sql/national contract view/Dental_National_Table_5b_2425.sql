-------------------------------------------------------------------------------------------------------
-- DENTAL National Activity Table 5b
--------------------------------------------------------------------------------------------------------

--Aug 2025: amended to add advanced perio RSD clinical item, requested by NHSE
--need to check if adv_perio is usually only once per COT, 
--eg. if COT and number of items will be the same
--have used adv_perio_sextants for total sextants, instead of adv_perio_count

DROP TABLE dental_national_table5b_2425;

CREATE TABLE dental_national_table5b_2425 AS
WITH
fact1 AS (   
SELECT treatment_year,
       treatment_charge_band_comb,
       SUM(fs)                    as C_fissure_sealants,
       SUM(radiographs)           as D_radiographs,
       SUM(endo_trt)              as E_endodontic,
       SUM(perm_fill)             as F_perm_fill,
       SUM(extra_gen)             as G_extraction,
       SUM(crowns)                as H_crowns,
       SUM(veneers)               as M_veneers,
       SUM(inlays)                as N_inlays,
       SUM(bridges)               as O_bridges,
       SUM(non_molar_count)       as W_non_molar,
       SUM(molar_count)           as X_molar,
       SUM(adv_perio_sextants)    as Y_adv_perio_sextants
FROM OST.DS_CONT_CLINICAL_FACT_2425
--FROM dental_national_activity_fact_inc_contras -- for comparison with NHSE publication
WHERE 1=1
--AND form_type = 'G' 
--AND uda <> 0                        
AND adult_child_ind = 'Adult'
--AND adult_child_at_doa = 'A'         
--AND age_at_period_end >= 18
AND treatment_charge_band_comb IN ('Band 1', 'Band 2', 'Band 2a', 'Band 2b', 'Band 2c', 'Band 3', 'Urgent Treatment')
--AND quarter != 'unallocated_1'  
AND quarter != 'unallocated_2' -- unallocated quarters shouldn't appear in table, but code kept to catch anything unusual
--AND treatment_year BETWEEN '2018/2019' AND '2023/2024' -- for testing only
GROUP BY treatment_year,  treatment_charge_band_comb
ORDER BY treatment_year DESC, treatment_charge_band_comb
)
--SELECT * FROM fact1;
, fact2 as (
SELECT * 
FROM fact1
UNPIVOT (  treatment_count FOR clinical_treatment IN (
                                                        C_fissure_sealants,
                                                        D_radiographs,
                                                        E_endodontic,
                                                        F_perm_fill,
                                                        G_extraction,
                                                        H_crowns,
                                                        M_veneers,
                                                        N_inlays,
                                                        O_bridges,
                                                        W_non_molar,
                                                        X_molar,
                                                        Y_adv_perio_sextants
                                                    )
        )
)
--SELECT * FROM fact2;
SELECT  * 
FROM fact2
PIVOT ( SUM(treatment_count)    FOR treatment_charge_band_comb IN (
                                                            'Band 1'     as Band_1, 
                                                            'Band 2'     as Band_2,
                                                            'Band 2a'    as Band_2a,
                                                            'Band 2b'    as Band_2b,
                                                            'Band 2c'    as Band_2c,
                                                            'Band 3'     as Band_3,
                                                            'Urgent Treatment' as Urgent
                                                        ) 
)
ORDER BY treatment_year DESC, clinical_treatment
;  

