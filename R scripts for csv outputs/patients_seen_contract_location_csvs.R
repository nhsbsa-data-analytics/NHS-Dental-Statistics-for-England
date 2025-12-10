#Script to create contract location dental activity data for 2019/20 to 2025/26
#statistical disclosure control applied to suppress patient totals of fewer than 5
#write to CSV output files, then put these into a ZIP file

#Extract data from 24 month patient lists (for adults) in warehouse
#and 12 month patient lists (for children) in warehouse
#by Region, Integrated Care Board (ICB), and Local Authority District (LAD) levels

#data for 2025/26 will only be a partial year, to 30/6/2025

#Load required population data, if not already loaded into environment ---------
nhs_region_pop_by_age <- get_ICB_SICBL_NHSER_pop_age(link = "https://www.ons.gov.uk/file?uri=/peoplepopulationandcommunity/populationandmigration/populationestimates/datasets/clinicalcommissioninggroupmidyearpopulationestimates/mid2011tomid2022integratedcareboards2023geography/sapeicb202320112022.xlsx",
                                             location_measure = "NHSER")

icb_pop_by_age <- get_ICB_SICBL_NHSER_pop_age(link = "https://www.ons.gov.uk/file?uri=/peoplepopulationandcommunity/populationandmigration/populationestimates/datasets/clinicalcommissioninggroupmidyearpopulationestimates/mid2011tomid2022integratedcareboards2023geography/sapeicb202320112022.xlsx",
                            location_measure = "ICB")

la_pop_age <- get_la_pop_age()

#get lookups if not already loaded into environment
#collect ons code lookup from DWH
# ons_code_lookup <- dplyr::tbl(con,
#                               from = dbplyr::in_schema("OST", "ONS_CODES_LOOKUP_23"))|>
#   collect()

#get nhs region codes from lookup
# region_codes <- ons_code_lookup |> 
#   select(NHSER23CDH, NHSER23CD) |>
#   unique()

#get ICB codes from lookup
# icb_codes <- ons_code_lookup |> 
#   select(ICB23CDH, ICB23CD) |>
#   unique()

#build time periods and contractor details from data warehouse -----------------
tdim <- dplyr::tbl(
  con,
  from = dbplyr::in_schema("DIM", "DS_YEAR_END_REPORTING_PERIOD")
) |>
  group_by(FINANCIAL_YEAR = TREATMENT_YEAR) |>
  summarise(PERIOD_START = min(YEAR_MONTH),
            PERIOD_END = max(YEAR_MONTH)) |>
  filter(between(FINANCIAL_YEAR, "2019/2020", "2025/2026"))

ONS <- dplyr::tbl(con,
                  from = dbplyr::in_schema("DIM", "DS_ONS_EDEN_COMBINED_DIM")) |>
  select(
    POSTCODE,
    COUNTRY_CODE,
    LAD_CODE,
    LAD_NAME
  )

REG <-  dplyr::tbl(con,
                   from = dbplyr::in_schema("DIM", "DS_REGIONS_DIM")) |>
  select(
    REGION_CODE,
    ONS_COUNTRY,
    YEAR_MONTH,
    REGION_DESCRIPTION
  )

#create look up of contractor details
CONTRACTOR_DETAILS <- dplyr::tbl(con,
                                 from = dbplyr::in_schema("DIM", "DS_CONTRACT_DIM")) |>
  mutate(CONTRACTOR_TAG = sql("substr(to_char(CONTRACT_NUMBER), 1, 6) || '/' || substr(to_char(CONTRACT_NUMBER), 7, 4)")) |>
  select(
    YEAR_MONTH,
    ONS_COUNTRY,
    PPC_ADDRESS_POSTCODE,
    CONTRACT_NUMBER,
    COMMISSIONER_CODE,
    COMMISSIONER_NAME,
    REGION
  ) |>
  # add inner join to tdim. this gives contract details as at june of following year
  inner_join(
    tdim,
    by = c(
      "YEAR_MONTH" = "PERIOD_END"
    )
  ) |> 
  left_join(
    ONS,
    by = c(
      "PPC_ADDRESS_POSTCODE" = "POSTCODE",
      "ONS_COUNTRY" = "COUNTRY_CODE"
    )
  ) |>
  inner_join(
    REG,
    by = c("REGION" = "REGION_CODE",
           "ONS_COUNTRY" = "ONS_COUNTRY",
           "YEAR_MONTH" = "YEAR_MONTH")
  )

DS_CONT_DETAILS_LTST_DIM <- dplyr::tbl(con,
                                       from = dbplyr::in_schema("OST", "DS_CONT_DETAILS_LTST_DIM")) |>
  select(CONTRACT_NUMBER,
         COMMISSIONER_CODE,
         COMMISSIONER_NAME
  )

DS_CONT_DETAILS_LTST_DIM_LA <- dplyr::tbl(con,
                                          from = dbplyr::in_schema("OST", "DS_CONT_DETAILS_LTST_DIM")) |>
  select(CONTRACT_NUMBER,
         LAD_CODE,
         LAD_NAME
  )


# NHS region data --------------------------------------------------------------
#get required columns from population data
region_pop <- nhs_region_pop_by_age |>
  select(FINANCIAL_YEAR,
         NHSER_CODE,     
         AGE_BAND,
         POPULATION) |>
  filter(AGE_BAND != "TOTAL") 

#pull data from DS_PATIENT_LIST_24M for NHS region
pat_seen_data_region_adult <- 
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
  inner_join(
    CONTRACTOR_DETAILS,
    by = c(
      "FINANCIAL_YEAR" = "FINANCIAL_YEAR",
      "CONTRACT_NUMBER" = "CONTRACT_NUMBER"
    )
  ) |>
  mutate(GEOGRAPHY_TYPE = "REGION") |>
  select(PSEEN_END_DATE,
         GEOGRAPHY_TYPE,
         GEOGRAPHY_ODS_CODE = REGION.y,
         GEOGRAPHY_NAME = REGION_DESCRIPTION,
         PATIENT_TYPE,
         AGE_BAND,
         PATIENT_COUNT_N,
         FINANCIAL_YEAR
  )  |>
  group_by(
    across(-PATIENT_COUNT_N)
  ) |>
  summarise(
    PATIENTS_SEEN = sum(PATIENT_COUNT_N, na.rm = T),
    .groups = "drop"
  ) |>
  collect()|>
  left_join(
    region_codes,
    by = c("GEOGRAPHY_ODS_CODE" = "NHSER23CDH")
  ) |>
  rename(
    "GEOGRAPHY_ONS_CODE" = "NHSER23CD"
  ) |>
  relocate(
    "GEOGRAPHY_ONS_CODE", .after = "GEOGRAPHY_ODS_CODE" 
  ) |>
  mutate(
    PSEEN_END_DATE = as.Date(PSEEN_END_DATE)
  ) |>
  left_join(
    region_pop,
    by = c(
      "FINANCIAL_YEAR" = "FINANCIAL_YEAR",
      "GEOGRAPHY_ONS_CODE" = "NHSER_CODE",
      "AGE_BAND" = "AGE_BAND"
    )
  ) |>
  arrange(
    GEOGRAPHY_NAME,
    AGE_BAND,
    PSEEN_END_DATE 
  ) |>
  mutate(
    POPULATION = zoo::na.locf(POPULATION)
  ) 

pat_seen_data_region_child <- 
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
  inner_join(
    CONTRACTOR_DETAILS,
    by = c(
      "FINANCIAL_YEAR" = "FINANCIAL_YEAR",
      "CONTRACT_NUMBER" = "CONTRACT_NUMBER"
    )
  ) |>
  mutate(GEOGRAPHY_TYPE = "REGION") |>
  select(PSEEN_END_DATE,
         GEOGRAPHY_TYPE,
         GEOGRAPHY_ODS_CODE = REGION.y,
         GEOGRAPHY_NAME = REGION_DESCRIPTION,
         PATIENT_TYPE,
         AGE_BAND,
         PATIENT_COUNT_N,
         FINANCIAL_YEAR
  )  |>
  group_by(
    across(-PATIENT_COUNT_N)
  ) |>
  summarise(
    PATIENTS_SEEN = sum(PATIENT_COUNT_N, na.rm = T),
    .groups = "drop"
  ) |>
  collect()|>
  left_join(
    region_codes,
    by = c("GEOGRAPHY_ODS_CODE" = "NHSER23CDH")
  ) |>
  rename(
    "GEOGRAPHY_ONS_CODE" = "NHSER23CD"
  ) |>
  relocate(
    "GEOGRAPHY_ONS_CODE", .after = "GEOGRAPHY_ODS_CODE" 
  ) |>
  mutate(
    PSEEN_END_DATE = as.Date(PSEEN_END_DATE)
  ) |>
  left_join(
    region_pop,
    by = c(
      "FINANCIAL_YEAR" = "FINANCIAL_YEAR",
      "GEOGRAPHY_ONS_CODE" = "NHSER_CODE",
      "AGE_BAND" = "AGE_BAND"
    )
  ) |>
  arrange(
    GEOGRAPHY_NAME,
    AGE_BAND,
    PSEEN_END_DATE 
  ) |>
  mutate(
    POPULATION = zoo::na.locf(POPULATION)
  ) 

# ICB data ---------------------------------------------------------------------
#get required columns from population data
ICB_pop <- icb_pop_by_age |>
  select(FINANCIAL_YEAR,
         ICB_CODE,    #change to ICB_CODE?
         AGE_BAND,
         POPULATION) |>
  filter(AGE_BAND != "TOTAL") 

#pull data from DS_PATIENT_LIST_24M for ICB
pat_seen_data_icb_adult <- 
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
  inner_join(
    DS_CONT_DETAILS_LTST_DIM,
    by = c(
      "CONTRACT_NUMBER" = "CONTRACT_NUMBER"
    )
  ) |>
  mutate(GEOGRAPHY_TYPE = "ICB") |>
  select(PSEEN_END_DATE,
         GEOGRAPHY_TYPE,
         GEOGRAPHY_ODS_CODE = COMMISSIONER_CODE.y,
         GEOGRAPHY_NAME = COMMISSIONER_NAME,
         PATIENT_TYPE,
         AGE_BAND,
         PATIENT_COUNT_N,
         FINANCIAL_YEAR
  )  |>
  group_by(
    across(-PATIENT_COUNT_N)
  ) |>
  summarise(
    PATIENTS_SEEN = sum(PATIENT_COUNT_N, na.rm = T),
    .groups = "drop"
  ) |>
  collect() |>
  left_join(
    icb_codes,
    by = c("GEOGRAPHY_ODS_CODE" = "ICB23CDH")
  ) |>
  rename(
    "GEOGRAPHY_ONS_CODE" = "ICB23CD"
  ) |>
  relocate(
    "GEOGRAPHY_ONS_CODE", .after = "GEOGRAPHY_ODS_CODE" 
  ) |>
  mutate(
    PSEEN_END_DATE = as.Date(PSEEN_END_DATE)
  ) |>
  left_join(
    ICB_pop,
    by = c(
      "FINANCIAL_YEAR" = "FINANCIAL_YEAR",
      "GEOGRAPHY_ONS_CODE" = "ICB_CODE",
      "AGE_BAND" = "AGE_BAND"
    )
  ) |>
  arrange(
    GEOGRAPHY_NAME,
    AGE_BAND,
    PSEEN_END_DATE 
  ) |>
  mutate(
    POPULATION = zoo::na.locf(POPULATION)
  )

pat_seen_data_icb_child <- 
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
  inner_join(
    DS_CONT_DETAILS_LTST_DIM,
    by = c(
      "CONTRACT_NUMBER" = "CONTRACT_NUMBER"
    )
  ) |>
  mutate(GEOGRAPHY_TYPE = "ICB") |>
  select(PSEEN_END_DATE,
         GEOGRAPHY_TYPE,
         GEOGRAPHY_ODS_CODE = COMMISSIONER_CODE.y,
         GEOGRAPHY_NAME = COMMISSIONER_NAME,
         PATIENT_TYPE,
         AGE_BAND,
         PATIENT_COUNT_N,
         FINANCIAL_YEAR
  )  |>
  group_by(
    across(-PATIENT_COUNT_N)
  ) |>
  summarise(
    PATIENTS_SEEN = sum(PATIENT_COUNT_N, na.rm = T),
    .groups = "drop"
  ) |>
  collect() |>
  left_join(
    icb_codes,
    by = c("GEOGRAPHY_ODS_CODE" = "ICB23CDH")
  ) |>
  rename(
    "GEOGRAPHY_ONS_CODE" = "ICB23CD"
  ) |>
  relocate(
    "GEOGRAPHY_ONS_CODE", .after = "GEOGRAPHY_ODS_CODE" 
  ) |>
  mutate(
    PSEEN_END_DATE = as.Date(PSEEN_END_DATE)
  ) |>
  left_join(
    ICB_pop,
    by = c(
      "FINANCIAL_YEAR" = "FINANCIAL_YEAR",
      "GEOGRAPHY_ONS_CODE" = "ICB_CODE",
      "AGE_BAND" = "AGE_BAND"
    )
  ) |>
  arrange(
    GEOGRAPHY_NAME,
    AGE_BAND,
    PSEEN_END_DATE 
  ) |>
  mutate(
    POPULATION = zoo::na.locf(POPULATION)
  )
# LA data ----------------------------------------------------------------------

LA_pop <- la_pop_age |>
  select(FINANCIAL_YEAR,
         LA_CODE,
         AGE_BAND,
         POPULATION)

#pull data from DS_PATIENT_LIST_24M for LA
pat_seen_data_la_adult <- 
  dplyr::tbl(con,
             from = dbplyr::in_schema("AML", "DS_PATIENT_LIST_24M")) |>
  filter(ONS_COUNTRY == "E92000001",
         AGE_AT_PERIOD_END > 17,
         
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
  inner_join(
    DS_CONT_DETAILS_LTST_DIM_LA,
    by = c(
      "CONTRACT_NUMBER" = "CONTRACT_NUMBER"
    )
  ) |>
  mutate(GEOGRAPHY_TYPE = "LOCAL_AUTHORITY",
         GEOGRAPHY_ODS_CODE = "N/A") |>
  select(PSEEN_END_DATE,
         GEOGRAPHY_TYPE,
         GEOGRAPHY_ODS_CODE,
         GEOGRAPHY_ONS_CODE = LAD_CODE,
         GEOGRAPHY_NAME = LAD_NAME,
         PATIENT_TYPE,
         AGE_BAND,
         PATIENT_COUNT_N,
         FINANCIAL_YEAR
  )  |>
  group_by(
    across(-PATIENT_COUNT_N)
  ) |>
  summarise(
    PATIENTS_SEEN = sum(PATIENT_COUNT_N, na.rm = T),
    .groups = "drop"
  ) |>
  collect() |>
  mutate(
    PSEEN_END_DATE = as.Date(PSEEN_END_DATE)
  ) |>
  left_join(
    LA_pop,
    by = c(
      "FINANCIAL_YEAR" = "FINANCIAL_YEAR",
      "GEOGRAPHY_ONS_CODE" = "LA_CODE",
      "AGE_BAND" = "AGE_BAND"
    )
  ) |>
  arrange(
    GEOGRAPHY_NAME,
    AGE_BAND,
    PSEEN_END_DATE 
  ) |>
  mutate(
    POPULATION = zoo::na.locf(POPULATION)
  ) 

pat_seen_data_la_child<- 
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
  filter(FINANCIAL_YEAR %in% c("2019/2020", "2020/2021", "2021/2022", "2022/2023", "2023/2024", "2024/2025","2025/2026")) |>
  inner_join(
    DS_CONT_DETAILS_LTST_DIM_LA,
    by = c(
      "CONTRACT_NUMBER" = "CONTRACT_NUMBER"
    )
  ) |>
  mutate(GEOGRAPHY_TYPE = "LOCAL_AUTHORITY",
         GEOGRAPHY_ODS_CODE = "N/A") |>
  select(PSEEN_END_DATE,
         GEOGRAPHY_TYPE,
         GEOGRAPHY_ODS_CODE,
         GEOGRAPHY_ONS_CODE = LAD_CODE,
         GEOGRAPHY_NAME = LAD_NAME,
         PATIENT_TYPE,
         AGE_BAND,
         PATIENT_COUNT_N,
         FINANCIAL_YEAR
  )  |>
  group_by(
    across(-PATIENT_COUNT_N)
  ) |>
  summarise(
    PATIENTS_SEEN = sum(PATIENT_COUNT_N, na.rm = T),
    .groups = "drop"
  ) |>
  collect() |>
  mutate(
    PSEEN_END_DATE = as.Date(PSEEN_END_DATE)
  ) |>
  left_join(
    LA_pop,
    by = c(
      "FINANCIAL_YEAR" = "FINANCIAL_YEAR",
      "GEOGRAPHY_ONS_CODE" = "LA_CODE",
      "AGE_BAND" = "AGE_BAND"
    )
  ) |>
  arrange(
    GEOGRAPHY_NAME,
    AGE_BAND,
    PSEEN_END_DATE 
  ) |>
  mutate(
    POPULATION = zoo::na.locf(POPULATION)
  ) 

# Combine all data into one -----------------------------------------------
pat_seen_data_combined <- pat_seen_data_region_adult |>
  bind_rows(pat_seen_data_region_child) |>
  bind_rows(pat_seen_data_icb_adult) |>
  bind_rows(pat_seen_data_icb_child) |>
  bind_rows(pat_seen_data_la_adult) |>
  bind_rows(pat_seen_data_la_child) |>
  arrange(PSEEN_END_DATE,
          GEOGRAPHY_ONS_CODE,
          GEOGRAPHY_ODS_CODE,
          GEOGRAPHY_TYPE,
          as.numeric(sub("^([0-9]+).*", "\\1", AGE_BAND)))

#apply sdc redaction using sdc function
pat_seen_data_combined_sdc <- pat_seen_data_combined |>
  apply_sdc(suppress_column = "PATIENTS_SEEN")

#when comparing totals for QR, may need to run data without SDC applied
#use the unredacted data for testing, then apply SDC and write to .csv outputs

#get list of financial years
unique_years <- unique(pat_seen_data_combined_sdc$FINANCIAL_YEAR)

#loop through financial years to filter data and save as .csv
#may need to adjust file names to clarify they are SDC version
#if any non-SDC versions also produced for testing
for(i in unique_years) {
  print(i)
  year_data <- pat_seen_data_combined_sdc |>
    filter(FINANCIAL_YEAR == i) |>
    select(-FINANCIAL_YEAR) |>
    mutate(
      UID = row_number()
    ) |>
    select(UID, everything())
  
  fwrite(year_data, 
         paste0("Y:\\Official Stats\\Dental\\2024_25\\csvs\\CSV outputs\\Geo Patients Seen (contract) csvs SDC\\geo_dental_pat_seen_cont",
                substr(i, 1, 4),
                "_",
                substr(i, 8, 9),
                ".csv"))
}

setwd("Y:\\Official Stats\\Dental\\2024_25\\csvs\\CSV outputs\\Geo Patients Seen (contract) csvs SDC")

#get all geo data .csv files path name
den_act_csv_files <- list.files(pattern = "^geo_dental_pat_seen_cont.*\\.csv$",
                                full.names = TRUE)

#save geo data to .zip
zip("geo_dental_pat_seen_cont_201920_202526.zip",
    files = c(den_act_csv_files))