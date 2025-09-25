#Script to create contract location dental activity data for 2019/20 to 2024/25
#write to CSV output files, then put these into a ZIP file

#Extract data from patient location dental activity fact table in warehouse
#by Region, Integrated Care Board (ICB), and Local Authority District (LAD) levels

#get lookups -------------------------------------------------------------------

#collect ONS code lookup from data warehouse if not already loaded into environment
# ons_code_lookup <- dplyr::tbl(con,
#                               from = dbplyr::in_schema("OST", "ONS_CODES_LOOKUP_23"))|>
#   collect()

#get region codes from lookup if not already loaded into environment
# region_codes <- ons_code_lookup |> 
#   select(NHSER23CDH, NHSER23CD) |>
#   unique()

#get icb codes from lookup if not already loaded into environment
# icb_codes <- ons_code_lookup |> 
#   select(ICB23CDH, ICB23CD) |>
#   unique()

#extract Region data -----------------------------------------------------------
regional_data <- dplyr::tbl(con,
                            from = dbplyr::in_schema("OST", "DS_CONT_ACTIVITY_FACT_2425")) |>
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
    REGION_CODE, 
    REGION_NAME,
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
    by = c("REGION_CODE" = "NHSER23CDH")
  ) |>
  mutate(GEOGRAPHY_TYPE = "REGION") |>
  select(
    FINANCIAL_YEAR = TREATMENT_YEAR,
    FINANCIAL_QUARTER,
    GEOGRAPHY_TYPE,
    GEOGRAPHY_ODS_CODE = REGION_CODE,
    GEOGRAPHY_ONS_CODE = NHSER23CD,
    GEOGRAPHY_NAME = REGION_NAME,	
    PATIENT_TYPE,	
    DENTAL_TREATMENT_BAND = TREATMENT_CHARGE_BAND_COMB,	
    UDA,	
    COT
  )



#pull ICB level data from fact tables
icb_data <- dplyr::tbl(con,
                       from = dbplyr::in_schema("OST", "DS_CONT_ACTIVITY_FACT_2425")) |>
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
    COMMISSIONER_CODE, 
    COMMISSIONER_NAME,
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
    icb_codes,
    by = c("COMMISSIONER_CODE" = "ICB23CDH")
  ) |>
  mutate(GEOGRAPHY_TYPE = "ICB") |>
  select(
    FINANCIAL_YEAR = TREATMENT_YEAR,
    FINANCIAL_QUARTER,
    GEOGRAPHY_TYPE,
    GEOGRAPHY_ODS_CODE = COMMISSIONER_CODE,
    GEOGRAPHY_ONS_CODE = ICB23CD,
    GEOGRAPHY_NAME = COMMISSIONER_NAME,	
    PATIENT_TYPE,	
    DENTAL_TREATMENT_BAND = TREATMENT_CHARGE_BAND_COMB,	
    UDA,	
    COT
  )

#pull LA level data from fact tables
la_data <- dplyr::tbl(con,
                      from = dbplyr::in_schema("OST", "DS_CONT_ACTIVITY_FACT_2425")) |>
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
    LAD_CODE, 
    LAD_NAME,
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
    GEOGRAPHY_ONS_CODE = LAD_CODE,
    GEOGRAPHY_NAME = LAD_NAME,	
    PATIENT_TYPE,	
    DENTAL_TREATMENT_BAND = TREATMENT_CHARGE_BAND_COMB,	
    UDA,	
    COT
  )

#combine as one file
combined_data <- regional_data |>
  bind_rows(icb_data) |>
  bind_rows(la_data)  |>
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
  
  fwrite(year_data, 
         paste0("Y:\\Official Stats\\Dental\\2024_25\\csvs\\CSV outputs\\Geo Dental Activity (contract) csvs\\geo_cont_activity_",
                substr(i, 1, 4),
                "_",
                substr(i, 8, 9),
                ".csv"))
}

setwd("Y:\\Official Stats\\Dental\\2024_25\\csvs\\CSV outputs\\Geo Dental Activity (contract) csvs")

#get all geo data .csv files path name
geo_csv_files <- list.files(pattern = "^geo_cont_activity.*\\.csv$",
                            full.names = TRUE)

#save geo data to .zip
zip("geo_cont_dental_activity_201920_202425.zip",
    files = c(geo_csv_files))