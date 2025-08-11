#script to import contract location activity tables to build national excel files
#to be called in main `pipeline.R` script
#additional functions loaded in main pipeline

#use SQL scripts from \sql folder in repository

# Define Custom Functions --------------------------------------------------
import_table <-
  function(TB) {
    dplyr::tbl(src = con, dbplyr::in_schema("OST", TB)) |> collect()
  }

append_total_column_1    <-
  function(TB) {
    cbind(TB, Total = rowSums(TB[, c(-1)],     na.rm = TRUE))
  }
append_total_column_12   <-
  function(TB) {
    cbind(TB, Total = rowSums(TB[, c(-1,-2)],    na.rm = TRUE))
  }
append_total_column_123  <-
  function(TB) {
    cbind(TB, Total = rowSums(TB[, c(-1,-2,-3)], na.rm = TRUE))
  }
append_total_column_12345  <-
  function(TB) {
    cbind(TB, Total = rowSums(TB[, c(-1,-2,-3, -4, -5)], na.rm = TRUE))
  }
append_total_column_1_to_6  <-
  function(TB) {
    cbind(TB, Total = rowSums(TB[, c(-1,-2,-3, -4, -5, -6)], na.rm = TRUE))
  }
append_total_column_1_to_8  <-
  function(TB) {
    cbind(TB, Total = rowSums(TB[, c(-1,-2,-3, -4, -5, -6, -7, -8)], na.rm = TRUE))
  }

percentage_table_1  <-
  function(TB) {
    cbind(TB[, 1],      TB[,-1] / TB$Total * 100)
  }
percentage_table_12 <-
  function(TB) {
    cbind(TB[, c(1, 2)], TB[, c(-1,-2)] / TB$Total * 100)
  }

# percentage_table_1 has trouble with naming the first col correctly

# Import tables created in SQL --------------------------------------------------

table1a_import <- import_table("DENTAL_NATIONAL_TABLE1A_2425")
table1c_import <- import_table("DENTAL_NATIONAL_TABLE1C_2425")
table1f_import <- import_table("DENTAL_NATIONAL_TABLE1F_2425")
table1g_import <- import_table("DENTAL_NATIONAL_TABLE1G_2425") # DCP COT split
table2a_import <- import_table("DENTAL_NATIONAL_TABLE2A_2425")
table2c_import <- import_table("DENTAL_NATIONAL_TABLE2C_2425")
table3a_import <- import_table("DENTAL_NATIONAL_TABLE3A_2425")
table4a_import <- import_table("DENTAL_NATIONAL_TABLE4A_2425")
table4c_import <- import_table("DENTAL_NATIONAL_TABLE4C_2425")
table5a_import <- import_table("DENTAL_NATIONAL_TABLE5A_2425")
table5b_import <- import_table("DENTAL_NATIONAL_TABLE5B_2425")
table5c_import <- import_table("DENTAL_NATIONAL_TABLE5C_2425")
table5d_import <- import_table("DENTAL_NATIONAL_TABLE5D_2425")
table6a_import <- import_table("DENTAL_NATIONAL_TABLE6A_2425")
table6c_import <- import_table("DENTAL_NATIONAL_TABLE6C_2425")

# Table_1a --------------------------------------------------

## Drop unwanted years and cols, replace Quarter with Year-Quarter, re-order cols, and rename cols
table1a <- table1a_import |>
  filter(between(TREATMENT_YEAR, first_year, last_year)) |>
  select(!TOTAL) |>
  unite("Financial Quarter",
        c(TREATMENT_YEAR, QUARTER),
        sep = " ",
        remove = FALSE)  |>
  select(TREATMENT_YEAR, everything()) |>
  rename(
    "Financial Year" = TREATMENT_YEAR,
    "Quarter" = QUARTER,
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
table1a <- append_total_column_123(table1a)

## Split into Table_1a_i (quarters) and Table_1a_ii (years)
table1aii  <-
  table1a |> filter (Quarter != "All") |> select (!Quarter)
table1ai <-
  table1a |> filter (Quarter == "All") |> select (!c(Quarter, "Financial Quarter"))

# Table 1c --------------------------------------------------
## Drop unwanted years and cols, re-code charge_status col, and rename cols
table1c <- table1c_import |>
  filter(between(TREATMENT_YEAR, first_year, last_year)) |>
  select(!TOTAL) |>
  # mutate(
  #   PATIENT_CHARGE_STATUS = recode(
  #     PATIENT_CHARGE_STATUS,
  #     "0 - All"         = "All",
  #     "Non-Exempt"  = "Paying adult",
  #     "Exempt"      = "Non-paying adult",
  #     "Child"       = "Child"
  #   )
  # ) |>
  mutate(
    PATIENT_CHARGE_STATUS = recode(
      PATIENT_CHARGE_STATUS,
      "0 - All"         = "All",
      "Non-Exempt"  = "Non-Exempt",
      "Exempt"      = "Exempt",
      "Child"       = "Child"
    )
  ) |>
  rename(
    "Financial Year" = TREATMENT_YEAR,
    "Patient_Type"   = PATIENT_CHARGE_STATUS,
    ## leaving the underscore in for now, removed below
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
table1c <- append_total_column_12(table1c)

## Split into Table_1c_i (patient-types) and Table_1c_ii (all)
table1c_excel  <-
  table1c |> filter (Patient_Type != "All") |> rename("Patient Type" = Patient_Type)

# Table1e_uda  --------------------------------------------------

## Tables 1e are created from Table 1c
## Note that Table1e_uda is not currently published, but is created here to be the basis for Table1e (percentages).
## Note that it is necessary to run the above code for arranging table1c before running the following code successfully.

# Create Table1ei_uda
table1ei_cot <- table1c |>
  filter(Patient_Type != "All") |>
  select(!"Total") |>
  pivot_longer(
    c(
      "Band 1",
      "Band 2",
      "Band 2a",
      "Band 2b",
      "Band 2c",
      "Band 3",
      "Urgent",
      "Free",
      "Regulation 11 Replacement Appliance"
    ),
    names_to = "Treatment_Band",
    values_to = "COT"
  ) |>
  pivot_wider(names_from = Patient_Type, values_from = "COT")

# Create Table1eii_uda
table1eii_cot <- table1c |>
  filter(Patient_Type != "All") |>
  select("Financial Year", "Patient_Type", "Total") |>
  pivot_wider(names_from = Patient_Type, values_from = "Total")

# Append totals columns
table1ei_cot  <- append_total_column_12(table1ei_cot)
table1eii_cot <- append_total_column_1(table1eii_cot)

# Table 1f --------------------------------------------------
## Drop unwanted years and cols, re-code charge_status col, and rename cols
table1f <- table1f_import |>
  filter(between(TREATMENT_YEAR, first_year, last_year)) |>
#  select(!TOTAL) |>
  mutate(
    EXEMPTION_DESC = recode(
      EXEMPTION_DESC,
      "0 - All"         = "All",
      "Adult in receipt of Income Support"  = "Income Support",
      "Adult in receipt of Universal Credit" = "Universal Credit",
      "Adult in receipt of income-based Jobseeker's Allowance (JSA)" = "Income-based Jobseeker's Allowance",
      "Adult in receipt of income-related Employment and Support Allowance (ESA)" = "Income-related Employment and Support Allowance",
      "Aged 18 and in full-time education"  = "Aged 18 and in full-time education",
      "Child (under 18)" = "Child",
      "Expectant mother" = "Expectant mother",
      "In Prison or a Young Offender Institute" = "In prison or young offender institute",
      "Named on a HC2 certificate" = "HC2 certificate",
      "Named on a HC3 certificate" = "HC3 certificate",
      "Named on a valid NHS Tax Credit Exemption certificate" = "NHS Tax Credit exemption certificate",
      "Nursing mother (had a baby in the year before treatment starts)" = "Mother of child born in the year before treatment started",
      "Paying adult" = "Paying adult",
      "Pension Credit guarantee credit (PCgc)" = "Pension Credit Guarantee"
    )
  ) |>
  rename(
    "Financial Year" = TREATMENT_YEAR,
    "Exemption Type"   = EXEMPTION_DESC,
    ## leaving the underscore in for now, removed below
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
table1f <- append_total_column_12(table1f)

# Table 1g ----------------------------------------------------------------------

#new table for 2024/24 release, Dental Care Professional (DCP) COT split by treatment band
#and whether activity was DCP-led, DCP-assisted, or not DCP led and not DCP assisted

## Drop unwanted years and cols, replace Quarter with Year-Quarter, re-order cols, and rename cols
table1g <- table1g_import |>
#  filter(between(TREATMENT_YEAR, first_year, last_year)) |>
  filter(between(TREATMENT_YEAR, "2022/2023", last_year)) |>
  select(!TOTAL) |>
  unite("Financial Quarter",
        c(TREATMENT_YEAR, QUARTER),
        sep = " ",
        remove = FALSE)  |>
  select(TREATMENT_YEAR, everything()) |>
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
               QUARTER,
               DCP,
               DCP_TYPE) |>
  rename(
    "Financial Year" = TREATMENT_YEAR,
    "Quarter" = QUARTER,
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
table1g <- append_total_column_12345(table1g)

## Split into Table_1g_i (quarters) and Table_1g_ii (years)

table1gi <-
  table1g |> filter (Quarter == "All") |> select (!c(Quarter, "Financial Quarter"))

table1gii  <-
  table1g |> filter (Quarter != "All") |> select (!Quarter) 

# Table_2a --------------------------------------------------

## Drop unwanted years and cols, replace Quarter with Year-Quarter, re-order cols, and rename cols
table2a <- table2a_import |>
  filter(between(TREATMENT_YEAR, first_year, last_year)) |>
  select(!TOTAL) |>
  unite("Financial Quarter",
        c(TREATMENT_YEAR, QUARTER),
        sep = " ",
        remove = FALSE)  |>
  select(TREATMENT_YEAR, everything()) |>
  rename(
    "Financial Year" = TREATMENT_YEAR,
    "Quarter" = QUARTER,
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
table2a <- append_total_column_123(table2a)

## Split into Table_2a_i (quarters) and Table_2a_ii (years)
table2aii  <-
  table2a |> filter (Quarter != "All") |> select (!Quarter)
table2ai <-
  table2a |> filter (Quarter == "All") |> select (!c(Quarter, "Financial Quarter"))

# Table 2c --------------------------------------------------
## Drop unwanted years and cols, re-code charge_status col, and rename cols
table2c <- table2c_import |>
  filter(between(TREATMENT_YEAR, first_year, last_year)) |>
  select(!TOTAL) |>
  mutate(
    CHARGE_STATUS = recode(
      CHARGE_STATUS,
      "0 - All"         = "All",
      "1 - Non-Exempt"  = "Non-Exempt",
      "2 - Exempt"      = "Exempt",
      "3 - Child"       = "Child"
    )
  ) |>
  rename(
    "Financial Year" = TREATMENT_YEAR,
    "Patient_Type"   = CHARGE_STATUS,
    ## leaving the underscore in for now, removed below
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
table2c <- append_total_column_12(table2c)

## Split into Table_2c_i (patient-types) and Table_2c_ii (all)
table2c_excel  <-
  table2c |> filter (Patient_Type != "All") |> rename("Patient Type" = Patient_Type)

# Table2e_uda  --------------------------------------------------

## Tables2e are created from Table 2c
## Note that Table2e_uda is not currently published, but is created here to be the basis for Table2e (percentages).
## Note that is is necessary to run the above code for arranging table2c before running the following code successfully.

# Create Table2ei_uda
table2ei_uda <- table2c |>
  filter(Patient_Type != "All") |>
  select(!"Total") |>
  pivot_longer(
    c(
      "Band 1",
      "Band 2",
      "Band 2a",
      "Band 2b",
      "Band 2c",
      "Band 3",
      "Urgent",
      "Free",
      "Regulation 11 Replacement Appliance"
    ),
    names_to = "Treatment_Band",
    values_to = "UDA"
  ) |>
  pivot_wider(names_from = Patient_Type, values_from = "UDA")

# Create Table2eii_uda
table2eii_uda <- table2c |>
  filter(Patient_Type != "All") |>
  select("Financial Year", "Patient_Type", "Total") |>
  pivot_wider(names_from = Patient_Type, values_from = "Total")

# Append totals columns
table2ei_uda  <- append_total_column_12(table2ei_uda)
table2eii_uda <- append_total_column_1(table2eii_uda)

# Table 3a --------------------------------------------------
## Remove unwanted years and cols, and rename cols
table3a <- table3a_import |>
  filter(between(TREATMENT_YEAR, first_year, last_year)) |>
  rename("Financial Year" = TREATMENT_YEAR,
         "Units of Orthodontic Activity" = UOA)

# Table 4a --------------------------------------------------
## Drop unwanted years, rename cols, create new date col, drop old date col, re-order cols
table4a <- table4a_import |>
  filter(between(
    YEAR_MONTH_LAST_DAY,
    first_patients_seen_date,
    last_patients_seen_date
  )) |>
  rename(
    "Date2"  = YEAR_MONTH_LAST_DAY,
    "18-64"  = AGE_18_64,
    "65-74"  = AGE_65_74,
    "75-84"  = AGE_75_84,
    "85+"    = AGE_85_PLUS,
    "Total"  = TOTAL
  )     |>
  mutate(Date = paste(mday(Date2), lubridate::month(Date2, label =
                                           TRUE), year(Date2) , sep = " ")) |>
  select(!Date2) |>
  select(Date, everything())


# Table 4b --------------------------------------------------

table_4b_population <- eng_pop_age |>
  filter(adult_child != "Child") |>
  select(-adult_child,-country) |>
  mutate(age_band = paste0(age_band, " Population")) |>
  pivot_wider(names_from = c(age_band),
              values_from = c(population))

table4b <- table4a |>
  #get CY from date for joining
  mutate(CY = as.numeric(year(
    as.Date(Date, format = "%d %B %Y") %m-% months(3)
  ))) |>
  left_join(table_4b_population,
            by = c("CY" = "calendar_year")) |>
  mutate(
    `18-64 Population` = na.locf(`18-64 Population`, fromLast = TRUE),
    `65-74 Population` = na.locf(`65-74 Population`, fromLast = TRUE),
    `75-84 Population` = na.locf(`75-84 Population`, fromLast = TRUE),
    `85+ Population` = na.locf(`85+ Population`, fromLast = TRUE),
    `Total Population` = `18-64 Population` + `65-74 Population` + `75-84 Population` + `85+ Population`
  ) |>
  #calculate proportions
  mutate(
    `18-64` = `18-64` / `18-64 Population` * 100,
    `65-74` = `65-74` / `65-74 Population` * 100,
    `75-84` = `75-84` / `75-84 Population` * 100,
    `85+` = `85+` / `85+ Population` * 100,
    `Total` = `Total` / `Total Population` * 100
  ) |>
  select(
    Date,
    `18-64 Population`,
    `65-74 Population`,
    `75-84 Population`,
    `85+ Population`,
    `Total Population`,
    `18-64`,
    `65-74`,
    `75-84`,
    `85+`,
    Total
  )

# Table 4c --------------------------------------------------
## Drop unwanted years, rename cols, create new date col, drop old date col, re-order cols
table4c <- table4c_import |>
  filter(between(
    YEAR_MONTH_LAST_DAY,
    first_patients_seen_date,
    last_patients_seen_date
  )) |>
  rename(
    "Date2"  = YEAR_MONTH_LAST_DAY,
    "0-4"    = AGE_0_4,
    "5-9"    = AGE_5_9,
    "10-14"  = AGE_10_14,
    "15-17"  = AGE_15_17,
    "Total"  = TOTAL
  ) |>
  mutate(Date = paste(mday(Date2), lubridate::month(Date2, label =
                                           TRUE), year(Date2) , sep = " ")) |>
  select(!Date2) |>
  select(Date, everything())


# Table 4d --------------------------------------------------

table_4d_population <- eng_pop_age |>
  filter(adult_child != "Adult") |>
  select(-adult_child,-country) |>
  mutate(age_band = paste0(age_band, " Population")) |>
  pivot_wider(names_from = c(age_band),
              values_from = c(population)) |>
  rename("0-4 Population" = 3,
         "5-9 Population" = 4)

# NOTE: work to do --------------------------------------------------
table4d <- table4c |>
  # get CY from date for joining
  mutate(CY = as.numeric(year(
    as.Date(Date, format = "%d %B %Y") %m-% months(3)
  ))) |>
  left_join(table_4d_population,
            by = c("CY" = "calendar_year")) |>
  mutate(
    `0-4 Population` = na.locf(`0-4 Population`, fromLast = TRUE),
    `5-9 Population` = na.locf(`5-9 Population`, fromLast = TRUE),
    `10-14 Population` = na.locf(`10-14 Population`, fromLast = TRUE),
    `15-17 Population` = na.locf(`15-17 Population`, fromLast = TRUE),
    `Total Population` = `0-4 Population` + `5-9 Population` + `10-14 Population` + `15-17 Population`
  ) |>
  #calculate proportions
  mutate(
    `0-4` = `0-4` / `0-4 Population` * 100,
    `5-9` = `5-9` / `5-9 Population` * 100,
    `10-14` = `10-14` / `10-14 Population` * 100,
    `15-17` = `15-17` / `15-17 Population` * 100,
    `Total` = `Total` / `Total Population` * 100
  ) |>
  select(
    Date,
    `0-4 Population`,
    `5-9 Population`,
    `10-14 Population`,
    `15-17 Population`,
    `Total Population`,
    `0-4`,
    `5-9`,
    `10-14`,
    `15-17`,
    Total
  )

# Table 5a --------------------------------------------------
## Remove unwanted years, re-code clinical_treatment, rename cols
table5a <- table5a_import |>
  filter(between(TREATMENT_YEAR, first_year, last_year)) |>
  mutate(
    CLINICAL_TREATMENT = recode(
      CLINICAL_TREATMENT,
      "A_SCALE_POLISH_COUNT"          =  "Scale and polish",
      "B_FLUORIDE_VARNISH_COUNT"      =  "Fluoride varnish",
      "C_FISSURE_SEALANTS_COUNT"      =  "Fissure sealants",
      "D_RADIOGRAPHS_COUNT"           =  "Radiograph(s)",
      "E_ENDODONTIC_COUNT"            =  "Endodontic treatment",
      "F_PERM_FILL_COUNT"             =  "Permanent fillings and sealant restorations",
      "G_EXTRACTION_COUNT"            =  "Extraction(s)",
      "H_CROWNS_COUNT"                =  "Crown(s)",
      "I_UPPER_ACRYLIC_COUNT"         =  "Upper denture - acrylic",
      "J_LOWER_ACRYLIC_COUNT"         =  "Lower denture - acrylic",
      "K_UPPER_METAL_COUNT"           =  "Upper denture - metal",
      "L_LOWER_METAL_COUNT"           =  "Lower denture - metal",
      "M_VENEERS_COUNT"               =  "Veneer(s)",
      "N_INLAYS_COUNT"                =  "Inlay(s)",
      "O_BRIDGES_COUNT"               =  "Bridge(s)",
      "P_REF_FOR_ADV_MAN_SERV_2"      =  "Referral for advanced mandatory services",
      "Q_EXAMINATION_COUNT"           =  "Examination",
      "R_ANTIBIOTICS_COUNT"           =  "Antibiotic items prescribing",
      "S_OTHER_COUNT"                 =  "Other treatment",
      "T_HARD_OCCL_SPLINT_COUNT"      =  "Hard oclusal splint",
      "U_BITEGUARD_COUNT"             =  "Soft oclusal splint (biteguard)",
      "V_ADD_TRT_BASE_DENTURE_COUNT"  = "Additional treatment to base of denture",
      "W_NON_MOLAR_COUNT"             = "Endodontic treatment - non molar",
      "X_MOLAR_COUNT"                 = "Endodontic treatment - molar",
      "Y_ADV_PERIO_COUNT"             = "Advanced perio RSD"
      
    )
  ) |>
  rename(
    "Financial Year" = TREATMENT_YEAR,
    "Clinical Treatment" = CLINICAL_TREATMENT,
    "Band 1"  = BAND_1,
    "Band 2"  = BAND_2,
    "Band 2a" = BAND_2A,
    "Band 2b" = BAND_2B,
    "Band 2c" = BAND_2C,
    "Band 3"  = BAND_3,
    "Urgent"  = URGENT
  )

## Insert a new Total column
table5a <- append_total_column_12(table5a)

# Table 5b --------------------------------------------------
## Remove unwanted years, re-code clinical_treatment, rename cols
table5b <- table5b_import |>
  filter(between(TREATMENT_YEAR, first_year, last_year))  |>
  mutate(
    CLINICAL_TREATMENT = recode(
      CLINICAL_TREATMENT,
      "C_FISSURE_SEALANTS"      =  "Fissure sealants",
      "D_RADIOGRAPHS"           =  "Radiograph(s)",
      "E_ENDODONTIC"            =  "Endodontic treatment",
      "F_PERM_FILL"             =  "Permanent fillings and sealant restorations",
      "G_EXTRACTION"            =  "Extraction(s)",
      "H_CROWNS"                =  "Crown(s)",
      "M_VENEERS"               =  "Veneer(s)",
      "N_INLAYS"                =  "Inlay(s)",
      "O_BRIDGES"               =  "Bridge(s)",
      "W_NON_MOLAR"             = "Endodontic treatment - non molar",
      "X_MOLAR"                 = "Endodontic treatment - molar",
      "Y_ADV_PERIO_SEXTANTS"    = "Advanced perio RSD sextants"
    )
  )   |>
  rename(
    "Financial Year"     = TREATMENT_YEAR,
    "Clinical Treatment" = CLINICAL_TREATMENT,
    "Band 1"  = BAND_1,
    "Band 2"  = BAND_2,
    "Band 2a" = BAND_2A,
    "Band 2b" = BAND_2B,
    "Band 2c" = BAND_2C,
    "Band 3"  = BAND_3,
    "Urgent"  = URGENT
  )

## Insert a new Total column
table5b <- append_total_column_12(table5b)

# Table 5c --------------------------------------------------
## Remove unwanted years, re-code clinical_treatment, rename cols
table5c <- table5c_import |>
  filter(between(TREATMENT_YEAR, first_year, last_year))  |>
  mutate(
    CLINICAL_TREATMENT = recode(
      CLINICAL_TREATMENT,
      "A_SCALE_POLISH_COUNT"          =  "Scale and polish",
      "B_FLUORIDE_VARNISH_COUNT"      =  "Fluoride varnish",
      "C_FISSURE_SEALANTS_COUNT"      =  "Fissure sealants",
      "D_RADIOGRAPHS_COUNT"           =  "Radiograph(s)",
      "E_ENDODONTIC_COUNT"            =  "Endodontic treatment",
      "F_PERM_FILL_COUNT"             =  "Permanent fillings and sealant restorations",
      "G_EXTRACTION_COUNT"            =  "Extraction(s)",
      "H_CROWNS_COUNT"                =  "Crown(s)",
      "I_UPPER_ACRYLIC_COUNT"         =  "Upper denture - acrylic",
      "J_LOWER_ACRYLIC_COUNT"         =  "Lower denture - acrylic",
      "K_UPPER_METAL_COUNT"           =  "Upper denture - metal",
      "L_LOWER_METAL_COUNT"           =  "Lower denture - metal",
      "M_VENEERS_COUNT"               =  "Veneer(s)",
      "N_INLAYS_COUNT"                =  "Inlay(s)",
      "O_BRIDGES_COUNT"               =  "Bridge(s)",
      "P_REF_FOR_ADV_MAN_SERV_2"      =  "Referral for advanced mandatory services",
      "Q_EXAMINATION_COUNT"           =  "Examination",
      "R_ANTIBIOTICS_COUNT"           =  "Antibiotic items prescribing",
      "S_OTHER_COUNT"                 =  "Other treatment",
      "T_HARD_OCCL_SPLINT_COUNT"      =  "Hard oclusal splint",
      "U_BITEGUARD_COUNT"             =  "Soft oclusal splint (biteguard)",
      "V_ADD_TRT_BASE_DENTURE_COUNT"  = "Additional treatment to base of denture",
      "W_NON_MOLAR_COUNT"             = "Endodontic treatment - non molar",
      "X_MOLAR_COUNT"                 = "Endodontic treatment - molar",
      "Y_ADV_PERIO_COUNT"             = "Advanced perio RSD"
      
    )
  )   |>
  rename(
    "Financial Year" = TREATMENT_YEAR,
    "Clinical Treatment" = CLINICAL_TREATMENT,
    "Band 1"  = BAND_1,
    "Band 2"  = BAND_2,
    "Band 2a" = BAND_2A,
    "Band 2b" = BAND_2B,
    "Band 2c" = BAND_2C,
    "Band 3"  = BAND_3,
    "Urgent"  = URGENT
  )

## Insert a new Total column
table5c <- append_total_column_12(table5c)

# Table 5d --------------------------------------------------
## Remove unwanted years, re-code clinical_treatment, rename cols
table5d <- table5d_import |>
  filter(between(TREATMENT_YEAR, first_year, last_year))  |>
  mutate(
    CLINICAL_TREATMENT = recode(
      CLINICAL_TREATMENT,
      "C_FISSURE_SEALANTS"      =  "Fissure sealants",
      "D_RADIOGRAPHS"           =  "Radiograph(s)",
      "E_ENDODONTIC"            =  "Endodontic treatment",
      "F_PERM_FILL"             =  "Permanent fillings and sealant restorations",
      "G_EXTRACTION"            =  "Extraction(s)",
      "H_CROWNS"                =  "Crown(s)",
      "M_VENEERS"               =  "Veneer(s)",
      "N_INLAYS"                =  "Inlay(s)",
      "O_BRIDGES"               =  "Bridge(s)",
      "W_NON_MOLAR"             = "Endodontic treatment - non molar",
      "X_MOLAR"                 = "Endodontic treatment - molar",
      "Y_ADV_PERIO_SEXTANTS"    = "Advanced perio RSD sextants"
    )
  )   |>
  rename(
    "Financial Year"     = TREATMENT_YEAR,
    "Clinical Treatment" = CLINICAL_TREATMENT,
    "Band 1"  = BAND_1,
    "Band 2"  = BAND_2,
    "Band 2a" = BAND_2A,
    "Band 2b" = BAND_2B,
    "Band 2c" = BAND_2C,
    "Band 3"  = BAND_3,
    "Urgent"  = URGENT
  )

## Insert a new Total column
table5d <- append_total_column_12(table5d)

# Table 6a --------------------------------------------------
## Drop unwanted years and cols, rename cols
table6a <- table6a_import |>
  filter(between(TREATMENT_YEAR, first_year, last_year))  |>
  select(!FREE)                                          |>
  rename(
    "Financial Year" = TREATMENT_YEAR,
    "Band 1"  = BAND_1,
    "Band 2"  = BAND_2,
    "Band 2a" = BAND_2A,
    "Band 2b" = BAND_2B,
    "Band 2c" = BAND_2C,
    "Band 3"  = BAND_3,
    "Urgent"  = URGENT,
    "Regulation 11 Replacement Appliance" = REG_11_REP_APP
  ) |>
  rowwise() |>
  mutate(Total = sum(c_across(where(is.numeric)), na.rm = TRUE)) |>
  ungroup()

# Table 6c --------------------------------------------------
table6c <- table6c_import |>
  filter(between(TREATMENT_YEAR, first_year, last_year))  |>
  mutate(
    EXEMPTION_DESC = recode(
      EXEMPTION_DESC,
      "0 - All"         = "All",
      "Adult in receipt of Income Support"  = "Income Support",
      "Adult in receipt of Universal Credit" = "Universal Credit",
      "Adult in receipt of income-based Jobseeker's Allowance (JSA)" = "Income-based Jobseeker's Allowance",
      "Adult in receipt of income-related Employment and Support Allowance (ESA)" = "Income-related Employment and Support Allowance",
      "Aged 18 and in full-time education"  = "Aged 18 and in full-time education",
      "Child (under 18)" = "Child",
      "Expectant mother" = "Expectant mother",
      "In Prison or a Young Offender Institute" = "In prison or young offender institute",
      "Named on a HC2 certificate" = "HC2 certificate",
      "Named on a HC3 certificate" = "HC3 certificate",
      "Named on a valid NHS Tax Credit Exemption certificate" = "NHS Tax Credit exemption certificate",
      "Nursing mother (had a baby in the year before treatment starts)" = "Mother of child born in the year before treatment started",
      "Paying adult" = "Paying adult",
      "Pension Credit guarantee credit (PCgc)" = "Pension Credit Guarantee"
    )
  )   |>
  arrange(desc(TREATMENT_YEAR), EXEMPTION_DESC) |>
  # mutate(
  #   EXEMPTION_DESC = recode(
  #     EXEMPTION_DESC,
  #     "B - Patient under 18"                   = "Child",
  #     "C - Aged 18 in Full Time Education"     = "Aged 18 and in full time education",
  #     "D - Expectant Mother"                   = "Expectant mother",
  #     "E - Mother of child born in the last 12 months" = "Mother of child born in the year before treatment started",
  #     "F - Prisoner" = "In prison or young offender institute",
  #     "G - Income Support"                     = "Income Support",
  #     "H - Income Based Job Seekers Allowance" = "Income-based Jobseeker's Allowance",
  #     "I - Income Related Employment and Support Allowance" = "Income-related Employment and Support Allowance",
  #     "J - Universal Credit"                   = "Universal Credit",
  #     "K - Pension Credit Guarantee"           = "Pension Credit Guarantee",
  #     "L - HC2 Certifiate"                     = "HC2 certificate",
  #     "M - NHS Tax Credit Exemption"           = "NHS Tax Credit exemption certificate",
  #     "N - HC3 Certifiate"                     = "HC3 certifiate"
  #   )
  # )   |>
  rename(
    "Financial Year" = TREATMENT_YEAR,
    "Exemption Type" = EXEMPTION_DESC,
    "Band 1"  = BAND_1,
    "Band 2"  = BAND_2,
    "Band 2a" = BAND_2A,
    "Band 2b" = BAND_2B,
    "Band 2c" = BAND_2C,
    "Band 3"  = BAND_3,
    "Urgent"  = URGENT
  ) |>
  select(
    -FREE,
    -REG_11_REP_APP
  ) |>
  rowwise() |>
  mutate(Total = sum(c_across(where(is.numeric)), na.rm = TRUE)) |>
  ungroup()

#Create percentage Tables --------------------------------------------------
table1bi      <- percentage_table_1(table1ai)
table1bii     <- percentage_table_12(table1aii)
table1d <- percentage_table_12(table1c_excel)
table1ei      <-
  percentage_table_12(table1ei_cot) |> mutate_all( ~ ifelse(is.nan(.), NA, .))
table1eii     <- percentage_table_1(table1eii_cot)
table2bi      <- percentage_table_1(table2ai)
table2bii     <- percentage_table_12(table2aii)
table2d      <- percentage_table_12(table2c_excel)
table2ei      <-
  percentage_table_12(table2ei_uda) |> mutate_all( ~ ifelse(is.nan(.), NA, .))
table2eii     <- percentage_table_1(table2eii_uda)
table6b       <- percentage_table_1(table6a)

## Fix for incorrect col name from percentage_table_1
colnames(table1bi)[1] <- "Financial Year"
colnames(table1eii)[1] <- "Financial Year"
colnames(table2bii)[1] <- "Financial Year"
colnames(table2bi)[1] <- "Financial Year"
colnames(table2eii)[1] <- "Financial Year"
colnames(table6b)[1]   <- "Financial Year"

## if NaN appear may need something like :
#table2e$Total <- replace_na(table2e$Total, NA)  ## must refresh the table view to see the effect of this