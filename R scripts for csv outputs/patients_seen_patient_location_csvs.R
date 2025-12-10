#Script to create patient location dental activity data for 2019/20 to 2025/26
#statistical disclosure control applied to suppress patient totals of fewer than 5
#write to CSV output files, then put these into a ZIP file

#Extract data from 24 month patient lists (for adults) in warehouse
#and 12 month patient lists (for children) in warehouse
#by Region, Integrated Care Board (ICB), Local Authority District (LAD), and Ward levels

#data for 2025/26 will only be a partial year, to 30/6/2025

#years for new run of data -----------------------------------------------------

#only run if not values already set in environment
# first_year <- "2019/2020"
# last_year  <- "2025/2026"

# first_patients_seen_date <-
#   as.Date(paste(substr(first_year, 1, 4), "09", "30", sep = "-")) ## Sept 30th
# last_patients_seen_date  <-
#   as.Date(paste(substr(last_year, 6, 9),  "07", "01", sep = "-")) ## July 1st

relevant_year_months <- format(seq(first_patients_seen_date, last_patients_seen_date, by = "month"), "%Y%m") #length 75

#get lookups -------------------------------------------------------------------

#get National Statistic Postcode Lookup (NSPL) from OST schema -----------------
NSPL_pat_loc <-  dplyr::tbl(con,
                            from = dbplyr::in_schema("OST", "ONS_NSPL_AUG_24_11CEN")) |>
  filter(CTRY == "E92000001") |>  #ENGLAND
  select(PCDS,
         NHSER,
         ICB,
         ICB23CDH,
         ICB23NM,
         LAUA,
         WARD) |>
  mutate(PCDS = sql("UPPER(REPLACE(PCDS, ' ', ''))"))  #remove spaces in postcodes and make upper case to make joins easier


ward_lookup <- get_ward_lookup() %>% 
  select(-WD23NMW)


#get population data -----------------------------------------------------------

# NSPL has 2021 NHSER codes, but we need to translate to 2022
region21_link = "https://hub.arcgis.com/api/v3/datasets/56b4b6f7685c42dbac7bd544d5fcba0e_0/downloads/data?format=csv&spatialRefId=3857&where=1%3D1"
regions_21 <- readr::read_csv(region21_link, show_col_types = FALSE)
regions_22 <- readr::read_csv("Y:\\Official Stats\\Dental\\2024_25\\csvs\\nhser_names_codes_22.csv", show_col_types = FALSE)

# make 21 to 22 dictionary
regions_21_22 <- regions_21 |>
  left_join(regions_22, by = join_by("NHSER21CDH" == "NHSER22CDH",
                                     "NHSER21NM" == "NHSER22NM")) |>
  rename(NHSER_NM = NHSER21NM)

# populations (here NHSER codes are 2022)
nhs_region_pop_by_age<- get_ICB_SICBL_NHSER_pop_age(link = "https://www.ons.gov.uk/file?uri=/peoplepopulationandcommunity/populationandmigration/populationestimates/datasets/clinicalcommissioninggroupmidyearpopulationestimates/mid2011tomid2022integratedcareboards2023geography/sapeicb202320112022.xlsx",
                                                    "NHSER")

# Using most recent available data to populate years without estimates
nhs_region_pop_by_age_2324 <- nhs_region_pop_by_age |>
  dplyr::filter(FINANCIAL_YEAR == max(FINANCIAL_YEAR)) |>
  dplyr::mutate(FINANCIAL_YEAR = '2023/2024',
                CALENDAR_YEAR = '2022')

nhs_region_pop_by_age_2425 <- nhs_region_pop_by_age |>
  dplyr::filter(FINANCIAL_YEAR == max(FINANCIAL_YEAR)) |>
  dplyr::mutate(FINANCIAL_YEAR = '2024/2025',
                CALENDAR_YEAR = '2022')

nhs_region_pop_by_age_2526 <- nhs_region_pop_by_age |>
  dplyr::filter(FINANCIAL_YEAR == max(FINANCIAL_YEAR)) |>
  dplyr::mutate(FINANCIAL_YEAR = '2025/2026',
                CALENDAR_YEAR = '2022')

nhs_region_pop_by_age_fill <- nhs_region_pop_by_age |>
  rbind(nhs_region_pop_by_age_2324, nhs_region_pop_by_age_2425, nhs_region_pop_by_age_2526)

# --- ICB ---

#set sys sleep delay if loop is failing due to frequency of requests
#Sys.sleep(20)

nhs_icb_pop_by_age <- get_ICB_SICBL_NHSER_pop_age(link = "https://www.ons.gov.uk/file?uri=/peoplepopulationandcommunity/populationandmigration/populationestimates/datasets/clinicalcommissioninggroupmidyearpopulationestimates/mid2011tomid2022integratedcareboards2023geography/sapeicb202320112022.xlsx",
                                                  "ICB")

# Using most recent available data to populate years without estimates
nhs_icb_pop_by_age_2324 <- nhs_icb_pop_by_age |>
  dplyr::filter(FINANCIAL_YEAR == max(FINANCIAL_YEAR)) |>
  dplyr::mutate(FINANCIAL_YEAR = '2023/2024',
                CALENDAR_YEAR = '2022')

nhs_icb_pop_by_age_2425 <- nhs_icb_pop_by_age |>
  dplyr::filter(FINANCIAL_YEAR == max(FINANCIAL_YEAR)) |>
  dplyr::mutate(FINANCIAL_YEAR = '2024/2025',
                CALENDAR_YEAR = '2022')

nhs_icb_pop_by_age_2526 <- nhs_icb_pop_by_age |>
  dplyr::filter(FINANCIAL_YEAR == max(FINANCIAL_YEAR)) |>
  dplyr::mutate(FINANCIAL_YEAR = '2025/2026',
                CALENDAR_YEAR = '2022')

nhs_icb_pop_by_age_fill <- nhs_icb_pop_by_age |>
  rbind(nhs_icb_pop_by_age_2324, nhs_icb_pop_by_age_2425, nhs_icb_pop_by_age_2526)


# LOCAL AUTHORITY ---------------------------------------------------------
# The NSPL LA codes are from 2023
la_lookup<- get_la_lookup() 

la_23_lookup <- la_lookup |>
  select(-LAD22CD) |>
  filter(!is.na(LAD23CD))

# --- LA population data ---
la_pop_by_age <- get_la_pop_age() 

# build 24/25 as 25/26 to ensure pop data pulls forwards
la_pop_by_age_2526 <- la_pop_by_age |>
  filter(FINANCIAL_YEAR == "2024/2025") |>
  mutate(FINANCIAL_YEAR = "2025/2026")

la_pop_by_age <- la_pop_by_age |>
  bind_rows(la_pop_by_age_2526)

# --- WARD ---

# --- get ward lookup ---


# --- ward population data  ---
ward_pop_age <-get_ward_pop_age(file_path = "Y:/Official Stats/Dental/2024_25/Data")

# Using most recent available data to populate years without estimates
ward_pop_age_2324 <- ward_pop_age |>
  dplyr::filter(FINANCIAL_YEAR == max(FINANCIAL_YEAR)) |>
  dplyr::mutate(FINANCIAL_YEAR = '2023/2024',
                CALENDAR_YEAR = '2022')

ward_pop_age_2425 <- ward_pop_age |>
  dplyr::filter(FINANCIAL_YEAR == max(FINANCIAL_YEAR)) |>
  dplyr::mutate(FINANCIAL_YEAR = '2024/2025',
                CALENDAR_YEAR = '2022')

ward_pop_age_2526 <- ward_pop_age |>
  dplyr::filter(FINANCIAL_YEAR == max(FINANCIAL_YEAR)) |>
  dplyr::mutate(FINANCIAL_YEAR = '2025/2026',
                CALENDAR_YEAR = '2022')

ward_pop_age_fill <- ward_pop_age |>
  rbind(ward_pop_age_2324, ward_pop_age_2425, ward_pop_age_2526)

# LOOP STARTS ------------------------------------------------------------------
for (i_month in 1:length(relevant_year_months)){
relevant_year_months_current = relevant_year_months[i_month]
print(relevant_year_months_current) #keep track of progress in console

# timing each loop iteration
system.time({
  
# Base tables 
  
# adult base table 
pat_seen_data_geog_adult_base <-
dplyr::tbl(con,
from = dbplyr::in_schema("AML", "DS_PATIENT_LIST_24M")) |>
filter(ONS_COUNTRY == "E92000001",  #ENGLAND
AGE_AT_PERIOD_END > 17,       #ADULTS
YEAR_MONTH %in% relevant_year_months_current
) |>
#head(1000000) |> #remove this line when not testing
select(YEAR_MONTH,
POSTCODE,
AGE_AT_PERIOD_END,
PATIENT_COUNT_N) |>
mutate(
PATIENT_TYPE = "Adult",
AGE_BAND = case_when(
AGE_AT_PERIOD_END > 17 & AGE_AT_PERIOD_END < 65 ~ "18-64",
AGE_AT_PERIOD_END > 64 & AGE_AT_PERIOD_END < 75 ~ "65-74",
AGE_AT_PERIOD_END > 74 & AGE_AT_PERIOD_END < 85 ~ "75-84",
AGE_AT_PERIOD_END > 84 ~ "85+"
),
PSEEN_END_DATE = sql("LAST_DAY(TO_DATE(YEAR_MONTH, 'YYYYMM'))"),
FINANCIAL_YEAR = sql("TO_CHAR(ADD_MONTHS(LAST_DAY(TO_DATE(YEAR_MONTH, 'YYYYMM')), -3), 'YYYY') || '/' || TO_CHAR(ADD_MONTHS(TO_DATE(YEAR_MONTH, 'YYYYMM'), 9), 'YYYY')")
) |>
select(
FINANCIAL_YEAR,
PSEEN_END_DATE,
POSTCODE,
PATIENT_COUNT_N,
PATIENT_TYPE,
AGE_BAND
) |>
group_by(
across(-PATIENT_COUNT_N)
) |>
summarise(
PATIENTS_SEEN = sum(PATIENT_COUNT_N, na.rm = T),
.groups = "drop"
) |>
mutate(POSTCODE = sql("UPPER(REPLACE(POSTCODE, ' ', ''))") )
#child base table
pat_seen_data_geog_child_base <-
dplyr::tbl(con,
from = dbplyr::in_schema("AML", "DS_PATIENT_LIST_12M")) |>
filter(ONS_COUNTRY == "E92000001",  #ENGLAND
AGE_AT_PERIOD_END <= 17,       #CHILDREN
YEAR_MONTH %in% relevant_year_months_current
) |>
#head(1000000) |> #remove this line when not testing
select(YEAR_MONTH,
POSTCODE,
AGE_AT_PERIOD_END,
PATIENT_COUNT_N) |>
mutate(
PATIENT_TYPE = "Child",
AGE_BAND = as.character(AGE_AT_PERIOD_END),
PSEEN_END_DATE = sql("LAST_DAY(TO_DATE(YEAR_MONTH, 'YYYYMM'))"),
FINANCIAL_YEAR = sql("TO_CHAR(ADD_MONTHS(LAST_DAY(TO_DATE(YEAR_MONTH, 'YYYYMM')), -3), 'YYYY') || '/' || TO_CHAR(ADD_MONTHS(TO_DATE(YEAR_MONTH, 'YYYYMM'), 9), 'YYYY')")
) |>
select(
FINANCIAL_YEAR,
PSEEN_END_DATE,
POSTCODE,
PATIENT_COUNT_N,
PATIENT_TYPE,
AGE_BAND
) |>
group_by(
across(-PATIENT_COUNT_N)
) |>
summarise(
PATIENTS_SEEN = sum(PATIENT_COUNT_N, na.rm = T),
.groups = "drop"
) |>
mutate(POSTCODE = sql("UPPER(REPLACE(POSTCODE, ' ', ''))") )
#combine base table
pat_seen_data_geog_base <- pat_seen_data_geog_adult_base |>
union_all(pat_seen_data_geog_child_base)
#join in locations data
pat_seen_data_geog <- pat_seen_data_geog_base |>
left_join(NSPL_pat_loc,
by = c("POSTCODE" = "PCDS") )
# Region
#aggregate data by region
pat_seen_data_region <- pat_seen_data_geog |>
select(FINANCIAL_YEAR,
PSEEN_END_DATE,
PATIENT_TYPE,
AGE_BAND,
PATIENTS_SEEN,
NHSER) |>  # NHSER codes are 2021 versions here
group_by(
across(-PATIENTS_SEEN)
) |>
summarise(
PATIENTS_SEEN = sum(PATIENTS_SEEN, na.rm = T),
.groups = "drop"
) |>
collect()|>
#Join with region codes
dplyr::left_join(regions_21_22, by = join_by("NHSER" == "NHSER21CD")) |>
rename(GEOGRAPHY_ONS_CODE = NHSER22CD,
GEOGRAPHY_ODS_CODE = NHSER21CDH,
GEOGRAPHY_NAME = NHSER_NM) |>
#Add in population data
dplyr::left_join(nhs_region_pop_by_age_fill,
by = c("GEOGRAPHY_ONS_CODE" = "NHSER_CODE",
"AGE_BAND" = "AGE_BAND",
"FINANCIAL_YEAR" = "FINANCIAL_YEAR")) |>
mutate(GEOGRAPHY_TYPE = "REGION") |>
select(
PSEEN_END_DATE,
GEOGRAPHY_TYPE,
GEOGRAPHY_ODS_CODE,
GEOGRAPHY_ONS_CODE,
GEOGRAPHY_NAME,
PATIENT_TYPE,
AGE_BAND,
PATIENTS_SEEN,
POPULATION
) |>
arrange(PSEEN_END_DATE,
GEOGRAPHY_TYPE,
GEOGRAPHY_ODS_CODE,
GEOGRAPHY_ONS_CODE,
GEOGRAPHY_NAME,
GEOGRAPHY_ONS_CODE,
factor(PATIENT_TYPE, levels = c('CHILD','ADULT')),
factor(AGE_BAND, levels = c('0','1', '2', '3',
'4', '5', '6', '7',
'8', '9', '10', '11',
'12', '13', '14', '15',
'16', '17', '18-64', '65-74',
'75-84', '85+')),
PATIENTS_SEEN,
POPULATION)
#ICB
# aggregate data by ICB
pat_seen_data_ICB <- pat_seen_data_geog %>%
select(FINANCIAL_YEAR,
PSEEN_END_DATE,
PATIENT_TYPE,
AGE_BAND,
PATIENTS_SEEN,
ICB,
ICB23CDH,
ICB23NM) |>
group_by(
across(-PATIENTS_SEEN)
) |>
summarise(
PATIENTS_SEEN = sum(PATIENTS_SEEN, na.rm = T),
.groups = "drop"
) |>
collect()|>
rename(GEOGRAPHY_ONS_CODE = ICB,
GEOGRAPHY_ODS_CODE = ICB23CDH,
GEOGRAPHY_NAME = ICB23NM)|>
#Add in population data
dplyr::left_join(nhs_icb_pop_by_age_fill,
by = c("GEOGRAPHY_ONS_CODE" = "ICB_CODE",
"AGE_BAND" = "AGE_BAND",
"FINANCIAL_YEAR" = "FINANCIAL_YEAR")) |>
mutate(GEOGRAPHY_TYPE = "ICB") |>
select(
PSEEN_END_DATE,
GEOGRAPHY_TYPE,
GEOGRAPHY_ODS_CODE,
GEOGRAPHY_ONS_CODE,
GEOGRAPHY_NAME,
PATIENT_TYPE,
AGE_BAND,
PATIENTS_SEEN,
POPULATION
) |>
arrange(PSEEN_END_DATE,
GEOGRAPHY_TYPE,
GEOGRAPHY_ODS_CODE,
GEOGRAPHY_ONS_CODE,
GEOGRAPHY_NAME,
GEOGRAPHY_ONS_CODE,
factor(PATIENT_TYPE, levels = c('CHILD','ADULT')),
factor(AGE_BAND, levels = c('0','1', '2', '3',
'4', '5', '6', '7',
'8', '9', '10', '11',
'12', '13', '14', '15',
'16', '17', '18-64', '65-74',
'75-84', '85+')),
PATIENTS_SEEN,
POPULATION)
# Local Authority
#aggregate data by LA
pat_seen_data_LA <- pat_seen_data_geog |>
select(FINANCIAL_YEAR,
PSEEN_END_DATE,
PATIENT_TYPE,
AGE_BAND,
PATIENTS_SEEN,
LAUA) |>
group_by(
across(-PATIENTS_SEEN)
) |>
summarise(
PATIENTS_SEEN = sum(PATIENTS_SEEN, na.rm = T),
.groups = "drop"
) |>
collect()|>
#Add in LA names
dplyr::left_join(la_23_lookup,
by = c("LAUA" = "LAD23CD") ) |>
rename(GEOGRAPHY_ONS_CODE = LAUA,
GEOGRAPHY_NAME = LAD23NM) |>
#Add in population data
dplyr::left_join(la_pop_by_age,
by = c("GEOGRAPHY_ONS_CODE" = "LA_CODE",
"AGE_BAND" = "AGE_BAND",
"FINANCIAL_YEAR" = "FINANCIAL_YEAR")) |>
mutate(GEOGRAPHY_TYPE = "LOCAL_AUTHORITY",
GEOGRAPHY_ODS_CODE = "N/A") |>
select(
PSEEN_END_DATE,
GEOGRAPHY_TYPE,
GEOGRAPHY_ODS_CODE,
GEOGRAPHY_ONS_CODE,
GEOGRAPHY_NAME,
PATIENT_TYPE,
AGE_BAND,
PATIENTS_SEEN,
POPULATION
) |>
arrange(PSEEN_END_DATE,
GEOGRAPHY_TYPE,
GEOGRAPHY_ODS_CODE,
GEOGRAPHY_ONS_CODE,
GEOGRAPHY_NAME,
GEOGRAPHY_ONS_CODE,
factor(PATIENT_TYPE, levels = c('CHILD','ADULT')),
factor(AGE_BAND, levels = c('0','1', '2', '3',
'4', '5', '6', '7',
'8', '9', '10', '11',
'12', '13', '14', '15',
'16', '17', '18-64', '65-74',
'75-84', '85+')),
PATIENTS_SEEN,
POPULATION)
#Ward
#aggregate data by ward
pat_seen_data_ward <- pat_seen_data_geog |>
select(FINANCIAL_YEAR,
PSEEN_END_DATE,
PATIENT_TYPE,
AGE_BAND,
PATIENTS_SEEN,
WARD) |>
group_by(
across(-PATIENTS_SEEN)
) |>
summarise(
PATIENTS_SEEN = sum(PATIENTS_SEEN, na.rm = T),
.groups = "drop"
) |>
collect()|>
#Add in WARD names
dplyr::left_join(ward_lookup,
by = c("WARD" = "WD23CD") ) |>
rename(GEOGRAPHY_ONS_CODE = WARD,
GEOGRAPHY_NAME = WD23NM) |>
#Add in population data
dplyr::left_join(ward_pop_age_fill,
by = c("GEOGRAPHY_ONS_CODE" = "WARD_CODE",
"AGE_BAND" = "AGE_BAND",
"FINANCIAL_YEAR" = "FINANCIAL_YEAR")) |>
mutate(GEOGRAPHY_TYPE = "WARD",
GEOGRAPHY_ODS_CODE = "N/A") |>
select(
PSEEN_END_DATE,
GEOGRAPHY_TYPE,
GEOGRAPHY_ODS_CODE,
GEOGRAPHY_ONS_CODE,
GEOGRAPHY_NAME,
PATIENT_TYPE,
AGE_BAND,
PATIENTS_SEEN,
POPULATION
) |>
arrange(PSEEN_END_DATE,
GEOGRAPHY_TYPE,
GEOGRAPHY_ODS_CODE,
GEOGRAPHY_ONS_CODE,
GEOGRAPHY_NAME,
GEOGRAPHY_ONS_CODE,
factor(PATIENT_TYPE, levels = c('CHILD','ADULT')),
factor(AGE_BAND, levels = c('0','1', '2', '3',
'4', '5', '6', '7',
'8', '9', '10', '11',
'12', '13', '14', '15',
'16', '17', '18-64', '65-74',
'75-84', '85+')),
PATIENTS_SEEN,
POPULATION)
#bind region, ICB, local authority, and ward data together
pat_seen_data_all <- bind_rows( pat_seen_data_region,
pat_seen_data_ICB,
pat_seen_data_LA,
pat_seen_data_ward)
write.csv(pat_seen_data_all, paste0("Y:/Official Stats/Dental/2024_25/csvs/CSV outputs/patients_seen_pat_loc_geog_monthly_tables/pat_seen_pat_loc_", relevant_year_months_current,".csv"), row.names = FALSE)
})
}

#bind monthly files into years -------------------------------------------------

path <- "Y:\\Official Stats\\Dental\\2024_25\\csvs\\CSV outputs\\patients_seen_pat_loc_geog_monthly_tables"

files <- list.files(path = path, pattern = "\\.csv$", full.names = TRUE)

data <- files |>
  lapply(read_csv) |>
  bind_rows() |>
  mutate(
    FINANCIAL_YEAR = case_when(
      PSEEN_END_DATE > as.Date("2019-03-31") & PSEEN_END_DATE < as.Date("2020-04-01") ~ "2019/2020",
      PSEEN_END_DATE > as.Date("2020-03-31") & PSEEN_END_DATE < as.Date("2021-04-01") ~ "2020/2021",
      PSEEN_END_DATE > as.Date("2021-03-31") & PSEEN_END_DATE < as.Date("2022-04-01") ~ "2021/2022",
      PSEEN_END_DATE > as.Date("2022-03-31") & PSEEN_END_DATE < as.Date("2023-04-01") ~ "2022/2023",
      PSEEN_END_DATE > as.Date("2023-03-31") & PSEEN_END_DATE < as.Date("2024-04-01") ~ "2023/2024",
      PSEEN_END_DATE > as.Date("2024-03-31") & PSEEN_END_DATE < as.Date("2025-04-01") ~ "2024/2025",
      PSEEN_END_DATE > as.Date("2025-03-31") & PSEEN_END_DATE < as.Date("2026-04-01") ~ "2025/2026"
    ))

#get list of financial years
unique_years <- unique(data$FINANCIAL_YEAR)

#loop through financial years to filter data and save as .csv
for(i in unique_years) {
  print(i)
  year_data <- data |>
    filter(FINANCIAL_YEAR == i) |>
    select(-FINANCIAL_YEAR) |>
    mutate(
      UID = row_number()
    ) |>
    select(UID, everything())
  fwrite(year_data,
         paste0("Y:\\Official Stats\\Dental\\2024_25\\csvs\\CSV outputs\\Geo Patients Seen (patient) csvs\\geo_dental_patients_seen_patient_location_",
                substr(i, 1, 4),
                "_",
                substr(i, 8, 9),
                ".csv"))
}

setwd("Y:\\Official Stats\\Dental\\2024_25\\csvs\\CSV outputs\\Geo Patients Seen (patient) csvs")
#get all geo data .csv files path name
csv_files <- list.files(pattern = "^geo_dental_patients_seen_patient_location.*\\.csv$",
                        full.names = TRUE)
#save geo data to .zip
zip("geo_dental_patients_seen_patient_location_201920_202526.zip",
    files = c(csv_files))
