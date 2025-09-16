----------------------------------------------------------------------------------------------------------------------------------------
-- DENTAL Run scripts for all tables
----------------------------------------------------------------------------------------------------------------------------------------

-- NOTES
-- 1. For this script to run successfuly this script and all the table scripts much be in the same folder.
-- 2. The table DS_CONT_ACTIVITY_FACT for the relevant time period (eg. DS_CONT_ACTIVITY_FACT_2425) must be created before using this script.
-- 3. The table DS_CONT_CLINICAL_FACT for the relevant time period (eg. DS_CONT_CLINICAL_FACT_2425) must be created before using this script.
-- 4. The table DS_CONT_ORTHO_FACT for the relevant time period (eg. DS_CONT_ORTHO_FACT_2425) must be created before using this script.
-- 5. The table DS_CONT_PAT_CHARGE_FACT for the relevant time period (eg. DS_CONT_PAT_CHARGE_FACT_2425) must be created before using this script.
-- 6. All of the table scripts must have the DROP and CREATE TABLE commands uncommented.

@@Dental_National_Table_1a_2425;
@@Dental_National_Table_1c_2425;
@@Dental_National_Table_1f_2425;
@@Dental_National_Table_1g_2425;
@@Dental_National_Table_2a_2425;
@@Dental_National_Table_2c_2425;
@@Dental_National_Table_2g_2425;
@@Dental_National_Table_3a_2425;
@@Dental_National_Table_4a_2425;
@@Dental_National_Table_4c_2425;
@@Dental_National_Table_5a_2425;
@@Dental_National_Table_5b_2425;
@@Dental_National_Table_5c_2425;
@@Dental_National_Table_5d_2425;
@@Dental_National_Table_6a_2425;
@@Dental_National_Table_6c_2425;

--TO DO add geo contract tables below

--@@DS_GEOG_TABLE_1A_2425 --example

--TO DO add geo patient tables below

--@@dental_geo_pat_table1a_2425 --example

--amend grant statement as required

-- GRANT SELECT ON dental_national_table1a_2425 TO EXAMPLE_USER; -- example





