#Script to create Index of Multiple Deprivation (IMD) quintile activity data 
#for 2019/20 to 2024/25
#write to CSV output files, then put these into a ZIP file

#extract IMD data from patient location dental activity fact table in warehouse
imd_csv_data <- dplyr::tbl(con,
                                from = dbplyr::in_schema("OST", "DS_PAT_ACTIVITY_FACT_2425")) |>

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
  #aggregate quintiles (1 to 5) up from deciles (1 to 10)
  dplyr::mutate(IMD_QUINTILE = case_when(IMD_DECILE %in% c(1, 2)  ~ "1",
                                           IMD_DECILE %in% c(3, 4) ~ "2",
                                           IMD_DECILE %in% c(5, 6) ~ "3",
                                           IMD_DECILE %in% c(7, 8) ~ "4",
                                           IMD_DECILE %in% c(9, 10) ~ "5",
                                           TRUE ~ 'Unknown'
  )) |>
  dplyr::select(-IMD_DECILE) |>
  group_by(
    TREATMENT_YEAR,
    FINANCIAL_QUARTER,
    TREATMENT_CHARGE_BAND_COMB,
    IMD_QUINTILE
  ) |>
  summarise(
    UDA = sum(UDA, na.rm = TRUE),
    COT = sum(COT, na.rm = TRUE),
    .groups = "drop"
  ) |>
  collect() |>
  select(
    FINANCIAL_YEAR = TREATMENT_YEAR,
    FINANCIAL_QUARTER,
    DENTAL_TREATMENT_BAND = TREATMENT_CHARGE_BAND_COMB,	
    IMD_QUINTILE,
    UDA,	
    COT
  )|>
  arrange(FINANCIAL_QUARTER,
          DENTAL_TREATMENT_BAND,
          IMD_QUINTILE) |>
  collect()

#get list of financial years
unique_years <- unique(imd_csv_data$FINANCIAL_YEAR)

#loop through financial years to filter data and save as .csv
for(i in unique_years) {
  print(i)
  year_data <- imd_csv_data |>
    filter(FINANCIAL_YEAR == i) |>
    mutate(
      UID = row_number()
    ) |>
    select(UID, everything())
  
  fwrite(year_data, 
         paste0("Y:\\Official Stats\\Dental\\2024_25\\csvs\\CSV outputs\\IMD csvs\\dental_imd_",
                substr(i, 1, 4),
                "_",
                substr(i, 8, 9),
                ".csv"))
}

setwd("Y:\\Official Stats\\Dental\\2024_25\\csvs\\CSV outputs\\IMD csvs")

#get all geo data .csv files path name
den_imd_csv_files <- list.files(pattern = "^dental_imd.*\\.csv$",
                                full.names = TRUE)

#save geo data to .zip
zip("dental_imd_201920_202425.zip",
    files = c(den_imd_csv_files))
