#Script to create patient location clinical treatments data for 2019/20 to 2024/25
#write to CSV output files, then put these into a ZIP file

#Extract data from patient location clinical treatments fact table in warehouse
#by Region, Integrated Care Board (ICB), and Local Authority District (LAD)
#One file for region, ICB, and LA. Ward in separate files due to size.

#extract Region, ICB, and LA data ----------------------------------------------
combined_data_pat_clinic <- dplyr::tbl(
  con,
  from = dbplyr::in_schema("OST", "DS_GEOG_PAT_CLINICAL_QRY_2425")
)|> 
  collect()|>
  arrange(FINANCIAL_YEAR,
          FINANCIAL_QUARTER,
          GEOGRAPHY_ONS_CODE,
          GEOGRAPHY_ODS_CODE,
          GEOGRAPHY_TYPE,
          AGE_BAND,
          DENTAL_TREATMENT_BAND,
          MEASURE)

combined_data_pat_clinic_names <- combined_data_pat_clinic |>
  dplyr::left_join(region_lookup, by = c("GEOGRAPHY_ONS_CODE" = "NHSER21CD")) |>
  dplyr::left_join(la_lookup, by = c("GEOGRAPHY_ONS_CODE" = "LAD23CD")) |>
  dplyr::mutate(GEOGRAPHY_ODS_CODE = case_when(GEOGRAPHY_TYPE == "REGION" ~ NHSER22CDH,
                                               TRUE ~ GEOGRAPHY_ODS_CODE),
                GEOGRAPHY_ONS_CODE = case_when(GEOGRAPHY_TYPE == "REGION" ~ NHSER22CD,
                                               TRUE ~ GEOGRAPHY_ONS_CODE),
                GEOGRAPHY_NAME = case_when(GEOGRAPHY_TYPE == "REGION" ~ NHSER21NM,
                                           GEOGRAPHY_TYPE == "LOCAL_AUTHORITY" ~ LAD23NM,
                                           TRUE ~ GEOGRAPHY_NAME)) |>
  dplyr::mutate(GEOGRAPHY_ONS_CODE = case_when(grepl("L", GEOGRAPHY_ONS_CODE) ~ "Other",
                                               grepl("M", GEOGRAPHY_ONS_CODE) ~ "Other",
                                               grepl("N", GEOGRAPHY_ONS_CODE) ~ "Other",
                                               grepl("S", GEOGRAPHY_ONS_CODE) ~ "Other",
                                               grepl("W", GEOGRAPHY_ONS_CODE) ~ "Other",
                                               is.na(GEOGRAPHY_ONS_CODE) ~ "Unknown",
                                               TRUE ~ GEOGRAPHY_ONS_CODE),
                GEOGRAPHY_NAME = case_when(GEOGRAPHY_ONS_CODE == "Other" ~ "Other",
                                           GEOGRAPHY_ONS_CODE == "Unknown" ~ "Unknown",
                                           TRUE ~ GEOGRAPHY_NAME)) |>
  dplyr::select(-(c(NHSER21CDH:LAD23NM))) |>
  dplyr::group_by(FINANCIAL_YEAR,
                  FINANCIAL_QUARTER,
                  GEOGRAPHY_TYPE,
                  GEOGRAPHY_ODS_CODE,
                  GEOGRAPHY_ONS_CODE,
                  GEOGRAPHY_NAME,
                  AGE_BAND,
                  DENTAL_TREATMENT_BAND,
                  MEASURE) |>
  dplyr::summarise(TOTAL = sum(VALUE, na.rm = TRUE)) |>
  ungroup()

#get list of financial years
unique_years_clinic_pat <- unique(combined_data_pat_clinic_names$FINANCIAL_YEAR)

for(i in unique_years_clinic_pat) {
  print(i)
  year_data <- combined_data_pat_clinic_names |>
    filter(FINANCIAL_YEAR == i)|>
    mutate(
      UID = row_number()
    ) |>
    select(UID, everything())
  
  data.table::fwrite(year_data, 
                     paste0("Y:\\Official Stats\\Dental\\2024_25\\csvs\\CSV outputs\\Geo Clinical Treatment (patient) csvs\\geo_pat_dental_clinical_",
                            substr(i, 1, 4),
                            "_",
                            substr(i, 8, 9),
                            ".csv"))
}

setwd("Y:\\Official Stats\\Dental\\2024_25\\csvs\\CSV outputs\\Geo Clinical Treatment (patient) csvs")

#get all geo data .csv files path name
geo_csv_files <- list.files(pattern = "^geo_pat_dental_clinical.*\\.csv$",
                            full.names = TRUE)

#save geo data to .zip
zip("geo_pat_dental_clinical_201920_202425.zip",
    files = c(geo_csv_files))

#extract Ward data -------------------------------------------------------------
#extract 1 year at a time due to size

pat_clinic_ward_1920 <- dplyr::tbl(
  con,
  from = dbplyr::in_schema("OST", "DS_GEOG_PAT_CLINICAL_QRY_WARD_1920")
)|> 
  collect()|>
  arrange(FINANCIAL_YEAR,
          FINANCIAL_QUARTER,
          GEOGRAPHY_ONS_CODE,
          GEOGRAPHY_ODS_CODE,
          GEOGRAPHY_TYPE,
          AGE_BAND,
          DENTAL_TREATMENT_BAND,
          MEASURE)

pat_clinic_ward_2021 <- dplyr::tbl(
  con,
  from = dbplyr::in_schema("OST", "DS_GEOG_PAT_CLINICAL_QRY_WARD_2021")
)|> 
  collect()|>
  arrange(FINANCIAL_YEAR,
          FINANCIAL_QUARTER,
          GEOGRAPHY_ONS_CODE,
          GEOGRAPHY_ODS_CODE,
          GEOGRAPHY_TYPE,
          AGE_BAND,
          DENTAL_TREATMENT_BAND,
          MEASURE)

pat_clinic_ward_2122 <- dplyr::tbl(
  con,
  from = dbplyr::in_schema("OST", "DS_GEOG_PAT_CLINICAL_QRY_WARD_2122")
)|> 
  collect()|>
  arrange(FINANCIAL_YEAR,
          FINANCIAL_QUARTER,
          GEOGRAPHY_ONS_CODE,
          GEOGRAPHY_ODS_CODE,
          GEOGRAPHY_TYPE,
          AGE_BAND,
          DENTAL_TREATMENT_BAND,
          MEASURE)

pat_clinic_ward_2223 <- dplyr::tbl(
  con,
  from = dbplyr::in_schema("OST", "DS_GEOG_PAT_CLINICAL_QRY_WARD_2223")
)|> 
  collect()|>
  arrange(FINANCIAL_YEAR,
          FINANCIAL_QUARTER,
          GEOGRAPHY_ONS_CODE,
          GEOGRAPHY_ODS_CODE,
          GEOGRAPHY_TYPE,
          AGE_BAND,
          DENTAL_TREATMENT_BAND,
          MEASURE)

pat_clinic_ward_2324 <- dplyr::tbl(
  con,
  from = dbplyr::in_schema("OST", "DS_GEOG_PAT_CLINICAL_QRY_WARD_2324")
)|> 
  collect()|>
  arrange(FINANCIAL_YEAR,
          FINANCIAL_QUARTER,
          GEOGRAPHY_ONS_CODE,
          GEOGRAPHY_ODS_CODE,
          GEOGRAPHY_TYPE,
          AGE_BAND,
          DENTAL_TREATMENT_BAND,
          MEASURE)

pat_clinic_ward_2425 <- dplyr::tbl(
  con,
  from = dbplyr::in_schema("OST", "DS_GEOG_PAT_CLINICAL_QRY_WARD_2425")
)|> 
  collect()|>
  arrange(FINANCIAL_YEAR,
          FINANCIAL_QUARTER,
          GEOGRAPHY_ONS_CODE,
          GEOGRAPHY_ODS_CODE,
          GEOGRAPHY_TYPE,
          AGE_BAND,
          DENTAL_TREATMENT_BAND,
          MEASURE)

pat_clinic_ward_1920_names <- pat_clinic_ward_1920 |>
  dplyr::left_join(ward_lookup, by = c("GEOGRAPHY_ONS_CODE" = "WD23CD")) |>
  dplyr::mutate(GEOGRAPHY_ONS_CODE = case_when(grepl("L", GEOGRAPHY_ONS_CODE) ~ "Other",
                                               grepl("M", GEOGRAPHY_ONS_CODE) ~ "Other",
                                               grepl("N", GEOGRAPHY_ONS_CODE) ~ "Other",
                                               grepl("S", GEOGRAPHY_ONS_CODE) ~ "Other",
                                               grepl("W", GEOGRAPHY_ONS_CODE) ~ "Other",
                                               is.na(GEOGRAPHY_ONS_CODE) ~ "Unknown",
                                               TRUE ~ GEOGRAPHY_ONS_CODE),
                GEOGRAPHY_NAME = case_when(GEOGRAPHY_ONS_CODE == "Other" ~ "Other",
                                           GEOGRAPHY_ONS_CODE == "Unknown" ~ "Unknown",
                                           TRUE ~ WD23NM)) |>
  dplyr::select(1,2,3,4,5,6,7,8,9,10) |>
  dplyr::group_by(FINANCIAL_YEAR,
                  FINANCIAL_QUARTER,
                  GEOGRAPHY_TYPE,
                  GEOGRAPHY_ODS_CODE,
                  GEOGRAPHY_ONS_CODE,
                  GEOGRAPHY_NAME,
                  AGE_BAND,
                  DENTAL_TREATMENT_BAND,
                  MEASURE) |>
  dplyr::summarise(TOTAL = sum(VALUE, na.rm = TRUE)) |>
  ungroup() |>
  dplyr::mutate(UID = row_number()) |>
  dplyr::select(UID, everything())

View(pat_clinic_ward_1920_names |>
       dplyr::group_by(FINANCIAL_YEAR,
                       AGE_BAND,
                       DENTAL_TREATMENT_BAND,
                       MEASURE) |>
       dplyr::summarise(value = sum(TOTAL)))

pat_clinic_ward_2021_names <- pat_clinic_ward_2021 |>
  dplyr::left_join(ward_lookup, by = c("GEOGRAPHY_ONS_CODE" = "WD23CD")) |>
  dplyr::mutate(GEOGRAPHY_ONS_CODE = case_when(grepl("L", GEOGRAPHY_ONS_CODE) ~ "Other",
                                               grepl("M", GEOGRAPHY_ONS_CODE) ~ "Other",
                                               grepl("N", GEOGRAPHY_ONS_CODE) ~ "Other",
                                               grepl("S", GEOGRAPHY_ONS_CODE) ~ "Other",
                                               grepl("W", GEOGRAPHY_ONS_CODE) ~ "Other",
                                               is.na(GEOGRAPHY_ONS_CODE) ~ "Unknown",
                                               TRUE ~ GEOGRAPHY_ONS_CODE),
                GEOGRAPHY_NAME = case_when(GEOGRAPHY_ONS_CODE == "Other" ~ "Other",
                                           GEOGRAPHY_ONS_CODE == "Unknown" ~ "Unknown",
                                           TRUE ~ WD23NM)) |>
  dplyr::select(1,2,3,4,5,6,7,8,9,10) |>
  dplyr::group_by(FINANCIAL_YEAR,
                  FINANCIAL_QUARTER,
                  GEOGRAPHY_TYPE,
                  GEOGRAPHY_ODS_CODE,
                  GEOGRAPHY_ONS_CODE,
                  GEOGRAPHY_NAME,
                  AGE_BAND,
                  DENTAL_TREATMENT_BAND,
                  MEASURE) |>
  dplyr::summarise(TOTAL = sum(VALUE, na.rm = TRUE)) |>
  ungroup() |>
  dplyr::mutate(UID = row_number()) |>
  dplyr::select(UID, everything())

pat_clinic_ward_2122_names <- pat_clinic_ward_2122 |>
  dplyr::left_join(ward_lookup, by = c("GEOGRAPHY_ONS_CODE" = "WD23CD")) |>
  dplyr::mutate(GEOGRAPHY_ONS_CODE = case_when(grepl("L", GEOGRAPHY_ONS_CODE) ~ "Other",
                                               grepl("M", GEOGRAPHY_ONS_CODE) ~ "Other",
                                               grepl("N", GEOGRAPHY_ONS_CODE) ~ "Other",
                                               grepl("S", GEOGRAPHY_ONS_CODE) ~ "Other",
                                               grepl("W", GEOGRAPHY_ONS_CODE) ~ "Other",
                                               is.na(GEOGRAPHY_ONS_CODE) ~ "Unknown",
                                               TRUE ~ GEOGRAPHY_ONS_CODE),
                GEOGRAPHY_NAME = case_when(GEOGRAPHY_ONS_CODE == "Other" ~ "Other",
                                           GEOGRAPHY_ONS_CODE == "Unknown" ~ "Unknown",
                                           TRUE ~ WD23NM)) |>
  dplyr::select(1,2,3,4,5,6,7,8,9,10) |>
  dplyr::group_by(FINANCIAL_YEAR,
                  FINANCIAL_QUARTER,
                  GEOGRAPHY_TYPE,
                  GEOGRAPHY_ODS_CODE,
                  GEOGRAPHY_ONS_CODE,
                  GEOGRAPHY_NAME,
                  AGE_BAND,
                  DENTAL_TREATMENT_BAND,
                  MEASURE) |>
  dplyr::summarise(TOTAL = sum(VALUE, na.rm = TRUE)) |>
  ungroup() |>
  dplyr::mutate(UID = row_number()) |>
  dplyr::select(UID, everything())

pat_clinic_ward_2223_names <- pat_clinic_ward_2223 |>
  dplyr::left_join(ward_lookup, by = c("GEOGRAPHY_ONS_CODE" = "WD23CD")) |>
  dplyr::mutate(GEOGRAPHY_ONS_CODE = case_when(grepl("L", GEOGRAPHY_ONS_CODE) ~ "Other",
                                               grepl("M", GEOGRAPHY_ONS_CODE) ~ "Other",
                                               grepl("N", GEOGRAPHY_ONS_CODE) ~ "Other",
                                               grepl("S", GEOGRAPHY_ONS_CODE) ~ "Other",
                                               grepl("W", GEOGRAPHY_ONS_CODE) ~ "Other",
                                               is.na(GEOGRAPHY_ONS_CODE) ~ "Unknown",
                                               TRUE ~ GEOGRAPHY_ONS_CODE),
                GEOGRAPHY_NAME = case_when(GEOGRAPHY_ONS_CODE == "Other" ~ "Other",
                                           GEOGRAPHY_ONS_CODE == "Unknown" ~ "Unknown",
                                           TRUE ~ WD23NM)) |>
  dplyr::select(1,2,3,4,5,6,7,8,9,10) |>
  dplyr::group_by(FINANCIAL_YEAR,
                  FINANCIAL_QUARTER,
                  GEOGRAPHY_TYPE,
                  GEOGRAPHY_ODS_CODE,
                  GEOGRAPHY_ONS_CODE,
                  GEOGRAPHY_NAME,
                  AGE_BAND,
                  DENTAL_TREATMENT_BAND,
                  MEASURE) |>
  dplyr::summarise(TOTAL = sum(VALUE, na.rm = TRUE)) |>
  ungroup() |>
  dplyr::mutate(UID = row_number()) |>
  dplyr::select(UID, everything())

pat_clinic_ward_2324_names <- pat_clinic_ward_2324 |>
  dplyr::left_join(ward_lookup, by = c("GEOGRAPHY_ONS_CODE" = "WD23CD")) |>
  dplyr::mutate(GEOGRAPHY_ONS_CODE = case_when(grepl("L", GEOGRAPHY_ONS_CODE) ~ "Other",
                                               grepl("M", GEOGRAPHY_ONS_CODE) ~ "Other",
                                               grepl("N", GEOGRAPHY_ONS_CODE) ~ "Other",
                                               grepl("S", GEOGRAPHY_ONS_CODE) ~ "Other",
                                               grepl("W", GEOGRAPHY_ONS_CODE) ~ "Other",
                                               is.na(GEOGRAPHY_ONS_CODE) ~ "Unknown",
                                               TRUE ~ GEOGRAPHY_ONS_CODE),
                GEOGRAPHY_NAME = case_when(GEOGRAPHY_ONS_CODE == "Other" ~ "Other",
                                           GEOGRAPHY_ONS_CODE == "Unknown" ~ "Unknown",
                                           TRUE ~ WD23NM)) |>
  dplyr::select(1,2,3,4,5,6,7,8,9,10) |>
  dplyr::group_by(FINANCIAL_YEAR,
                  FINANCIAL_QUARTER,
                  GEOGRAPHY_TYPE,
                  GEOGRAPHY_ODS_CODE,
                  GEOGRAPHY_ONS_CODE,
                  GEOGRAPHY_NAME,
                  AGE_BAND,
                  DENTAL_TREATMENT_BAND,
                  MEASURE) |>
  dplyr::summarise(TOTAL = sum(VALUE, na.rm = TRUE)) |>
  ungroup() |>
  dplyr::mutate(UID = row_number()) |>
  dplyr::select(UID, everything())

pat_clinic_ward_2425_names <- pat_clinic_ward_2425 |>
  dplyr::left_join(ward_lookup, by = c("GEOGRAPHY_ONS_CODE" = "WD23CD")) |>
  dplyr::mutate(GEOGRAPHY_ONS_CODE = case_when(grepl("L", GEOGRAPHY_ONS_CODE) ~ "Other",
                                               grepl("M", GEOGRAPHY_ONS_CODE) ~ "Other",
                                               grepl("N", GEOGRAPHY_ONS_CODE) ~ "Other",
                                               grepl("S", GEOGRAPHY_ONS_CODE) ~ "Other",
                                               grepl("W", GEOGRAPHY_ONS_CODE) ~ "Other",
                                               is.na(GEOGRAPHY_ONS_CODE) ~ "Unknown",
                                               TRUE ~ GEOGRAPHY_ONS_CODE),
                GEOGRAPHY_NAME = case_when(GEOGRAPHY_ONS_CODE == "Other" ~ "Other",
                                           GEOGRAPHY_ONS_CODE == "Unknown" ~ "Unknown",
                                           TRUE ~ WD23NM)) |>
  dplyr::select(1,2,3,4,5,6,7,8,9,10) |>
  dplyr::group_by(FINANCIAL_YEAR,
                  FINANCIAL_QUARTER,
                  GEOGRAPHY_TYPE,
                  GEOGRAPHY_ODS_CODE,
                  GEOGRAPHY_ONS_CODE,
                  GEOGRAPHY_NAME,
                  AGE_BAND,
                  DENTAL_TREATMENT_BAND,
                  MEASURE) |>
  dplyr::summarise(TOTAL = sum(VALUE, na.rm = TRUE)) |>
  ungroup() |>
  dplyr::mutate(UID = row_number()) |>
  dplyr::select(UID, everything())

#TO DO: rewrite code so file writing is done in a loop or similar
data.table::fwrite(pat_clinic_ward_1920_names, "Y:\\Official Stats\\Dental\\2024_25\\csvs\\CSV outputs\\Geo Clinical Treatment (patient ward) csvs\\geo_pat_dental_clinical_ward_1920.csv")
data.table::fwrite(pat_clinic_ward_2021_names, "Y:\\Official Stats\\Dental\\2024_25\\csvs\\CSV outputs\\Geo Clinical Treatment (patient ward) csvs\\geo_pat_dental_clinical_ward_2021.csv")
data.table::fwrite(pat_clinic_ward_2122_names, "Y:\\Official Stats\\Dental\\2024_25\\csvs\\CSV outputs\\Geo Clinical Treatment (patient ward) csvs\\geo_pat_dental_clinical_ward_2122.csv")
data.table::fwrite(pat_clinic_ward_2223_names, "Y:\\Official Stats\\Dental\\2024_25\\csvs\\CSV outputs\\Geo Clinical Treatment (patient ward) csvs\\geo_pat_dental_clinical_ward_2223.csv")
data.table::fwrite(pat_clinic_ward_2324_names, "Y:\\Official Stats\\Dental\\2024_25\\csvs\\CSV outputs\\Geo Clinical Treatment (patient ward) csvs\\geo_pat_dental_clinical_ward_2324.csv")
data.table::fwrite(pat_clinic_ward_2425_names, "Y:\\Official Stats\\Dental\\2024_25\\csvs\\CSV outputs\\Geo Clinical Treatment (patient ward) csvs\\geo_pat_dental_clinical_ward_2425.csv")

setwd("Y:\\Official Stats\\Dental\\2024_25\\csvs\\CSV outputs\\Geo Clinical Treatment (patient ward) csvs")

#get all geo data .csv files path name
geo_csv_files <- list.files(pattern = "^geo_pat_dental_clinical_ward.*\\.csv$",
                            full.names = TRUE)

#save geo data to .zip
zip("geo_pat_dental_clinical_ward_201920_202425.zip",
    files = c(geo_csv_files))