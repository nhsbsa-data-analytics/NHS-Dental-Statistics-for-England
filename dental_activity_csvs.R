
#pull dental activity data
activity_csv_data <- dplyr::tbl(con,
                       from = dbplyr::in_schema("OST", "DS_CONT_ACTIVITY_FACT_2425")) |>
  filter(
    TREATMENT_YEAR >= "2019/2020" & TREATMENT_YEAR <= "2024/2025",
    FORM_TYPE == "G", 
    QUARTER != "unallocated_1",
    QUARTER != "unallocated_2",
    !(TREATMENT_CHARGE_BAND_COMB %in% c("N/A", "Only a Domiciliary Visit", "Free - Unknown"))
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
    FORMATTED_CONTRACT_NUMBER, 
    PPC_LOCATION_V_CODE,
    PPC_ADDRESS_POSTCODE,
    PATIENT_TYPE,
    TREATMENT_CHARGE_BAND_COMB
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
    CONTRACTOR_TAG = FORMATTED_CONTRACT_NUMBER,
    PRACTICE_CODE = PPC_LOCATION_V_CODE,
    PRACTICE_POSTCODE = PPC_ADDRESS_POSTCODE,
    PATIENT_TYPE,
    DENTAL_TREATMENT_BAND = TREATMENT_CHARGE_BAND_COMB,	
    UDA,	
    COT
  )|>
  arrange(FINANCIAL_QUARTER,
          CONTRACTOR_TAG,
          PRACTICE_CODE,
          PATIENT_TYPE,
          DENTAL_TREATMENT_BAND)

#get list of financial years
unique_years <- unique(activity_csv_data$FINANCIAL_YEAR)

#loop through financial years to filter data and save a .csv
for(i in unique_years) {
  print(i)
year_data <- activity_csv_data |>
  filter(FINANCIAL_YEAR == i) |>
  mutate(
    UID = row_number()
  ) |>
  select(UID, everything())

fwrite(year_data, 
       paste0("Y:\\Official Stats\\Dental\\2024_25\\csvs\\CSV outputs\\Dental Activity csvs\\dental_activity_",
              substr(i, 1, 4),
              "_",
              substr(i, 8, 9),
              ".csv"))
}

setwd("Y:\\Official Stats\\Dental\\2024_25\\csvs\\CSV outputs\\Dental Activity csvs")

#get all geo data .csv files path name
den_act_csv_files <- list.files(pattern = "^dental_activity.*\\.csv$",
                            full.names = TRUE)

#save geo data to .zip
zip("dental_activity_201920_202425.zip",
    files = c(den_act_csv_files))
