-------------------------------------------------------------------------------------------------------
-- DENTAL National Activity Table 5a
--------------------------------------------------------------------------------------------------------

--updated to add adv_perio_count (advanced perio RSD clinical item, requested by NHSE)

DROP TABLE dental_national_table5a_2425;

CREATE TABLE dental_national_table5a_2425 AS
WITH
fact1 AS (   
SELECT treatment_year,
       treatment_charge_band_comb,
       SUM(scale_polish_count)          as A_scale_polish_count,       
       SUM(fv_count)                    as B_fluoride_varnish_count,  
       SUM(fs_count)                    as C_fissure_sealants_count,
       SUM(radiographs_count)           as D_radiographs_count,
       SUM(endo_trt_count)              as E_endodontic_count,
       SUM(perm_fill_count)             as F_perm_fill_count,
       SUM(extra_gen_count)             as G_extraction_count,
       SUM(crowns_count)                as H_crowns_count,
       SUM(upper_acrylic_count)         as I_upper_acrylic_count,
       SUM(lower_acrylic_count)         as J_lower_acrylic_count,
       SUM(upper_metal_count)           as K_upper_metal_count,
       SUM(lower_metal_count)           as L_lower_metal_count,
       SUM(veneers_count)               as M_veneers_count,
       SUM(inlays_count)                as N_inlays_count,
       SUM(bridges_count)               as O_bridges_count,
       SUM(ams_count)         as P_ref_for_adv_man_serv_2, 
       SUM(exam_count)           as Q_examination_count,
       SUM(anti_count)           as R_antibiotics_count,
       SUM(other_count)       as S_other_count,
       SUM(custom_hard_bite)     as T_hard_occl_splint_count,
       SUM(custom_soft_bite)     as U_biteguard_count,
       SUM(denture_add_rel_reb)   as V_add_trt_base_denture_count,
       SUM(non_molar_count)             as W_non_molar_count,
       SUM(molar_count)                 as X_molar_count,
       SUM(adv_perio_count)                   as Y_adv_perio_count
FROM OST.DS_CONT_CLINICAL_FACT_2425
--FROM dental_national_activity_fact_inc_contras -- for comparison with NHSE publication
WHERE 1=1
--AND form_type = 'G' -- seems to make no difference
--AND uda <> 0                        -- **  double check if this is needed **
AND adult_child_ind = 'Adult'
--AND adult_child_at_doa = 'A'         -- ** alternative ways to select adults, but adult_child_ind should be correct **
--AND age_at_period_end >= 18
AND treatment_charge_band_comb IN ('Band 1', 'Band 2', 'Band 2a', 'Band 2b', 'Band 2c', 'Band 3', 'Urgent Treatment')
--AND quarter != 'unallocated_1'  -- **  table not built with unallocated for quarter, but kept to catch anything unusual **
AND quarter != 'unallocated_2'
--AND treatment_year BETWEEN '2018/2019' AND '2023/2024' -- for testing only
GROUP BY treatment_year,  treatment_charge_band_comb
ORDER BY treatment_year DESC, treatment_charge_band_comb
)
--SELECT * FROM fact1;
, fact2 as (
SELECT * 
FROM fact1
UNPIVOT (  treatment_count FOR clinical_treatment IN (
                                                        A_scale_polish_count,       
                                                        B_fluoride_varnish_count,  
                                                        C_fissure_sealants_count,
                                                        D_radiographs_count,
                                                        E_endodontic_count,
                                                        F_perm_fill_count,
                                                        G_extraction_count,
                                                        H_crowns_count,
                                                        I_upper_acrylic_count,
                                                        J_lower_acrylic_count,
                                                        K_upper_metal_count,
                                                        L_lower_metal_count,
                                                        M_veneers_count,
                                                        N_inlays_count,
                                                        O_bridges_count,
                                                        P_ref_for_adv_man_serv_2,
                                                        Q_examination_count,
                                                        R_antibiotics_count,
                                                        S_other_count,
                                                        T_hard_occl_splint_count,
                                                        U_biteguard_count,
                                                        V_add_trt_base_denture_count,
                                                        W_non_molar_count,
                                                        X_molar_count,
                                                        Y_adv_perio_count
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

