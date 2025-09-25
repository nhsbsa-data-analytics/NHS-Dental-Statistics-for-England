#Script to create dental activity data for 2019/20 to 2025/26 by individual contract level
#statistical disclosure control applied to suppress patient totals of fewer than 5
#write to CSV output files, then put these into a ZIP file

#Extract data from 24 month patient lists (for adults) in warehouse
#and 12 month patient lists (for children) in warehouse
#data for 2025/26 will only be a partial year, to 30/6/2025

#connect to warehouse ----------------------------------------------------------
# con <- nhsbsaR::con_nhsbsa(dsn = "FBS_8192k",
#                            driver = "Oracle in OraClient19Home1",
#                            "DWCP")

#create look up of contractor details
DS_CONTRACT_DIM <- dplyr::tbl(con,
                                    from = dbplyr::in_schema("DIM", "DS_CONTRACT_DIM")) |>
  mutate(CONTRACTOR_TAG = sql("substr(to_char(CONTRACT_NUMBER), 1, 6) || '/' || substr(to_char(CONTRACT_NUMBER), 7, 4)")) |>
  select(
    YEAR_MONTH,
    CONTRACT_NUMBER,
    CONTRACTOR_TAG,
    PPC_LOCATION_V_CODE,
    PROVIDER_NAME,
    PPC_ADDRESS_POSTCODE
  )

#pull data from DS_PATIENT_LIST_24M and join on contractor look up
dental_patients_seen_data_adult <- 
  dplyr::tbl(con,
             from = dbplyr::in_schema("AML", "DS_PATIENT_LIST_24M")) |>
  filter(ONS_COUNTRY == "E92000001",
         AGE_AT_PERIOD_END > 17
         ) |>
  mutate(
    PATIENT_TYPE = "Adult",
    AGE_BAND = case_when(
      AGE_AT_PERIOD_END > 17 & AGE_AT_PERIOD_END < 65 ~ "18-64",
      AGE_AT_PERIOD_END > 64 & AGE_AT_PERIOD_END < 75 ~ "65-74",
      AGE_AT_PERIOD_END > 74 & AGE_AT_PERIOD_END < 85 ~ "75-84",
      AGE_AT_PERIOD_END > 84 ~ "85+"
    ),
    PSEEN_END_DATE = sql("LAST_DAY(TO_DATE(YEAR_MONTH, 'YYYYMM'))"),
    FINANCIAL_YEAR = case_when(
      PSEEN_END_DATE > as.Date("2019-03-31") & PSEEN_END_DATE < as.Date("2020-04-01") ~ "2019/2020",
      PSEEN_END_DATE > as.Date("2020-03-31") & PSEEN_END_DATE < as.Date("2021-04-01") ~ "2020/2021",
      PSEEN_END_DATE > as.Date("2021-03-31") & PSEEN_END_DATE < as.Date("2022-04-01") ~ "2021/2022",
      PSEEN_END_DATE > as.Date("2022-03-31") & PSEEN_END_DATE < as.Date("2023-04-01") ~ "2022/2023",
      PSEEN_END_DATE > as.Date("2023-03-31") & PSEEN_END_DATE < as.Date("2024-04-01") ~ "2023/2024",
      PSEEN_END_DATE > as.Date("2024-03-31") & PSEEN_END_DATE < as.Date("2025-04-01") ~ "2024/2025",
      PSEEN_END_DATE > as.Date("2025-03-31") & PSEEN_END_DATE < as.Date("2025-07-01") ~ "2025/2026"
    )
  ) |>
  filter(FINANCIAL_YEAR %in% c("2019/2020", "2020/2021", "2021/2022", "2022/2023", "2023/2024", "2024/2025", "2025/2026")) |>
  left_join(
    DS_CONTRACT_DIM,
    by = c(
      "YEAR_MONTH" = "YEAR_MONTH",
      "CONTRACT_NUMBER" = "CONTRACT_NUMBER"
    )
  ) |>
  select(PSEEN_END_DATE,
         CONTRACTOR_TAG,
         PRACTICE_CODE = PPC_LOCATION_V_CODE,
         PRACTICE_NAME = PROVIDER_NAME,
         PRACTICE_POSTCODE = PPC_ADDRESS_POSTCODE,
         PATIENT_TYPE,
         AGE_BAND,
         PATIENT_COUNT_N
         )  |>
  group_by(
    across(-PATIENT_COUNT_N)
  ) |>
  summarise(
    PATIENTS_SEEN = sum(PATIENT_COUNT_N, na.rm = T),
    .groups = "drop"
  ) |>
  collect()

#pull data from DS_PATIENT_LIST_12M and join on contractor look up
dental_patients_seen_data_child <- 
  dplyr::tbl(con,
             from = dbplyr::in_schema("AML", "DS_PATIENT_LIST_12M")) |>
  filter(ONS_COUNTRY == "E92000001",
         AGE_AT_PERIOD_END <= 17
  ) |>
  mutate(
    PATIENT_TYPE = "Child",
    AGE_BAND = as.character(AGE_AT_PERIOD_END),
    PSEEN_END_DATE = sql("LAST_DAY(TO_DATE(YEAR_MONTH, 'YYYYMM'))"),
    FINANCIAL_YEAR = case_when(
      PSEEN_END_DATE > as.Date("2019-03-31") & PSEEN_END_DATE < as.Date("2020-04-01") ~ "2019/2020",
      PSEEN_END_DATE > as.Date("2020-03-31") & PSEEN_END_DATE < as.Date("2021-04-01") ~ "2020/2021",
      PSEEN_END_DATE > as.Date("2021-03-31") & PSEEN_END_DATE < as.Date("2022-04-01") ~ "2021/2022",
      PSEEN_END_DATE > as.Date("2022-03-31") & PSEEN_END_DATE < as.Date("2023-04-01") ~ "2022/2023",
      PSEEN_END_DATE > as.Date("2023-03-31") & PSEEN_END_DATE < as.Date("2024-04-01") ~ "2023/2024",
      PSEEN_END_DATE > as.Date("2024-03-31") & PSEEN_END_DATE < as.Date("2025-04-01") ~ "2024/2025",
      PSEEN_END_DATE > as.Date("2025-03-31") & PSEEN_END_DATE < as.Date("2025-07-01") ~ "2025/2026"
    )
  ) |>
  filter(FINANCIAL_YEAR %in% c("2019/2020", "2020/2021", "2021/2022", "2022/2023", "2023/2024", "2024/2025", "2025/2026")) |>
  left_join(
    DS_CONTRACT_DIM,
    by = c(
      "YEAR_MONTH" = "YEAR_MONTH",
      "CONTRACT_NUMBER" = "CONTRACT_NUMBER"
    )
  ) |>
  select(PSEEN_END_DATE,
         CONTRACTOR_TAG,
         PRACTICE_CODE = PPC_LOCATION_V_CODE,
         PRACTICE_NAME = PROVIDER_NAME,
         PRACTICE_POSTCODE = PPC_ADDRESS_POSTCODE,
         PATIENT_TYPE,
         AGE_BAND,
         PATIENT_COUNT_N
  )  |>
  group_by(
    across(-PATIENT_COUNT_N)
  ) |>
  summarise(
    PATIENTS_SEEN = sum(PATIENT_COUNT_N, na.rm = T),
    .groups = "drop"
  ) |>
  collect()

#apply filters to extract only required months data
dental_patients_seen_data_overall <- dental_patients_seen_data_adult |>
  bind_rows(dental_patients_seen_data_child) |>
  mutate(
  PSEEN_END_DATE = as.Date(PSEEN_END_DATE)
  ) |>
  mutate(    FINANCIAL_YEAR = case_when(
    PSEEN_END_DATE > as.Date("2019-03-31") & PSEEN_END_DATE < as.Date("2020-04-01") ~ "2019/2020",
    PSEEN_END_DATE > as.Date("2020-03-31") & PSEEN_END_DATE < as.Date("2021-04-01") ~ "2020/2021",
    PSEEN_END_DATE > as.Date("2021-03-31") & PSEEN_END_DATE < as.Date("2022-04-01") ~ "2021/2022",
    PSEEN_END_DATE > as.Date("2022-03-31") & PSEEN_END_DATE < as.Date("2023-04-01") ~ "2022/2023",
    PSEEN_END_DATE > as.Date("2023-03-31") & PSEEN_END_DATE < as.Date("2024-04-01") ~ "2023/2024",
    PSEEN_END_DATE > as.Date("2024-03-31") & PSEEN_END_DATE < as.Date("2025-04-01") ~ "2024/2025",
    PSEEN_END_DATE > as.Date("2025-03-31") & PSEEN_END_DATE < as.Date("2025-07-01") ~ "2025/2026"
  )) |>
  arrange(
    PSEEN_END_DATE,
    PRACTICE_CODE,
    PATIENT_TYPE,
    AGE_BAND
  ) 

#check how many rows affected by applying SDC
# view(dental_patients_seen_data_overall |>
#        dplyr::mutate(SDC_flag = case_when(
#          PATIENTS_SEEN <= 4 ~ "Y",
#          TRUE ~ "N"
#        )) |>
#        dplyr::count(SDC_flag))

#check by financial year
# view(dental_patients_seen_data_overall |> 
#        dplyr::filter(PATIENTS_SEEN >= 5) |>
#        dplyr::group_by(FINANCIAL_YEAR) |>
#        dplyr::summarise(total_non_sdc_patients = sum(PATIENTS_SEEN)))
# view(dental_patients_seen_data_overall |> 
#        dplyr::filter(PATIENTS_SEEN <= 4) |>
#        dplyr::group_by(FINANCIAL_YEAR) |>
#        dplyr::summarise(total_sdc_patients = sum(PATIENTS_SEEN)))

#apply sdc redaction using sdc function
dental_patients_seen_data_sdc <- dental_patients_seen_data_overall |>
  apply_sdc(suppress_column = "PATIENTS_SEEN")

#when comparing totals for QR, may need to run data without SDC applied
#use the unredacted data for testing, then apply SDC and write to .csv outputs

#get list of financial years
unique_years <- unique(dental_patients_seen_data_sdc$FINANCIAL_YEAR)

#loop through financial years to filter data and save as .csv
#may need to adjust file names to clarify they are SDC version
#if any non-SDC versions also produced for testing
for(i in unique_years) {
  print(i)
year_data <- dental_patients_seen_data_sdc |>
  filter(FINANCIAL_YEAR == i) |>
  select(-FINANCIAL_YEAR) |>
  mutate(
    UID = row_number()
  ) |>
  select(UID, everything())

fwrite(year_data, 
       paste0("Y:\\Official Stats\\Dental\\2024_25\\csvs\\CSV outputs\\Patients Seen csvs SDC\\dental_patients_seen_",
              substr(i, 1, 4),
              "_",
              substr(i, 8, 9),
              ".csv"))
}

setwd("Y:\\Official Stats\\Dental\\2024_25\\csvs\\CSV outputs\\Patients Seen csvs SDC\\")

#get all geo data .csv files path name
den_act_csv_files <- list.files(pattern = "^dental_patients_seen.*\\.csv$",
                            full.names = TRUE)

#save geo data to .zip
zip("dental_patients_seen_201920_202526.zip",
    files = c(den_act_csv_files))

#spot check values for specific groups, compare against previously published data
# check <- dental_patients_seen_data_overall |>
#   filter(FINANCIAL_YEAR == "2023/2024",
#          PSEEN_END_DATE == as.Date("2024-03-31"),
#          PATIENT_TYPE == "Adult")
# 
# sum(check$PATIENTS_SEEN)
