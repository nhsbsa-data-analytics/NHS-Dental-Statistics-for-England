#Script to create contract location clinical treatments data for 2019/20 to 2024/25
#write to CSV output files, then put these into a ZIP file

#Extract data from contract location clinical treatments fact table in warehouse
#by Region, Integrated Care Board (ICB), and Local Authority District (LAD)

combined_data_clinic_cont <- dplyr::tbl(
  con,
  from = dbplyr::in_schema("OST", "DS_GEOG_CONT_CLINICAL_QRY_2425")
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

#get list of financial years
unique_years_clinic_cont <- unique(combined_data_clinic_cont$FINANCIAL_YEAR)

#loop through financial years to filter data and save a .csv
for(i in unique_years_clinic_cont) {
  print(i)
  year_data <- combined_data_clinic_cont |>
    filter(FINANCIAL_YEAR == i)|>
    mutate(
      UID = row_number()
    ) |>
    select(UID, everything())
  
  data.table::fwrite(year_data, 
                     paste0("Y:\\Official Stats\\Dental\\2024_25\\csvs\\CSV outputs\\Geo Clinical Treatment (contract) csvs\\geo_cont_dental_clinical_",
                            substr(i, 1, 4),
                            "_",
                            substr(i, 8, 9),
                            ".csv"))
}
setwd("Y:\\Official Stats\\Dental\\2024_25\\csvs\\CSV outputs\\Geo Clinical Treatment (contract) csvs")

#get all geo data .csv files path name
geo_csv_files <- list.files(pattern = "^geo_cont_dental_clinical.*\\.csv$",
                            full.names = TRUE)

#save geo data to .zip
zip("geo_cont_dental_clinical_201920_202425.zip",
    files = c(geo_csv_files))