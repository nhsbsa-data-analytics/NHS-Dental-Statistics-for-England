# custom functions not needed 
# as data already in final format for column names, totals, percentages etc

# Import data from SQL queries -------------------------------------------------
#code commented out while switching to direct table import from warehouse

# geo_data <- import_geog_tables(filepath = "",
#                               con = nhsbsaR::con_nhsbsa(dsn = "FBS_8192k",
#                                                    driver = "Oracle in OraClient19Home1",
#                                                    "DWCP"))
# Check data has been imported
#geo_data$GEOG_TABLE_1A |> View()

# aggregate NHS region population by ageband 
# up to adults (18 and over) or children (17 and under)

# TO DO: create loop or similar code to extract/rename objects more efficiently
# store data from list as objects for use later 

#code commented out while switching to direct table import from warehouse

# geo_table1a <- geo_data$GEOG_TABLE_1A
# geo_table1b <- geo_data$GEOG_TABLE_1B
# geo_table1c <- geo_data$GEOG_TABLE_1C
# geo_table1d <- geo_data$GEOG_TABLE_1D
# geo_table1e <- geo_data$GEOG_TABLE_1E
# geo_table1f <- geo_data$GEOG_TABLE_1F
# geo_table2a <- geo_data$GEOG_TABLE_2A
# geo_table2b <- geo_data$GEOG_TABLE_2B
# geo_table2c <- geo_data$GEOG_TABLE_2C
# geo_table2d <- geo_data$GEOG_TABLE_2D
# geo_table2e <- geo_data$GEOG_TABLE_2E
# geo_table2f <- geo_data$GEOG_TABLE_2F
# geo_table3a <- geo_data$GEOG_TABLE_3A
# geo_table3b <- geo_data$GEOG_TABLE_3B
# geo_table3c <- geo_data$GEOG_TABLE_3C

#TO DO: put table import into function/loop

geo_table1a_import <- import_table("DENTAL_GEO_CONT_TABLE1A_2425")
geo_table1ai_import <- import_table("DENTAL_GEO_CONT_TABLE1AI_2425")
geo_table1b_import <- import_table("DENTAL_GEO_CONT_TABLE1B_2425")
geo_table1bi_import <- import_table("DENTAL_GEO_CONT_TABLE1BI_2425")
geo_table1c_import <- import_table("DENTAL_GEO_CONT_TABLE1C_2425")
geo_table1ci_import <- import_table("DENTAL_GEO_CONT_TABLE1CI_2425")
geo_table1d_import <- import_table("DENTAL_GEO_CONT_TABLE1D_2425")
geo_table1e_import <- import_table("DENTAL_GEO_CONT_TABLE1E_2425")
geo_table1f_import <- import_table("DENTAL_GEO_CONT_TABLE1F_2425")
geo_table2a_import <- import_table("DENTAL_GEO_CONT_TABLE2A_2425")
geo_table2b_import <- import_table("DENTAL_GEO_CONT_TABLE2B_2425")
geo_table2c_import <- import_table("DENTAL_GEO_CONT_TABLE2C_2425")
geo_table2d_import <- import_table("DENTAL_GEO_CONT_TABLE2D_2425")
geo_table2e_import <- import_table("DENTAL_GEO_CONT_TABLE2E_2425")
geo_table2f_import <- import_table("DENTAL_GEO_CONT_TABLE2F_2425")
geo_table3a_import <- import_table("DENTAL_GEO_CONT_TABLE3A_2425")
geo_table3b_import <- import_table("DENTAL_GEO_CONT_TABLE3B_2425")
geo_table3c_import <- import_table("DENTAL_GEO_CONT_TABLE3C_2425")

#Addition formatting for DCP breakdown tables

#Table 1ai

geo_table1ai <- geo_table1ai_import |>
  filter(between(TREATMENT_YEAR, "2022/2023", last_year)) |>
  select(!TOTAL) |>
  mutate(DCP =
           recode(DCP,
                  "0 - All"          = "All",
                  "DCP-led"          = "DCP-led",
                  "DCP-assisted"     = "DCP-assisted",
                  "Non-DCP led and not DCP assisted" = "Non-DCP led and not DCP assisted"),
         DCP_TYPE = 
           recode(DCP_TYPE,
                  "0 - All"          = "All",
                  "Dental Hygienist" = "Dental Hygienist",
                  "Dental Therapist" = "Dental Therapist",
                  "Other" = "Other")) |>
  arrange(desc(TREATMENT_YEAR),
          ODS_CODE,
#          QUARTER,
          DCP,
          DCP_TYPE) |>
  rename(
    "Financial year" = TREATMENT_YEAR,
#    "Quarter" = QUARTER, #if importing quarterly table
    "ONS code" = ONS_CODE,
    "ODS code" = ODS_CODE,
    "Region name" = REGION_NAME,
    "DCP status" = DCP,
    "DCP type" = DCP_TYPE,
    "Band 1"  = BAND_1,
    "Band 2"  = BAND_2,
    "Band 2a" = BAND_2A,
    "Band 2b" = BAND_2B,
    "Band 2c" = BAND_2C,
    "Band 3"  = BAND_3,
    "Urgent"  = URGENT,
    "Free"    = FREE,
    "Regulation 11 Replacement Appliance" = REG_11_REP_APP
  ) 

## Insert a new Total column
geo_table1ai <- append_total_column_1_to_6(geo_table1ai) 

#Table 1bi

geo_table1bi <- geo_table1bi_import |>
  filter(between(TREATMENT_YEAR, "2022/2023", last_year)) |>
  select(!(TOTAL)) |>
  mutate(DCP =
           recode(DCP,
                  "0 - All"          = "All",
                  "DCP-led"          = "DCP-led",
                  "DCP-assisted"     = "DCP-assisted",
                  "Non-DCP led and not DCP assisted" = "Non-DCP led and not DCP assisted"),
         DCP_TYPE = 
           recode(DCP_TYPE,
                  "0 - All"          = "All",
                  "Dental Hygienist" = "Dental Hygienist",
                  "Dental Therapist" = "Dental Therapist",
                  "Other" = "Other")) |>
  arrange(desc(TREATMENT_YEAR),
          ICB_NAME,
          #          QUARTER,
          DCP,
          DCP_TYPE) |>
  rename(
    "Financial year" = TREATMENT_YEAR,
    #    "Quarter" = QUARTER, #if importing quarterly table
    "ONS code" = ONS_CODE,
    "ODS code" = ODS_CODE,
    "ICB name" = ICB_NAME,
    "DCP status" = DCP,
    "DCP type" = DCP_TYPE,
    "Band 1"  = BAND_1,
    "Band 2"  = BAND_2,
    "Band 2a" = BAND_2A,
    "Band 2b" = BAND_2B,
    "Band 2c" = BAND_2C,
    "Band 3"  = BAND_3,
    "Urgent"  = URGENT,
    "Free"    = FREE,
    "Regulation 11 Replacement Appliance" = REG_11_REP_APP
  ) 

## Insert a new Total column
geo_table1bi <- append_total_column_1_to_6(geo_table1bi) 

#Table 1ci

geo_table1ci <- geo_table1ci_import |>
  filter(between(TREATMENT_YEAR, "2022/2023", last_year)) |>
  select(!TOTAL) |>
  mutate(DCP =
           recode(DCP,
                  "0 - All"          = "All",
                  "DCP-led"          = "DCP-led",
                  "DCP-assisted"     = "DCP-assisted",
                  "Non-DCP led and not DCP assisted" = "Non-DCP led and not DCP assisted"),
         DCP_TYPE = 
           recode(DCP_TYPE,
                  "0 - All"          = "All",
                  "Dental Hygienist" = "Dental Hygienist",
                  "Dental Therapist" = "Dental Therapist",
                  "Other" = "Other")) |>
  arrange(desc(TREATMENT_YEAR),
          ONS_CODE,
          #          QUARTER,
          DCP,
          DCP_TYPE) |>
  rename(
    "Financial year" = TREATMENT_YEAR,
    #    "Quarter" = QUARTER, #if importing quarterly table
    "ONS code" = ONS_CODE,
    "Local Authority name" = LAD_NAME,
    "DCP status" = DCP,
    "DCP type" = DCP_TYPE,
    "Band 1"  = BAND_1,
    "Band 2"  = BAND_2,
    "Band 2a" = BAND_2A,
    "Band 2b" = BAND_2B,
    "Band 2c" = BAND_2C,
    "Band 3"  = BAND_3,
    "Urgent"  = URGENT,
    "Free"    = FREE,
    "Regulation 11 Replacement Appliance" = REG_11_REP_APP
  ) 

## Insert a new Total column
geo_table1ci <- append_total_column_1_to_6(geo_table1ci) 

#Add population data to tables 3d, 3e, 3f and calculate % of population columns
#from population data loaded in main pipeline

#population estimates at ICB and Region level not available for mid-year 2023 or 2024
#use 2022 mid-year estimates instead for these levels

#Table 3d
geo_table3d <- geo_table3a_import |>
  dplyr::left_join(nhser_pop_child_adult_ltst, by = c("ONS code" = "NHSER_CODE")) |>
  tidyr::pivot_wider(names_from = "CHILD_ADULT",
                     values_from = "POPULATION") |>
  dplyr::mutate(`Provisional adult percent` = (`Adults seen`/ADULT * 100),
                `Provisional child percent` = (`Children seen`/CHILD * 100)) |>
  dplyr::rename(`Adult population` = `ADULT`,
                `Child population` = `CHILD`) |>
  dplyr::select (-c(FINANCIAL_YEAR,
                    NHSER_NAME,
                    `Adults seen`,
                    `Children seen`)) |>
  dplyr::select(`Financial year`,
                `ONS code`,
                `ODS code`,
                `Region name`,
                `Mid-year population year` = CALENDAR_YEAR,
                `Adult population`,
                `Child population`,
                `Provisional adult percent`,
                `Provisional child percent`)
  
#Table 3e
geo_table3e <- geo_table3b_import |>
  dplyr::left_join(icb_pop_child_adult_ltst, by = c("ONS code" = "ICB_CODE")) |>
  #remove H and J commissioners as no population available
  dplyr::filter(! `ODS code` %in% c("HJ1",
                              "HJ2",
                              "HJ3",
                              "HJ4",
                              "HJ5",
                              "HJ6",
                              "HJ7")) |>
  tidyr::pivot_wider(names_from = "CHILD_ADULT",
                     values_from = "POPULATION") |>
  dplyr::mutate(`Provisional adult percent` = (`Adults seen`/ADULT * 100),
                `Provisional child percent` = (`Children seen`/CHILD * 100)) |>
  dplyr::rename(`Adult population` = `ADULT`,
                `Child population` = `CHILD`) |>
  dplyr::select (-c(FINANCIAL_YEAR,
                    ICB_NAME,
                    `Adults seen`,
                    `Children seen`)) |>
  dplyr::select(`Financial year`,
                `ONS code`,
                `ODS code`,
                `ICB name`,
                `Mid-year population year` = CALENDAR_YEAR,
                `Adult population`,
                `Child population`,
                `Provisional adult percent`,
                `Provisional child percent`)

#Table 3f
geo_table3f <- geo_table3c_import |>
  dplyr::left_join(la_pop_child_adult_ltst, by = c("Financial year" = "FINANCIAL_YEAR",
                                              "ONS code" = "LA_CODE")) |>
  tidyr::pivot_wider(names_from = "CHILD_ADULT",
                     values_from = "POPULATION") |>
  dplyr::mutate(`Adult percent` = (`Adults seen`/ADULT * 100),
                `Child percent` = (`Children seen`/CHILD * 100)) |>
  dplyr::rename(`Adult population` = `ADULT`,
                `Child population` = `CHILD`) |>
  dplyr::select (-c(LA_NAME,
                    `Adults seen`,
                    `Children seen`)) |>
  dplyr::select(`Financial year`,
                `ONS code`,
                `Local Authority name`,
                `Mid-year population year` = CALENDAR_YEAR,
                `Adult population`,
                `Child population`,
                `Adult percent`,
                `Child percent`)