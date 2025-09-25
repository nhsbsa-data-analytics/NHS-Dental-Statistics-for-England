#Script to create patient location patient charges data for 2019/20 to 2024/25
#write to CSV output files, then put these into a ZIP file

#Extract data from patient location patient charges fact table in warehouse
#by Region, Integrated Care Board (ICB), Local Authority District (LAD), and Ward levels

#connect to warehouse ----------------------------------------------------------
# con <- nhsbsaR::con_nhsbsa(dsn = "FBS_8192k",
#                            driver = "Oracle in OraClient19Home1",
#                            "DWCP")

#get lookups for ICB, LA, Ward, and Region -------------------------------------

#only need to run commented out code if lookups not already loaded into environment

# la_lookup<- get_la_lookup()

# ward_lookup <- get_ward_lookup()

#region lookup requires copy of Office for National Statistics (ONS) 2022 codes
#lookup file saved in working directory due to issue with ONS website

# setwd("Y:\\Official Stats\\Dental\\2024_25\\csvs")
# region_lookup <- get_region_lookups()

# icbs <- dplyr::tbl(
#   con,
#   from = dbplyr::in_schema("OST", "ONS_CODES_LOOKUP_23")
# )|>
#   select(ICB23CD,
#          ICB23CDH,
#          ICB23NM)|>
#   distinct()|>
#   collect()
# 
# regions <- dplyr::tbl(
#   con,
#   from = dbplyr::in_schema("OST", "ONS_CODES_LOOKUP_23")
# )|> select(NHSER23CD,
#            NHSER23CDH,
#            NHSER23NM)|>
#   distinct()|>
#   collect()

#extract LAD data --------------------------------------------------------------
las_data<- dplyr::tbl(
  con,
  from = dbplyr::in_schema("OST","DS_PAT_PAT_CHARGE_FACT_2425"))|>
  filter( TREATMENT_CHARGE_BAND_COMB %in% c(
    "Band 1",
    "Band 2",
    "Band 2a",
    "Band 2b",
    "Band 2c",
    "Band 3",
    "Urgent Treatment"))|>
  group_by(TREATMENT_YEAR,
           LAUA,
           TREATMENT_CHARGE_BAND_COMB
  )|>
  summarise(VALUE = sum(PATIENT_CHARGE_AMOUNT, na.rm = TRUE),.groups= "drop")|>
  mutate(GEOGRAPHY_TYPE = "LOCAL_AUTHORITY",
         GEOGRAPHY_ODS_CODE = "N/A")|>
  select( FINANCIAL_YEAR= TREATMENT_YEAR,
          GEOGRAPHY_TYPE,
          GEOGRAPHY_ODS_CODE,
          GEOGRAPHY_ONS_CODE = LAUA,
          DENTAL_TREATMENT_BAND = TREATMENT_CHARGE_BAND_COMB,
          VALUE)|>
  arrange(FINANCIAL_YEAR,
          GEOGRAPHY_ONS_CODE,
          DENTAL_TREATMENT_BAND)|>
  collect()

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
                  GEOGRAPHY_TYPE,
                  GEOGRAPHY_ODS_CODE,
                  GEOGRAPHY_ONS_CODE,
                  GEOGRAPHY_NAME,
                  DENTAL_TREATMENT_BAND) |>
  summarise(VALUE = sum(VALUE, na.rm = TRUE)) |>
  ungroup()

#extract ICB data --------------------------------------------------------------
icbs_data<- dplyr::tbl(
  con,
  from = dbplyr::in_schema("OST","DS_PAT_PAT_CHARGE_FACT_2425"))|>
  filter( TREATMENT_CHARGE_BAND_COMB %in% c(
    "Band 1",
    "Band 2",
    "Band 2a",
    "Band 2b",
    "Band 2c",
    "Band 3",
    "Urgent Treatment"))|>
  group_by(TREATMENT_YEAR,
           PAT_ICB,
           PAT_ICB_CDH,
           PAT_ICB_NM,
           TREATMENT_CHARGE_BAND_COMB
  )|>
  summarise(VALUE = sum(PATIENT_CHARGE_AMOUNT, na.rm = TRUE),.groups= "drop")|>
  collect()|>
  mutate(GEOGRAPHY_TYPE = "ICB")|>
  select( FINANCIAL_YEAR = TREATMENT_YEAR,
          GEOGRAPHY_TYPE,
          GEOGRAPHY_ODS_CODE = PAT_ICB_CDH,
          GEOGRAPHY_ONS_CODE = PAT_ICB,
          GEOGRAPHY_NAME = PAT_ICB_NM,
          DENTAL_TREATMENT_BAND = TREATMENT_CHARGE_BAND_COMB,
          VALUE)|>
  arrange(FINANCIAL_YEAR,
          GEOGRAPHY_ONS_CODE,
          DENTAL_TREATMENT_BAND)

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
                  GEOGRAPHY_TYPE,
                  GEOGRAPHY_ODS_CODE,
                  GEOGRAPHY_ONS_CODE,
                  GEOGRAPHY_NAME,
                  DENTAL_TREATMENT_BAND) |>
  summarise(VALUE = sum(VALUE, na.rm = TRUE)) |>
  ungroup()

#extract Region data -----------------------------------------------------------
regional_data <-  dplyr::tbl(
  con,
  from = dbplyr::in_schema("OST","DS_PAT_PAT_CHARGE_FACT_2425"))|>
  filter( TREATMENT_CHARGE_BAND_COMB %in% c(
    "Band 1",
    "Band 2",
    "Band 2a",
    "Band 2b",
    "Band 2c",
    "Band 3",
    "Urgent Treatment"))|>
  group_by(TREATMENT_YEAR,
           PAT_REGION,
           TREATMENT_CHARGE_BAND_COMB
  )|>
  summarise(VALUE = sum(PATIENT_CHARGE_AMOUNT, na.rm = TRUE),.groups= "drop")|>
  collect()|>
  left_join(regions, by =join_by("PAT_REGION"=="NHSER23CD"))|>
  mutate(GEOGRAPHY_TYPE = "REGION")|>
  select( FINANCIAL_YEAR = TREATMENT_YEAR,
          GEOGRAPHY_TYPE,
          GEOGRAPHY_ODS_CODE = NHSER23CDH,
          GEOGRAPHY_ONS_CODE = PAT_REGION,
          DENTAL_TREATMENT_BAND = TREATMENT_CHARGE_BAND_COMB,
          VALUE)|>
  arrange(FINANCIAL_YEAR,
          GEOGRAPHY_ONS_CODE,
          DENTAL_TREATMENT_BAND)

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
                                               GEOGRAPHY_ONS_CODE == "E40000008" ~ "E40000011",
                                               GEOGRAPHY_ONS_CODE == "E40000009" ~ "E40000012",
                                               is.na(GEOGRAPHY_ONS_CODE) ~ "Unknown",
                                               TRUE ~ GEOGRAPHY_ONS_CODE)) |>
  dplyr::mutate(GEOGRAPHY_NAME = case_when(GEOGRAPHY_ONS_CODE == "Other"  ~ "Other",
                                           GEOGRAPHY_ONS_CODE == "Unknown" ~ "Unknown",
                                           TRUE ~ NHSER21NM,
  )) |>
  dplyr::group_by(FINANCIAL_YEAR,
                  GEOGRAPHY_TYPE,
                  GEOGRAPHY_ODS_CODE = NHSER24CDH,
                  GEOGRAPHY_ONS_CODE,
                  GEOGRAPHY_NAME,
                  DENTAL_TREATMENT_BAND) |>
  summarise(VALUE = sum(VALUE, na.rm = TRUE)) |>
  ungroup()

#extract Ward data -------------------------------------------------------------
wards_data<- dplyr::tbl(
  con,
  from = dbplyr::in_schema("OST","DS_PAT_PAT_CHARGE_FACT_2425"))|>
  filter( TREATMENT_CHARGE_BAND_COMB %in% c(
    "Band 1",
    "Band 2",
    "Band 2a",
    "Band 2b",
    "Band 2c",
    "Band 3",
    "Urgent Treatment"))|>
  group_by(TREATMENT_YEAR,
           WARD,
           TREATMENT_CHARGE_BAND_COMB
  )|>
  summarise(VALUE = sum(PATIENT_CHARGE_AMOUNT, na.rm = TRUE),.groups= "drop")|>
  mutate(GEOGRAPHY_TYPE = "LOCAL_AUTHORITY",
         GEOGRAPHY_ODS_CODE = "N/A")|>
  select( FINANCIAL_YEAR= TREATMENT_YEAR,
          GEOGRAPHY_TYPE,
          GEOGRAPHY_ODS_CODE,
          GEOGRAPHY_ONS_CODE = WARD,
          DENTAL_TREATMENT_BAND = TREATMENT_CHARGE_BAND_COMB,
          VALUE)|>
  arrange(FINANCIAL_YEAR,
          GEOGRAPHY_ONS_CODE,
          DENTAL_TREATMENT_BAND)|>
  collect()

#join names from ward lookup
#assign activity from patients with non-England postcodes to 'Other'
#unmapped postcode patient activity to 'Unknown'

ward_data <- wards_data |>
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
                  GEOGRAPHY_TYPE,
                  GEOGRAPHY_ODS_CODE,
                  GEOGRAPHY_ONS_CODE,
                  GEOGRAPHY_NAME,
                  DENTAL_TREATMENT_BAND) |>
  summarise(VALUE = sum(VALUE, na.rm = TRUE)) |>
  ungroup()

#combine as one file
combined_data_charge_pat <- region_data |>
  bind_rows(icb_data) |>
  bind_rows(la_data)  |>
  bind_rows(ward_data)|>
  arrange(FINANCIAL_YEAR,
          GEOGRAPHY_ONS_CODE,
          GEOGRAPHY_ODS_CODE,
          GEOGRAPHY_TYPE,
          DENTAL_TREATMENT_BAND)

#get list of financial years
unique_years_charge_pat <- unique(combined_data_charge_pat$FINANCIAL_YEAR)

#loop through financial years to filter data and save a .csv
for(i in unique_years_charge_pat) {
  print(i)
  year_data <- combined_data_charge_pat |>
    filter(FINANCIAL_YEAR == i)|>
    mutate(
      UID = row_number()
    ) |>
    select(UID, everything())
  
  data.table::fwrite(year_data, 
                     paste0("Y:\\Official Stats\\Dental\\2024_25\\csvs\\CSV outputs\\Geo Patient Charges (patient) csvs\\geo_pat_dental_charges_",
                            substr(i, 1, 4),
                            "_",
                            substr(i, 8, 9),
                            ".csv"))
}

setwd("Y:\\Official Stats\\Dental\\2024_25\\csvs\\CSV outputs\\Geo Patient Charges (patient) csvs")

#get all geo data .csv files path name
pat_charges_cont_csv_files <- list.files(pattern = "^geo_pat_dental_charges.*\\.csv$",
                                         full.names = TRUE)

#save geo data to .zip
zip("geo_pat_dental_charges_201920_202425.zip",
    files = c(pat_charges_cont_csv_files))