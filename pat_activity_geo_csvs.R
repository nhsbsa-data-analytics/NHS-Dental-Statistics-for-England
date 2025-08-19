#collect ons code lookup from DWH
ons_code_lookup <- dplyr::tbl(con,
                              from = dbplyr::in_schema("OST", "ONS_CODES_LOOKUP_23"))|>
  collect()

#get lookups for LA and Ward
la_lookup<- get_la_lookup()

ward_lookup <- get_ward_lookup()

#requires copy of 2022 codes file saved in working directory due to issue with ONS website
setwd("Y:\\Official Stats\\Dental\\2024_25\\csvs")
region_lookup <- get_region_lookups()

#get nhs region codes from lookup
region_codes <- ons_code_lookup |> 
  select(NHSER23CDH, NHSER23CD, NHSER23NM) |>
  unique()

#pull NHS region level data from fact tables
regional_data <- dplyr::tbl(con,
                            from = dbplyr::in_schema("OST", "DS_PAT_ACTIVITY_FACT_2425")) |>
  filter(
    TREATMENT_YEAR >= "2019/2020" & TREATMENT_YEAR <= "2024/2025",
    FORM_TYPE == "G", 
    QUARTER != "unallocated_1",
    QUARTER != "unallocated_2",
    !(TREATMENT_CHARGE_BAND_COMB %in% c("N/A", "Only a Domiciliary Visit", "Free - Unknown", "Only a Sedation"))
  ) |>
  mutate(
    FINANCIAL_QUARTER = paste0(TREATMENT_YEAR, " ", QUARTER),
    PATIENT_TYPE = case_when(
      EXEMPTION_DESC == "Child (under 18)"  ~ "Child",
      EXEMPTION_DESC == "Paying adult" ~ "Paying adult",
      TRUE ~ "Non-paying adult"
    ) 
  ) |>
  group_by(
    TREATMENT_YEAR,
    FINANCIAL_QUARTER,
    PAT_REGION, 
    PATIENT_TYPE,
    TREATMENT_CHARGE_BAND_COMB
  ) |>
  summarise(
    UDA = sum(UDA, na.rm = TRUE),
    COT = sum(COT, na.rm = TRUE),
    .groups = "drop"
  ) |>
  collect() |>
  left_join(
    region_codes,
    by = c("PAT_REGION" = "NHSER23CD")
  ) |>
  mutate(GEOGRAPHY_TYPE = "REGION") |>
  select(
    FINANCIAL_YEAR = TREATMENT_YEAR,
    FINANCIAL_QUARTER,
    GEOGRAPHY_TYPE,
    GEOGRAPHY_ODS_CODE = NHSER23CDH,
    GEOGRAPHY_ONS_CODE = PAT_REGION,
    GEOGRAPHY_NAME = NHSER23NM,	
    PATIENT_TYPE,	
    DENTAL_TREATMENT_BAND = TREATMENT_CHARGE_BAND_COMB,	
    UDA,	
    COT
  )

#join names and codes for 2 regions that changed code
#assign activity from patients with non-England postcodes to 'Other'
#unmapped postcode patient activity to 'Unknown'
region_data <- regional_data |>
  dplyr::left_join(region_lookup, by = join_by(GEOGRAPHY_ONS_CODE == "NHSER21CD")) |>
  #add non England data into 'other' group
  #add non-mapped postcode activity to 'unknown' group 
  dplyr::mutate(GEOGRAPHY_ONS_CODE = case_when(GEOGRAPHY_ONS_CODE %in% c('L99999999',
                                                                         'M99999999',
                                                                         'N99999999',
                                                                         'S99999999',
                                                                         'W99999999') ~ "Other",
                                               is.na(GEOGRAPHY_ONS_CODE) ~ "Unknown",
                                               TRUE ~ GEOGRAPHY_ONS_CODE)) |>
  dplyr::mutate(GEOGRAPHY_NAME = case_when(GEOGRAPHY_ONS_CODE == "Other"  ~ "Other",
                                           GEOGRAPHY_ONS_CODE == "Unknown" ~ "Unknown",
                                           TRUE ~ NHSER21NM,
  )) |>
  dplyr::group_by(FINANCIAL_YEAR,
                  FINANCIAL_QUARTER,
                  GEOGRAPHY_TYPE,
                  GEOGRAPHY_ODS_CODE = NHSER24CDH,
                  GEOGRAPHY_ONS_CODE,
                  GEOGRAPHY_NAME,
                  PATIENT_TYPE,
                  DENTAL_TREATMENT_BAND) |>
  summarise(across(UDA:COT, ~ sum(.x, na.rm = TRUE))) |>
  ungroup()

icb_codes <- ons_code_lookup |> 
  select(ICB23CDH, ICB23CD, ICB23NM) |>
  unique()

#pull ICB level data from fact tables
#Patient ICB name, ICB ONS code and ICB ODS code can be taken straight from fact table
icbs_data <- dplyr::tbl(con,
                        from = dbplyr::in_schema("OST", "DS_PAT_ACTIVITY_FACT_2425")) |>
  filter(
    TREATMENT_YEAR >= "2019/2020" & TREATMENT_YEAR <= "2024/2025",
    FORM_TYPE == "G", 
    QUARTER != "unallocated_1",
    QUARTER != "unallocated_2",
    !(TREATMENT_CHARGE_BAND_COMB %in% c("N/A", "Only a Domiciliary Visit", "Free - Unknown", "Only a Sedation"))
  ) |>
  mutate(
    FINANCIAL_QUARTER = paste0(TREATMENT_YEAR, " ", QUARTER),
    PATIENT_TYPE = case_when(
      EXEMPTION_DESC == "Child (under 18)"  ~ "Child",
      EXEMPTION_DESC == "Paying adult" ~ "Paying adult",
      TRUE ~ "Non-paying adult"
    ) 
  ) |>
  group_by(
    TREATMENT_YEAR,
    FINANCIAL_QUARTER,
    PAT_ICB, 
    PAT_ICB_CDH,
    PAT_ICB_NM,
    PATIENT_TYPE,
    TREATMENT_CHARGE_BAND_COMB
  ) |>
  summarise(
    UDA = sum(UDA, na.rm = TRUE),
    COT = sum(COT, na.rm = TRUE),
    .groups = "drop"
  ) |>
  collect() |>
  mutate(GEOGRAPHY_TYPE = "ICB") |>
  select(
    FINANCIAL_YEAR = TREATMENT_YEAR,
    FINANCIAL_QUARTER,
    GEOGRAPHY_TYPE,
    GEOGRAPHY_ODS_CODE = PAT_ICB_CDH,
    GEOGRAPHY_ONS_CODE = PAT_ICB,
    GEOGRAPHY_NAME = PAT_ICB_NM,	
    PATIENT_TYPE,	
    DENTAL_TREATMENT_BAND = TREATMENT_CHARGE_BAND_COMB,	
    UDA,	
    COT
  )

#assign activity from patients with non-England postcodes to 'Other'
#unmapped postcode patient activity to 'Unknown'

icb_data <- icbs_data |>
  #add non England data into 'other' group
  #add non-mapped postcode activity to 'unknown' group 
  dplyr::mutate(GEOGRAPHY_ONS_CODE = case_when(GEOGRAPHY_ONS_CODE %in% c('L99999999',
                                                         'M99999999',
                                                         'N99999999',
                                                         'S99999999',
                                                         'W99999999') ~ "Other",
                                       is.na(GEOGRAPHY_ONS_CODE) ~ "Unknown",
                                       TRUE ~ GEOGRAPHY_ONS_CODE)) |>
  dplyr::mutate(GEOGRAPHY_NAME = case_when(GEOGRAPHY_ONS_CODE == "Other"  ~ "Other",
                                       GEOGRAPHY_ONS_CODE == "Unknown" ~ "Unknown",
                                       TRUE ~ GEOGRAPHY_NAME)) |>  
  dplyr::group_by(FINANCIAL_YEAR,
                  FINANCIAL_QUARTER,
                  GEOGRAPHY_TYPE,
                  GEOGRAPHY_ODS_CODE,
                  GEOGRAPHY_ONS_CODE,
                  GEOGRAPHY_NAME,
                  PATIENT_TYPE,
                  DENTAL_TREATMENT_BAND) |>
  summarise(across(UDA:COT, ~ sum(.x, na.rm = TRUE))) |>
  ungroup()

#pull LA level data from fact tables
#patient LA ONS code in fact table as LAUA, will need name from joined lookup (no ODS code)
las_data <- dplyr::tbl(con,
                       from = dbplyr::in_schema("OST", "DS_PAT_ACTIVITY_FACT_2425")) |>
  filter(
    TREATMENT_YEAR >= "2019/2020" & TREATMENT_YEAR <= "2024/2025",
    FORM_TYPE == "G", 
    QUARTER != "unallocated_1",
    QUARTER != "unallocated_2",
    !(TREATMENT_CHARGE_BAND_COMB %in% c("N/A", "Only a Domiciliary Visit", "Free - Unknown", "Only a Sedation"))
  ) |>
  mutate(
    FINANCIAL_QUARTER = paste0(TREATMENT_YEAR, " ", QUARTER),
    PATIENT_TYPE = case_when(
      EXEMPTION_DESC == "Child (under 18)"  ~ "Child",
      EXEMPTION_DESC == "Paying adult" ~ "Paying adult",
      TRUE ~ "Non-paying adult"
    ) 
  ) |>
  group_by(
    TREATMENT_YEAR,
    FINANCIAL_QUARTER,
    LAUA, 
    PATIENT_TYPE,
    TREATMENT_CHARGE_BAND_COMB
  ) |>
  summarise(
    UDA = sum(UDA, na.rm = TRUE),
    COT = sum(COT, na.rm = TRUE),
    .groups = "drop"
  ) |>
  collect() |>
  mutate(GEOGRAPHY_TYPE = "LOCAL_AUTHORITY",
         GEOGRAPHY_ODS_CODE = "N/A") |>
  select(
    FINANCIAL_YEAR = TREATMENT_YEAR,
    FINANCIAL_QUARTER,
    GEOGRAPHY_TYPE,
    GEOGRAPHY_ODS_CODE,
    GEOGRAPHY_ONS_CODE = LAUA,
    PATIENT_TYPE,	
    DENTAL_TREATMENT_BAND = TREATMENT_CHARGE_BAND_COMB,	
    UDA,	
    COT
  )

#join names from LA lookup
#assign activity from patients with non-England postcodes to 'Other'
#unmapped postcode patient activity to 'Unknown'

la_data <- las_data |>
  dplyr::mutate(GEOGRAPHY_ONS_CODE = case_when(grepl("L", GEOGRAPHY_ONS_CODE) ~ "Other",
                                       grepl("M", GEOGRAPHY_ONS_CODE) ~ "Other",
                                       grepl("N", GEOGRAPHY_ONS_CODE) ~ "Other",
                                       grepl("S", GEOGRAPHY_ONS_CODE) ~ "Other",
                                       grepl("W", GEOGRAPHY_ONS_CODE) ~ "Other",
                                       is.na(GEOGRAPHY_ONS_CODE) ~ "Unknown",
                                       TRUE ~ GEOGRAPHY_ONS_CODE)) |>
  dplyr::left_join(la_lookup, by = join_by(GEOGRAPHY_ONS_CODE == "LAD23CD")) |>
  dplyr::mutate(GEOGRAPHY_NAME = case_when(GEOGRAPHY_ONS_CODE == "Other"  ~ "Other",
                                      GEOGRAPHY_ONS_CODE == "Unknown" ~ "Unknown",
                                      TRUE ~ `LAD23NM`)) |>
  dplyr::group_by(FINANCIAL_YEAR,
                  FINANCIAL_QUARTER,
                  GEOGRAPHY_TYPE,
                  GEOGRAPHY_ODS_CODE,
                  GEOGRAPHY_ONS_CODE,
                  GEOGRAPHY_NAME,
                  PATIENT_TYPE,
                  DENTAL_TREATMENT_BAND) |>
  summarise(across(UDA:COT, ~ sum(.x, na.rm = TRUE))) |>
  ungroup()

#pull Ward level data from fact tables
##patient Ward ONS code in fact table as WARD, will need name from joined lookup (no ODS code)
wards_data <- dplyr::tbl(con,
                       from = dbplyr::in_schema("OST", "DS_PAT_ACTIVITY_FACT_2425")) |>
  filter(
    TREATMENT_YEAR >= "2019/2020" & TREATMENT_YEAR <= "2024/2025",
    FORM_TYPE == "G", 
    QUARTER != "unallocated_1",
    QUARTER != "unallocated_2",
    !(TREATMENT_CHARGE_BAND_COMB %in% c("N/A", "Only a Domiciliary Visit", "Free - Unknown", "Only a Sedation"))
  ) |>
  mutate(
    FINANCIAL_QUARTER = paste0(TREATMENT_YEAR, " ", QUARTER),
    PATIENT_TYPE = case_when(
      EXEMPTION_DESC == "Child (under 18)"  ~ "Child",
      EXEMPTION_DESC == "Paying adult" ~ "Paying adult",
      TRUE ~ "Non-paying adult"
    ) 
  ) |>
  group_by(
    TREATMENT_YEAR,
    FINANCIAL_QUARTER,
    WARD, 
    PATIENT_TYPE,
    TREATMENT_CHARGE_BAND_COMB
  ) |>
  summarise(
    UDA = sum(UDA, na.rm = TRUE),
    COT = sum(COT, na.rm = TRUE),
    .groups = "drop"
  ) |>
  collect() |>
  mutate(GEOGRAPHY_TYPE = "WARD",
         GEOGRAPHY_ODS_CODE = "N/A") |>
  select(
    FINANCIAL_YEAR = TREATMENT_YEAR,
    FINANCIAL_QUARTER,
    GEOGRAPHY_TYPE,
    GEOGRAPHY_ODS_CODE,
    GEOGRAPHY_ONS_CODE = WARD,
    PATIENT_TYPE,	
    DENTAL_TREATMENT_BAND = TREATMENT_CHARGE_BAND_COMB,	
    UDA,	
    COT
  )

#join names from Ward lookup
#assign activity from patients with non-England postcodes to 'Other'
#unmapped postcode patient activity to 'Unknown'

ward_data <- wards_data |>
  #add non England data into 'other' group
  #add non-mapped postcode activity to 'unknown' group
  #TO DO put grepl call into single case when grouping
  dplyr::mutate(GEOGRAPHY_ONS_CODE = case_when(grepl("L", GEOGRAPHY_ONS_CODE) ~ "Other",
                                       grepl("M", GEOGRAPHY_ONS_CODE) ~ "Other",
                                       grepl("N", GEOGRAPHY_ONS_CODE) ~ "Other",
                                       grepl("S", GEOGRAPHY_ONS_CODE) ~ "Other",
                                       grepl("W", GEOGRAPHY_ONS_CODE) ~ "Other",
                                       is.na(GEOGRAPHY_ONS_CODE) ~ "Unknown",
                                       TRUE ~ GEOGRAPHY_ONS_CODE)) |>
  dplyr::left_join(ward_lookup, by = join_by(GEOGRAPHY_ONS_CODE == "WD23CD")) |>
  dplyr::mutate(GEOGRAPHY_NAME = case_when(GEOGRAPHY_ONS_CODE == "Other"  ~ "Other",
                                        GEOGRAPHY_ONS_CODE == "Unknown" ~ "Unknown",
                                        TRUE ~ `WD23NM`)) |>
  dplyr::group_by(FINANCIAL_YEAR,
                  FINANCIAL_QUARTER,
                  GEOGRAPHY_TYPE,
                  GEOGRAPHY_ODS_CODE,
                  GEOGRAPHY_ONS_CODE,
                  GEOGRAPHY_NAME,
                  PATIENT_TYPE,
                  DENTAL_TREATMENT_BAND) |>
  summarise(across(UDA:COT, ~ sum(.x, na.rm = TRUE))) |>
  ungroup()

#combine as one file
combined_data <- region_data |>
  bind_rows(icb_data) |>
  bind_rows(la_data)  |>
  bind_rows(ward_data)|>
  arrange(FINANCIAL_QUARTER,
          GEOGRAPHY_ONS_CODE,
          GEOGRAPHY_ODS_CODE,
          GEOGRAPHY_TYPE,
          PATIENT_TYPE,
          DENTAL_TREATMENT_BAND)

#get list of financial years
unique_years <- unique(combined_data$FINANCIAL_YEAR)

#loop through financial years to filter data and save a .csv
for(i in unique_years) {
  print(i)
  year_data <- combined_data |>
    filter(FINANCIAL_YEAR == i)|>
    mutate(
      UID = row_number()
    ) |>
    select(UID, everything())
  
  data.table::fwrite(year_data, 
         paste0("Y:\\Official Stats\\Dental\\2024_25\\csvs\\CSV outputs\\Geo Patient Activity csvs\\geo_pat_activity_",
                substr(i, 1, 4),
                "_",
                substr(i, 8, 9),
                ".csv"))
}

setwd("Y:\\Official Stats\\Dental\\2024_25\\csvs\\CSV outputs\\Geo Patient Activity csvs")

#get all geo data .csv files path name
geo_csv_files <- list.files(pattern = "^geo_pat_activity.*\\.csv$",
                            full.names = TRUE)

#save geo data to .zip
zip("geo_patient_activity_201920_202425.zip",
    files = c(geo_csv_files))
