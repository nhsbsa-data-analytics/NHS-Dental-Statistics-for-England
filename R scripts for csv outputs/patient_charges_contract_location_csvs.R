#Script to create contract location patient charges data for 2019/20 to 2024/25
#write to CSV output files, then put these into a ZIP file

#Extract data from contract location patient charges fact table in warehouse
#by Region, Integrated Care Board (ICB), and Local Authority District (LAD)

#connect to warehouse ----------------------------------------------------------
# con <- nhsbsaR::con_nhsbsa(dsn = "FBS_8192k",
#                            driver = "Oracle in OraClient19Home1",
#                            "DWCP")

#get lookup codes for ICB, LA, and Region --------------------------------------

#only need to run commented out code if lookups not already loaded into environment

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

#extract LA data ---------------------------------------------------------------
la_data <- dplyr::tbl(
  con,
  from = dbplyr::in_schema("OST","DS_CONT_PAT_CHARGE_FACT_2425"))|>
  filter( TREATMENT_CHARGE_BAND_COMB %in% c(
    "Band 1",
    "Band 2",
    "Band 2a",
    "Band 2b",
    "Band 2c",
    "Band 3",
    "Urgent Treatment"))|>
  group_by(TREATMENT_YEAR,
           LAD_CODE,
           LAD_NAME,
           TREATMENT_CHARGE_BAND_COMB
  )|>
  summarise(VALUE = sum(PATIENT_CHARGE_AMOUNT, na.rm = TRUE),.groups= "drop")|>
  mutate(GEOGRAPHY_TYPE = "LOCAL_AUTHORITY",
         GEOGRAPHY_ODS_CODE = "N/A")|>
  select( FINANCIAL_YEAR= TREATMENT_YEAR,
          GEOGRAPHY_TYPE,
          GEOGRAPHY_ODS_CODE,
          GEOGRAPHY_ONS_CODE = LAD_CODE,
          GEOGRAPHY_NAME =LAD_NAME ,
          DENTAL_TREATMENT_BAND = TREATMENT_CHARGE_BAND_COMB,
          VALUE)|>
  arrange(FINANCIAL_YEAR,
          GEOGRAPHY_ONS_CODE,
          DENTAL_TREATMENT_BAND,)|>
  collect()

#extract ICB data --------------------------------------------------------------
icb_data<- dplyr::tbl(
  con,
  from = dbplyr::in_schema("OST","DS_CONT_PAT_CHARGE_FACT_2425"))|>
  filter( TREATMENT_CHARGE_BAND_COMB %in% c(
    "Band 1",
    "Band 2",
    "Band 2a",
    "Band 2b",
    "Band 2c",
    "Band 3",
    "Urgent Treatment"))|>
  group_by(TREATMENT_YEAR,
           COMMISSIONER_CODE,
           COMMISSIONER_NAME,
           TREATMENT_CHARGE_BAND_COMB
  )|>
  summarise(VALUE = sum(PATIENT_CHARGE_AMOUNT, na.rm = TRUE),.groups= "drop")|>
  collect()|>
  left_join(icbs, by =join_by("COMMISSIONER_CODE"=="ICB23CDH"))|>
  mutate(GEOGRAPHY_TYPE = "ICB")|>
  select( FINANCIAL_YEAR = TREATMENT_YEAR,
          GEOGRAPHY_TYPE,
          GEOGRAPHY_ODS_CODE = COMMISSIONER_CODE,
          GEOGRAPHY_ONS_CODE = ICB23CD,
          GEOGRAPHY_NAME = COMMISSIONER_NAME,
          DENTAL_TREATMENT_BAND = TREATMENT_CHARGE_BAND_COMB,
          VALUE)|>
  arrange(FINANCIAL_YEAR,
          GEOGRAPHY_ONS_CODE,
          DENTAL_TREATMENT_BAND)

#extract region data -----------------------------------------------------------
region_data<-  dplyr::tbl(
  con,
  from = dbplyr::in_schema("OST","DS_CONT_PAT_CHARGE_FACT_2425"))|>
  filter( TREATMENT_CHARGE_BAND_COMB %in% c(
    "Band 1",
    "Band 2",
    "Band 2a",
    "Band 2b",
    "Band 2c",
    "Band 3",
    "Urgent Treatment"))|>
  group_by(TREATMENT_YEAR,
           REGION_CODE,
           REGION_NAME,
           TREATMENT_CHARGE_BAND_COMB
  )|>
  summarise(VALUE = sum(PATIENT_CHARGE_AMOUNT, na.rm = TRUE),.groups= "drop")|>
  collect()|>
  left_join(regions, by =join_by("REGION_CODE"=="NHSER23CDH"))|>
  mutate(GEOGRAPHY_TYPE = "REGION")|>
  select( FINANCIAL_YEAR = TREATMENT_YEAR,
          GEOGRAPHY_TYPE,
          GEOGRAPHY_ODS_CODE = REGION_CODE,
          GEOGRAPHY_ONS_CODE = NHSER23CD,
          GEOGRAPHY_NAME = REGION_NAME,
          DENTAL_TREATMENT_BAND = TREATMENT_CHARGE_BAND_COMB,
          VALUE)|>
  arrange(FINANCIAL_YEAR,
          GEOGRAPHY_ONS_CODE,
          DENTAL_TREATMENT_BAND)


#combine as one file
combined_data_charge_cont <- region_data |>
  bind_rows(icb_data) |>
  bind_rows(la_data)  |>
  arrange(FINANCIAL_YEAR,
          GEOGRAPHY_ONS_CODE,
          GEOGRAPHY_ODS_CODE,
          GEOGRAPHY_TYPE,
          DENTAL_TREATMENT_BAND)

#get list of financial years
unique_years_charge_cont <- unique(combined_data_charge_cont$FINANCIAL_YEAR)

#loop through financial years to filter data and save a .csv
for(i in unique_years_charge_cont) {
  print(i)
  year_data <- combined_data_charge_cont |>
    filter(FINANCIAL_YEAR == i)|>
    mutate(
      UID = row_number()
    ) |>
    select(UID, everything())
  
  data.table::fwrite(year_data, 
                     paste0("Y:\\Official Stats\\Dental\\2024_25\\csvs\\CSV outputs\\Geo Patient Charges (contract) csvs\\geo_cont_dental_charges_",
                            substr(i, 1, 4),
                            "_",
                            substr(i, 8, 9),
                            ".csv"))
}

setwd("Y:\\Official Stats\\Dental\\2024_25\\csvs\\CSV outputs\\Geo Patient Charges (contract) csvs")

#get all geo data .csv files path name
pat_charges_csv_files <- list.files(pattern = "^geo_cont_dental_charges.*\\.csv$",
                                    full.names = TRUE)

#save geo data to .zip
zip("geo_cont_dental_charges_201920_202425.zip",
    files = c(pat_charges_csv_files))