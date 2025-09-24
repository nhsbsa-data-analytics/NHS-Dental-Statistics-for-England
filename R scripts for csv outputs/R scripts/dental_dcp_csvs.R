#Script to create Dental Care Professional (DCP) activity data for 2019/20 to 2024/25
#write to CSV output files, then put these into a ZIP file

#Extract DCP data from contract location dental activity fact table in warehouse
#by Region, Integrated Care Board (ICB), and Local Authority District (LAD) levels

#data by LAD -------------------------------------------------------------------
dcp_lad_csv_data <- dplyr::tbl(con,
                                from = dbplyr::in_schema("OST", "DS_CONT_ACTIVITY_FACT_2425")) |>

  dplyr::filter(
    TREATMENT_YEAR >= "2019/2020" & TREATMENT_YEAR <= "2024/2025",
    FORM_TYPE == "G", 
    QUARTER != "unallocated_1",
    QUARTER != "unallocated_2",
    !(TREATMENT_CHARGE_BAND_COMB %in% c("N/A", "Only a Domiciliary Visit", "Free - Unknown", "Only a Sedation"))
  ) |>
  dplyr::mutate(
    FINANCIAL_QUARTER = paste0(TREATMENT_YEAR, " ", QUARTER)
  ) |>
  group_by(
    TREATMENT_YEAR,
    FINANCIAL_QUARTER,
    LAD_CODE,
    LAD_NAME,
    DCP,
    DCP_TYPE,
    TREATMENT_CHARGE_BAND_COMB
  ) |>
  summarise(
    UDA = sum(UDA, na.rm = TRUE),
    COT = sum(COT, na.rm = TRUE),
    .groups = "drop"
  ) |>
  mutate(
    GEOGRAPHY_TYPE = "LOCAL_AUTHORITY",
    GEOGRAPHY_ODS_CODE = "N/A"
  ) |>
  select(
    FINANCIAL_YEAR = TREATMENT_YEAR,
    FINANCIAL_QUARTER,
    GEOGRAPHY_TYPE,
    GEOGRAPHY_ODS_CODE,
    GEOGRAPHY_ONS_CODE = LAD_CODE,
    GEOGRAPHY_NAME = LAD_NAME,
    DCP,
    DCP_TYPE,
    DENTAL_TREATMENT_BAND = TREATMENT_CHARGE_BAND_COMB,	
    UDA,	
    COT
  )|>
  arrange(FINANCIAL_QUARTER,
          GEOGRAPHY_ONS_CODE,
          DCP,
          DCP_TYPE) |>
  collect()

#data by ICB -------------------------------------------------------------------
icb_data <- dplyr::tbl(con,
                    from = dbplyr::in_schema("OST", "ONS_CODES_LOOKUP_23")) |>
  select(ICB23CDH, ICB23CD, ICB23NM) |>
  distinct()

dcp_icb_csv_data <- dplyr::tbl(con,
                               from = dbplyr::in_schema("OST", "DS_CONT_ACTIVITY_FACT_2425")) |>
  left_join(
    icb_data,
    by = c("COMMISSIONER_CODE" = "ICB23CDH")
  ) |>
  dplyr::filter(
    TREATMENT_YEAR >= "2019/2020" & TREATMENT_YEAR <= "2024/2025",
    FORM_TYPE == "G", 
    QUARTER != "unallocated_1",
    QUARTER != "unallocated_2",
    !(TREATMENT_CHARGE_BAND_COMB %in% c("N/A", "Only a Domiciliary Visit", "Free - Unknown", "Only a Sedation"))
  ) |>
  dplyr::mutate(
    FINANCIAL_QUARTER = paste0(TREATMENT_YEAR, " ", QUARTER)
  ) |>
  group_by(
    TREATMENT_YEAR,
    FINANCIAL_QUARTER,
    COMMISSIONER_CODE,
    ICB23CD,
    COMMISSIONER_NAME,
    DCP,
    DCP_TYPE,
    TREATMENT_CHARGE_BAND_COMB
  ) |>
  summarise(
    UDA = sum(UDA, na.rm = TRUE),
    COT = sum(COT, na.rm = TRUE),
    .groups = "drop"
  ) |>
  mutate(
    GEOGRAPHY_TYPE = "ICB",
  ) |>
  select(
    FINANCIAL_YEAR = TREATMENT_YEAR,
    FINANCIAL_QUARTER,
    GEOGRAPHY_TYPE,
    GEOGRAPHY_ODS_CODE = COMMISSIONER_CODE,
    GEOGRAPHY_ONS_CODE = ICB23CD,
    GEOGRAPHY_NAME = COMMISSIONER_NAME,
    DCP,
    DCP_TYPE,
    DENTAL_TREATMENT_BAND = TREATMENT_CHARGE_BAND_COMB,	
    UDA,	
    COT
  )|>
  arrange(FINANCIAL_QUARTER,
          GEOGRAPHY_ONS_CODE,
          DCP,
          DCP_TYPE) |>
  filter(!is.na(GEOGRAPHY_NAME)) |>
  collect()

#filter particular row to spot check against table dental_geo_cont_table1bi
icb_check <- dcp_icb_csv_data |>
  filter(
    FINANCIAL_YEAR == "2024/2025",
    GEOGRAPHY_ODS_CODE == "QGH",
    DCP == "DCP-led",
    DCP_TYPE == "Dental Therapist",
    DENTAL_TREATMENT_BAND == "Band 1"
  )

#data by region ----------------------------------------------------------------
region_data <- dplyr::tbl(con,
                       from = dbplyr::in_schema("OST", "ONS_CODES_LOOKUP_23")) |>
  select(NHSER23CDH, NHSER23CD, NHSER23NM) |>
  distinct() 

dcp_region_csv_data <- dplyr::tbl(con,
                               from = dbplyr::in_schema("OST", "DS_CONT_ACTIVITY_FACT_2425")) |>
  left_join(
    region_data,
    by = c("REGION_CODE" = "NHSER23CDH")
  ) |>
  dplyr::filter(
    TREATMENT_YEAR >= "2019/2020" & TREATMENT_YEAR <= "2024/2025",
    FORM_TYPE == "G", 
    QUARTER != "unallocated_1",
    QUARTER != "unallocated_2",
    !(TREATMENT_CHARGE_BAND_COMB %in% c("N/A", "Only a Domiciliary Visit", "Free - Unknown", "Only a Sedation"))
  ) |>
  dplyr::mutate(
    FINANCIAL_QUARTER = paste0(TREATMENT_YEAR, " ", QUARTER)
  ) |>
  group_by(
    TREATMENT_YEAR,
    FINANCIAL_QUARTER,
    REGION_CODE,
    NHSER23CD,
    REGION_NAME,
    DCP,
    DCP_TYPE,
    TREATMENT_CHARGE_BAND_COMB
  ) |>
  summarise(
    UDA = sum(UDA, na.rm = TRUE),
    COT = sum(COT, na.rm = TRUE),
    .groups = "drop"
  ) |>
  mutate(
    GEOGRAPHY_TYPE = "REGION",
  ) |>
  select(
    FINANCIAL_YEAR = TREATMENT_YEAR,
    FINANCIAL_QUARTER,
    GEOGRAPHY_TYPE,
    GEOGRAPHY_ODS_CODE = REGION_CODE,
    GEOGRAPHY_ONS_CODE = NHSER23CD,
    GEOGRAPHY_NAME = REGION_NAME,
    DCP,
    DCP_TYPE,
    DENTAL_TREATMENT_BAND = TREATMENT_CHARGE_BAND_COMB,	
    UDA,	
    COT
  )|>
  arrange(FINANCIAL_QUARTER,
          GEOGRAPHY_ONS_CODE,
          DCP,
          DCP_TYPE) |>
  filter(!is.na(GEOGRAPHY_NAME)) |>
  collect()

#filter particular row to spot check against table dental_geo_cont_table1ai
region_check <- dcp_region_csv_data |>
  filter(
    FINANCIAL_YEAR == "2024/2025",
    GEOGRAPHY_ODS_CODE == "Y56",
    DCP == "DCP-assisted",
    DCP_TYPE == "Dental Hygienist",
    DENTAL_TREATMENT_BAND == "Band 1"
  )

#combine all data -------------------------------------------------------------
dcp_csv_data <- dcp_region_csv_data |>
  bind_rows(
    dcp_icb_csv_data,
    dcp_lad_csv_data
  )

#get list of financial years
unique_years <- unique(dcp_csv_data$FINANCIAL_YEAR)

#loop through financial years to filter data and save as .csv
for(i in unique_years) {
  print(i)
  year_data <- dcp_csv_data |>
    filter(FINANCIAL_YEAR == i) |>
    mutate(
      UID = row_number()
    ) |>
    select(UID, everything())
  
  fwrite(year_data, 
         paste0("Y:\\Official Stats\\Dental\\2024_25\\csvs\\CSV outputs\\DCP csvs\\dental_dcp_",
                substr(i, 1, 4),
                "_",
                substr(i, 8, 9),
                ".csv"))
}

setwd("Y:\\Official Stats\\Dental\\2024_25\\csvs\\CSV outputs\\DCP csvs")

#get all geo data .csv files path name
den_imd_csv_files <- list.files(pattern = "^dental_dcp.*\\.csv$",
                                full.names = TRUE)

#save geo data to .zip
zip("dental_dcp_201920_202425.zip",
    files = c(den_imd_csv_files))
