#Read in fact table data

# DS_WORKFORCE_FACT_2425 draft version of table
# built from contract details mapped to latest month in contract dim
# workforce_fact <- dplyr::tbl(con,
#                              from = dbplyr::in_schema("OST", "DS_WORKFORCE_FACT_2425")) |>
#   collect()

##DS_WORKFORCE_FACT_202503 version of table 
#built from contract details mapped to 202403 for 2019/20 to 2023/24 data
#and mapped to 202503 for 2024/25 data

#keeps historical data the same as published last year and accounts for mapping area codes
#and maps to include 2023 changes to ICB codes/orgs
#but maps the new year of data to contract details at end of 24/25 financial year
workforce_fact <- dplyr::tbl(con,
                             from = dbplyr::in_schema("OST", "DS_WORKFORCE_FACT_202503")) |>
  collect()

#Read in 2023/24 publication fact data, for comparison

workforce_fact_old <- dplyr::tbl(con,
                              from = dbplyr::in_schema("OST", "DS_WORKFORCE_FACT_202403")) |>
  collect()

#import roles data ------------------------------------------------
#using import_roles_data_2425.R script

source(import_roles_data.R)

#import roles data from Y drive ------------------------------------------------
#using import_roles_data.R script
#TO DO: put into R functions and/or source file in pipeline

#initial data exploration ------------------------------------------------------

#how many distinct performer numbers by year (England and Wales)
View(workforce_fact |>
       dplyr::group_by(TREATMENT_YEAR, ONS_COUNTRY) |>
       dplyr::summarise(unique_perf_num = n_distinct(PERFORMER_NUMBER)))

#check how many performers with more than 1 surname across all years
View(workforce_fact |>
       dplyr::group_by(PERFORMER_NUMBER) |>
       dplyr::summarise(unique_perf_surname = n_distinct(SURNAME)) |>
       dplyr::filter(unique_perf_surname > 1))

View(workforce_fact |>
       dplyr::filter(COMMISSIONER_CODE %in% c('Q44', 'Q45', 'Q46', 'Q47', 'Q48', 'Q49',
                                              'Q50', 'Q51', 'Q52', 'Q53', 'Q54', 'Q55',
                                              'Q56', 'Q57', 'Q58', 'Q59', 'Q60', 'Q61',
                                              'Q62', 'Q63', 'Q64', 'Q65', 'Q66', 'Q67',
                                              'Q68', 'Q69', 'Q70')))

View(workforce_fact |>
       dplyr::filter(LTST_COMM_CODE %in% c('Q44', 'Q45', 'Q46', 'Q47', 'Q48', 'Q49',
                                           'Q50', 'Q51', 'Q52', 'Q53', 'Q54', 'Q55',
                                           'Q56', 'Q57', 'Q58', 'Q59', 'Q60', 'Q61',
                                           'Q62', 'Q63', 'Q64', 'Q65', 'Q66', 'Q67',
                                           'Q68', 'Q69', 'Q70')))

#explore against last year's data
workforce_fact_test <- workforce_fact |>
  dplyr::filter(TREATMENT_YEAR != "2024/2025")

#6 performers (10 rows total) where CCG code changed from 05G to 05W
wf_diff <- setdiff(workforce_fact_test, workforce_fact_old)  

#split data into England and Wales ---------------------------------------------
#(total rows added together gives same as workforce_fact
#so no rows with other values or missing data for ONS_COUNTRY column)
wales_wf_fact <- workforce_fact |>
  dplyr::filter(ONS_COUNTRY == "W92000004")

#england split moved into code for ICB name join below
# eng_wf_fact <- workforce_fact |>
#   dplyr::filter(ONS_COUNTRY == "E92000001")

wales_wf_fact_old <- workforce_fact_old |>
   dplyr::filter(ONS_COUNTRY == "W92000004")
eng_wf_fact_old <- workforce_fact_old |>
   dplyr::filter(ONS_COUNTRY == "E92000001")

#area team codes, some commissioners in 2019/20 map to area codes instead
area_team_codes <- c('Q44', 'Q45', 'Q46', 'Q47', 'Q48', 'Q49',
                     'Q50', 'Q51', 'Q52', 'Q53', 'Q54', 'Q55',
                     'Q56', 'Q57', 'Q58', 'Q59', 'Q60', 'Q61',
                     'Q62', 'Q63', 'Q64', 'Q65', 'Q66', 'Q67',
                     'Q68', 'Q69', 'Q70')

#join on ICB names from ONS lookup, as names in ltst_comm_name 
#sometimes not matching commissioner code at time of recording
#2023 codes used for population later, so join on those
icb_lookup_distinct <- nhs_lookups$region_23 |>
  select(ICB23CDH, ICB23CD, ICB23NM) |>
  distinct(ICB23CDH, ICB23CD, ICB23NM)

eng_wf_fact <- workforce_fact |>
  dplyr::filter(ONS_COUNTRY == "E92000001") |>
  dplyr::mutate(LTST_COMM_CODE = case_when(
    COMMISSIONER_CODE %in% area_team_codes ~ LTST_COMM_CODE,
    TRUE ~ COMMISSIONER_CODE
  )) |>
  dplyr::left_join(icb_lookup_distinct, by = c("LTST_COMM_CODE" = "ICB23CDH")) |>
  dplyr::mutate(LTST_COMM_NAME = case_when(LTST_COMM_CODE == 'HJ1' ~ "H&J North East and Yorkshire",
                                           LTST_COMM_CODE == 'HJ2' ~ "H&J North West",
                                           LTST_COMM_CODE == 'HJ3' ~ "H&J Midlands",
                                           LTST_COMM_CODE == 'HJ4' ~ "H&J East of England",
                                           LTST_COMM_CODE == 'HJ5' ~ "H&J London",
                                           LTST_COMM_CODE == 'HJ6' ~ "H&J South East",
                                           LTST_COMM_CODE == 'HJ7' ~ "H&J South West",
                                           TRUE ~ as.character(ICB23NM)))

# dist_act_perf_2324_new <- eng_wf$wf_2324$active_performers$nat_output |>
#   dplyr::distinct(PerformerNumber)
# table_1a_dist_perf_2324 <- readRDS("table1a_dist_perf_2324_t.RDS")
# 
# perf_2324_diff <- setdiff(dist_act_perf_2324_new, table_1a_dist_perf_2324)
# perf_2324_diff_2 <- setdiff(table_1a_dist_perf_2324, dist_act_perf_2324_new)
                          
#all performers where latest commissioner name column was na 
#were for health and justice (H&J) commissioners
#so after H&J case when mutate, no na values found in LTST_COMM_NAME
View(eng_wf_fact |>
       dplyr::filter(is.na(LTST_COMM_NAME)))

#performers where commissioner code is different to latest comm code
#and commissioner code isn't in list of area teams
#are for prison contracts that now map to H&J commissioner codes
#so eng_wf_fact code above was changed to fill in H&J names when H&J code appears
View(eng_wf_fact |>
       dplyr::filter(!(COMMISSIONER_CODE == LTST_COMM_CODE)) |>
       filter(!(COMMISSIONER_CODE %in% area_team_codes)))

#define welsh lhbs vector for use in finding
#performers with an english contract who have a PPC address in Wales
welsh_lhbs <- c('7A1', '7A2', '7A3', '7A4', '7A5', '7A6', '7A7')

#check if any english contracts where commissioner code in the 7 welsh LHB codes
#(none found)
View(eng_wf_fact |>
       dplyr::filter(COMMISSIONER_CODE %in% welsh_lhbs))
#check where CCG codes are in welsh LHBs
View(eng_wf_fact |>
       dplyr::filter(CCG_CODE %in% welsh_lhbs))

# view(eng_wf_fact |>
#        dplyr::filter(COMMISSIONER_CODE != CCG_CODE))

#some performers with NA in CCG_CODE column, but valid PPC address
#can't manually assign CCG_CODE based on postcode, as postcodes not valid
#this affects 52 rows, 45 distinct performers with activity
#from 6 distinct ppc address postcodes

View(eng_wf_fact |>
       dplyr::filter(is.na(CCG_CODE)) |>
       dplyr::filter(UDA > 0 | UOA > 0) |>
       distinct(PERFORMER_NUMBER))

#english workforce data ----------------------------------------------------------

#all rows by treatment year 
#filtered to only rows with activity in year 
#so in english data there were  rows across all years where UDA and UOA was 0.

#split data by treatment year and filter to rows with activity in the given year
eng_wf_raw <- wf_year_split(eng_wf_fact)

#2019/20 has a much higher number of rows than other years, check

#create list of active performers in England for each treatment year
#calculates performer age group, contract type, dentist type

#remove DCPs and split out later 

eng_wf <- list()

eng_wf$wf_1920$active_performers <- get_eng_wf(eng_roles_distinct$roles_1920_1yr,
                                               eng_roles_distinct$roles_1920_3yr,
                                               eng_wf_raw$wf_1920)
eng_wf$wf_2021$active_performers <- get_eng_wf(eng_roles_distinct$roles_2021_1yr,
                                               eng_roles_distinct$roles_2021_3yr,
                                               eng_wf_raw$wf_2021)
eng_wf$wf_2122$active_performers <- get_eng_wf(eng_roles_distinct$roles_2122_1yr,
                                               eng_roles_distinct$roles_2122_3yr,
                                               eng_wf_raw$wf_2122)
eng_wf$wf_2223$active_performers <- get_eng_wf(eng_roles_distinct$roles_2223_1yr,
                                               eng_roles_distinct$roles_2223_3yr,
                                               eng_wf_raw$wf_2223)
eng_wf$wf_2223$active_performers$nat_output <- eng_wf[["wf_2223"]][["active_performers"]][["nat_output"]] |>
  dplyr::filter(!(DentistType == "Dental Care Professional"))
eng_wf$wf_2223$active_performers$ICB_output <- eng_wf[["wf_2223"]][["active_performers"]][["ICB_output"]] |>
  dplyr::filter(!(DentistType == "Dental Care Professional"))

eng_wf$wf_2324$active_performers <- get_eng_wf(eng_roles_distinct$roles_2324_1yr,
                                               eng_roles_distinct$roles_2324_3yr,
                                               eng_wf_raw$wf_2324)
eng_wf$wf_2324$active_performers$nat_output <- eng_wf[["wf_2324"]][["active_performers"]][["nat_output"]] |>
  dplyr::filter(!(DentistType == "Dental Care Professional"))
eng_wf$wf_2324$active_performers$ICB_output <- eng_wf[["wf_2324"]][["active_performers"]][["ICB_output"]] |>
  dplyr::filter(!(DentistType == "Dental Care Professional"))

#change 3yr roles file to one including 2024/25, if available
eng_wf$wf_2425$active_performers <- get_eng_wf(eng_roles_distinct$roles_2425_1yr,
                                               comb_1yr_files,
                                               eng_wf_raw$wf_2425) 
eng_wf$wf_2425$active_performers$nat_output <- eng_wf[["wf_2425"]][["active_performers"]][["nat_output"]] |>
  dplyr::filter(!(DentistType == "Dental Care Professional"))
eng_wf$wf_2425$active_performers$ICB_output <- eng_wf[["wf_2425"]][["active_performers"]][["ICB_output"]] |>
  dplyr::filter(!(DentistType == "Dental Care Professional"))


#get national level joiners and leavers for each year 

eng_wf$wf_2021$nat_joiners_leavers <- get_nat_joiners_leavers(eng_wf$wf_1920$active_performers$nat_output,
                                                              eng_wf$wf_2021$active_performers$nat_output,
                                                              "01/04/2020",
                                                              "01/04/2019")
eng_wf$wf_2122$nat_joiners_leavers <- get_nat_joiners_leavers(eng_wf$wf_2021$active_performers$nat_output,
                                                              eng_wf$wf_2122$active_performers$nat_output,
                                                              "01/04/2021",
                                                              "01/04/2020")
eng_wf$wf_2223$nat_joiners_leavers <- get_nat_joiners_leavers(eng_wf$wf_2122$active_performers$nat_output,
                                                              eng_wf$wf_2223$active_performers$nat_output,
                                                              "01/04/2022",
                                                              "01/04/2021")
eng_wf$wf_2324$nat_joiners_leavers <- get_nat_joiners_leavers(eng_wf$wf_2223$active_performers$nat_output,
                                                              eng_wf$wf_2324$active_performers$nat_output,
                                                              "01/04/2023",
                                                              "01/04/2022")
eng_wf$wf_2425$nat_joiners_leavers <- get_nat_joiners_leavers(eng_wf$wf_2324$active_performers$nat_output,
                                                              eng_wf$wf_2425$active_performers$nat_output,
                                                              "01/04/2024",
                                                              "01/04/2023")

# view(eng_wf$wf_2223$active_performers$nat_output |>
#        distinct(PerformerNumber))
# view(eng_wf$wf_1920$active_performers$nat_output |>
#        dplyr::filter(!(DentistType %in% c("PO", "PP", "Foundation Dentist"))))

#get ICB level joiners and leavers for each year

eng_wf$wf_2021$icb_joiners_leavers <- get_icb_joiners_leavers(eng_wf$wf_1920$active_performers$ICB_output,
                                                              eng_wf$wf_2021$active_performers$ICB_output,
                                                              "01/04/2020",
                                                              "01/04/2019")
eng_wf$wf_2122$icb_joiners_leavers <- get_icb_joiners_leavers(eng_wf$wf_2021$active_performers$ICB_output,
                                                              eng_wf$wf_2122$active_performers$ICB_output,
                                                              "01/04/2021",
                                                              "01/04/2020")
eng_wf$wf_2223$icb_joiners_leavers <- get_icb_joiners_leavers(eng_wf$wf_2122$active_performers$ICB_output,
                                                              eng_wf$wf_2223$active_performers$ICB_output,
                                                              "01/04/2022",
                                                              "01/04/2021")
eng_wf$wf_2324$icb_joiners_leavers <- get_icb_joiners_leavers(eng_wf$wf_2223$active_performers$ICB_output,
                                                              eng_wf$wf_2324$active_performers$ICB_output,
                                                              "01/04/2023",
                                                              "01/04/2022")
eng_wf$wf_2425$icb_joiners_leavers <- get_icb_joiners_leavers(eng_wf$wf_2324$active_performers$ICB_output,
                                                              eng_wf$wf_2425$active_performers$ICB_output,
                                                              "01/04/2024",
                                                              "01/04/2023")

#SICBL level data - active performers
#based on CCG code column, so location of performer/primary correspondence address
#NOT location of commissioner

eng_wf$wf_1920$sicbl_performers <- get_eng_wf_sicbl(eng_roles_distinct$roles_1920_1yr,
                                                    eng_roles_distinct$roles_1920_3yr,
                                                    eng_wf_raw$wf_1920)
eng_wf$wf_2021$sicbl_performers <- get_eng_wf_sicbl(eng_roles_distinct$roles_2021_1yr,
                                                    eng_roles_distinct$roles_2021_3yr,
                                                    eng_wf_raw$wf_2021)
eng_wf$wf_2122$sicbl_performers <- get_eng_wf_sicbl(eng_roles_distinct$roles_2122_1yr,
                                                    eng_roles_distinct$roles_2122_3yr,
                                                    eng_wf_raw$wf_2122)
eng_wf$wf_2122$sicbl_performers$nat_output <- eng_wf[["wf_2122"]][["sicbl_performers"]][["nat_output"]] |>
  dplyr::filter(!(DentistType == "Dental Care Professional"))
eng_wf$wf_2122$sicbl_performers$SICBL_output <- eng_wf[["wf_2122"]][["sicbl_performers"]][["SICBL_output"]] |>
  dplyr::filter(!(DentistType == "Dental Care Professional"))

eng_wf$wf_2223$sicbl_performers <- get_eng_wf_sicbl(eng_roles_distinct$roles_2223_1yr,
                                                    eng_roles_distinct$roles_2223_3yr,
                                                    eng_wf_raw$wf_2223)
eng_wf$wf_2223$sicbl_performers$nat_output <- eng_wf[["wf_2223"]][["sicbl_performers"]][["nat_output"]] |>
  dplyr::filter(!(DentistType == "Dental Care Professional"))
eng_wf$wf_2223$sicbl_performers$SICBL_output <- eng_wf[["wf_2223"]][["sicbl_performers"]][["SICBL_output"]] |>
  dplyr::filter(!(DentistType == "Dental Care Professional"))

eng_wf$wf_2324$sicbl_performers <- get_eng_wf_sicbl(eng_roles_distinct$roles_2324_1yr,
                                                    eng_roles_distinct$roles_2324_3yr,
                                                    eng_wf_raw$wf_2324)
eng_wf$wf_2324$sicbl_performers$nat_output <- eng_wf[["wf_2324"]][["sicbl_performers"]][["nat_output"]] |>
  dplyr::filter(!(DentistType == "Dental Care Professional"))
eng_wf$wf_2324$sicbl_performers$SICBL_output <- eng_wf[["wf_2324"]][["sicbl_performers"]][["SICBL_output"]] |>
  dplyr::filter(!(DentistType == "Dental Care Professional"))

#update 3yr roles file for 2024/25 if available 
eng_wf$wf_2425$sicbl_performers <- get_eng_wf_sicbl(eng_roles_distinct$roles_2425_1yr,
                                                    comb_1yr_files,
                                                    eng_wf_raw$wf_2425)
eng_wf$wf_2425$sicbl_performers$nat_output <- eng_wf[["wf_2425"]][["sicbl_performers"]][["nat_output"]] |>
  dplyr::filter(!(DentistType == "Dental Care Professional"))
eng_wf$wf_2425$sicbl_performers$SICBL_output <- eng_wf[["wf_2425"]][["sicbl_performers"]][["SICBL_output"]] |>
  dplyr::filter(!(DentistType == "Dental Care Professional"))

#get SICBL level joiners and leavers for each year

eng_wf$wf_2021$sicbl_joiners_leavers <- get_sicbl_joiners_leavers(eng_wf$wf_1920$sicbl_performers$SICBL_output,
                                                                  eng_wf$wf_2021$sicbl_performers$SICBL_output,
                                                                  "01/04/2020",
                                                                  "01/04/2019")
eng_wf$wf_2122$sicbl_joiners_leavers <- get_sicbl_joiners_leavers(eng_wf$wf_2021$sicbl_performers$SICBL_output,
                                                                  eng_wf$wf_2122$sicbl_performers$SICBL_output,
                                                                  "01/04/2021",
                                                                  "01/04/2020")
eng_wf$wf_2223$sicbl_joiners_leavers <- get_sicbl_joiners_leavers(eng_wf$wf_2122$sicbl_performers$SICBL_output,
                                                                  eng_wf$wf_2223$sicbl_performers$SICBL_output,
                                                                  "01/04/2022",
                                                                  "01/04/2021")
eng_wf$wf_2324$sicbl_joiners_leavers <- get_sicbl_joiners_leavers(eng_wf$wf_2223$sicbl_performers$SICBL_output,
                                                                  eng_wf$wf_2324$sicbl_performers$SICBL_output,
                                                                  "01/04/2023",
                                                                  "01/04/2022")
eng_wf$wf_2425$sicbl_joiners_leavers <- get_sicbl_joiners_leavers(eng_wf$wf_2324$sicbl_performers$SICBL_output,
                                                                  eng_wf$wf_2425$sicbl_performers$SICBL_output,
                                                                  "01/04/2024",
                                                                  "01/04/2023")

### Excel table aggregations

#Table 1a: Number of dentists with NHS activity by financial year

nat_wf_1920 <- eng_wf$wf_1920$active_performers$nat_output |>
  dplyr::group_by(`Year`) |>
  dplyr::summarise(Dentists = n_distinct(PerformerNumber)) |>
  ungroup() |>
  dplyr::mutate(Joiners = NA) |>
  dplyr::mutate(Leavers = NA)

nat_wf_2021 <- get_table_1a(eng_wf$wf_2021,
                            fin_year = "2020/2021")
nat_wf_2122 <- get_table_1a(eng_wf$wf_2122,
                            fin_year = "2021/2022")
nat_wf_2223 <- get_table_1a(eng_wf$wf_2223,
                            fin_year = "2022/2023")
nat_wf_2324 <- get_table_1a(eng_wf$wf_2324,
                            fin_year = "2023/2024")
nat_wf_2425 <- get_table_1a(eng_wf$wf_2425,
                            fin_year = "2024/2025")


table_1a_wf <- rbind(nat_wf_1920,
                     nat_wf_2021,
                     nat_wf_2122,
                     nat_wf_2223,
                     nat_wf_2324,
                     nat_wf_2425) |>
  dplyr::select(`Financial year` = Year,
                Dentists,
                Joiners,
                Leavers)

#Table 1b: Number and percentage of dentists with NHS activity by contract type and dentist type, England

type_wf_1920 <- get_table_1b(eng_wf$wf_1920,
                             fin_year = "2019/2020")
type_wf_2021 <- get_table_1b(eng_wf$wf_2021,
                             fin_year = "2020/2021")
type_wf_2122 <- get_table_1b(eng_wf$wf_2122,
                             fin_year = "2021/2022")
type_wf_2223 <- get_table_1b(eng_wf$wf_2223,
                             fin_year = "2022/2023")
type_wf_2324 <- get_table_1b(eng_wf$wf_2324,
                             fin_year = "2023/2024")
type_wf_2425 <- get_table_1b(eng_wf$wf_2425,
                             fin_year = "2024/2025")

table_1b_wf <- rbind(type_wf_1920,
                  type_wf_2021,
                  type_wf_2122,
                  type_wf_2223,
                  type_wf_2324,
                  type_wf_2425) |>
  dplyr::group_by(Year) |>
  #add year totals to calculate percentages from
  dplyr::mutate(`Year total` = case_when(Year == "2019/2020" ~ 24676,
                                      Year == "2020/2021" ~ 23733,
                                      Year == "2021/2022" ~ 24265,
                                      Year == "2022/2023" ~ 24151,
                                      Year == "2023/2024" ~ 24193,
                                      Year == "2024/2025" ~ 24543),
                `Percentage of dentists` = ((Dentists / `Year total`) * 100)) |>
  dplyr::ungroup() |>
  dplyr::select(`Financial year` = Year,
                `Dentist type` = DentistType,
                `Contract type` = ContractType,
                Dentists,
                `Year total`,
                `Percentage of dentists`
                )

#Table 1c: Number of dentists with NHS activity by gender and age group, England

agegen_wf_1920 <- get_table_1c(eng_wf$wf_1920,
                               fin_year = "2019/2020")
agegen_wf_2021 <- get_table_1c(eng_wf$wf_2021,
                               fin_year = "2020/2021")
agegen_wf_2122 <- get_table_1c(eng_wf$wf_2122,
                               fin_year = "2021/2022")
agegen_wf_2223 <- get_table_1c(eng_wf$wf_2223,
                               fin_year = "2022/2023")
agegen_wf_2324 <- get_table_1c(eng_wf$wf_2324,
                               fin_year = "2023/2024")
agegen_wf_2425 <- get_table_1c(eng_wf$wf_2425,
                               fin_year = "2024/2025")

table_1c_wf <- rbind(agegen_wf_1920,
                  agegen_wf_2021,
                  agegen_wf_2122,
                  agegen_wf_2223,
                  agegen_wf_2324,
                  agegen_wf_2425) |>
  dplyr::arrange(Year, match(AgeGroup, c("All", "Under 35", "35-44", "45-54", "55+")), PerformerGender) |>
  dplyr::group_by(Year) |>
  dplyr::mutate(`Year total` = case_when(Year == "2019/2020" ~ 24676,
                                      Year == "2020/2021" ~ 23733,
                                      Year == "2021/2022" ~ 24265,
                                      Year == "2022/2023" ~ 24151,
                                      Year == "2023/2024" ~ 24193,
                                      Year == "2024/2025" ~ 24543),
                `Percentage of dentists` = ((Dentists / `Year total`) * 100)) |>
  dplyr::ungroup() |>
  dplyr::select(`Financial year` = Year,
                `Age group` = AgeGroup,
                `Performer gender` = PerformerGender,
                Dentists,
                `Year total`,
                `Percentage of dentists`)

#Table 2a: Number of dentists with NHS activity, financial year, England

table_2a_wf <- table_1a_wf |>
  dplyr::select(`Financial year`,
                Dentists) |>
  dplyr::left_join(eng_nat_pop, by = c("Financial year" = "FINANCIAL_YEAR")) |>
  dplyr::mutate(`Area name` = "England",
                `Population per dentist` = (POPULATION/Dentists),
                `Dentists per 100,000 population` = (Dentists / (POPULATION / 100000))) |>
  dplyr::select(`Financial year`,
                `ONS code` = CODE,
                `Area name`,
                Dentists,
                `Mid-year population year` = CALENDAR_YEAR,
                Population = POPULATION,
                `Population per dentist`,
                `Dentists per 100,000 population`)

#Table 2b: Number of dentists with NHS activity, financial year, NHS region and ICB

reg_wf_1920 <- get_table_2b_region(eng_wf$wf_1920)
reg_wf_2021 <- get_table_2b_region(eng_wf$wf_2021)
reg_wf_2122 <- get_table_2b_region(eng_wf$wf_2122)
reg_wf_2223 <- get_table_2b_region(eng_wf$wf_2223)
reg_wf_2324 <- get_table_2b_region(eng_wf$wf_2324)
reg_wf_2425 <- get_table_2b_region(eng_wf$wf_2425) |>
  #remove 'unknown' region as this is H&J codes that can't be mapped to region
  #H&J dentists already included in this table elsewhere
  dplyr::filter(`ODS code` != 'Unknown')

icb_wf_1920 <- get_table_2b_icb(eng_wf$wf_1920)
icb_wf_2021 <- get_table_2b_icb(eng_wf$wf_2021)
icb_wf_2122 <- get_table_2b_icb(eng_wf$wf_2122)
icb_wf_2223 <- get_table_2b_icb(eng_wf$wf_2223)
icb_wf_2324 <- get_table_2b_icb(eng_wf$wf_2324)
icb_wf_2425 <- get_table_2b_icb(eng_wf$wf_2425) |>
  #add H&J names back in (lost during population join)
  dplyr::mutate(`Area name` = case_when(`ODS code` == 'HJ1' ~ "H&J North East and Yorkshire",
                             `ODS code` == 'HJ2' ~ "H&J North West",
                             `ODS code` == 'HJ3' ~ "H&J Midlands",
                             `ODS code` == 'HJ4' ~ "H&J East of England",
                             `ODS code` == 'HJ5' ~ "H&J London",
                             `ODS code` == 'HJ6' ~ "H&J South East",
                             `ODS code` == 'HJ7' ~ "H&J South West",
                             TRUE ~ as.character(`Area name`)))
  

table_2b_wf <- rbind(reg_wf_1920,
                  icb_wf_1920,
                  reg_wf_2021,
                  icb_wf_2021,
                  reg_wf_2122,
                  icb_wf_2122,
                  reg_wf_2223,
                  icb_wf_2223,
                  reg_wf_2324,
                  icb_wf_2324,
                  reg_wf_2425,
                  icb_wf_2425)

#Table 2c region and ICB joiners and leavers

icb_joiners_leavers_2021 <- get_table_2c_icb(eng_wf$wf_2021,
                                             fin_year = "2020/2021")
icb_joiners_leavers_2122 <- get_table_2c_icb(eng_wf$wf_2122,
                                             fin_year = "2021/2022")
icb_joiners_leavers_2223 <- get_table_2c_icb(eng_wf$wf_2223,
                                             fin_year = "2022/2023")
icb_joiners_leavers_2324 <- get_table_2c_icb(eng_wf$wf_2324,
                                             fin_year = "2023/2024")
icb_joiners_leavers_2425 <- get_table_2c_icb(eng_wf$wf_2425,
                                             fin_year = "2024/2025")

reg_joiners_leavers_2021 <- get_table_2c_region(eng_wf$wf_2021,
                                                fin_year = "2020/2021")
reg_joiners_leavers_2122 <- get_table_2c_region(eng_wf$wf_2122,
                                                fin_year = "2021/2022")
reg_joiners_leavers_2223 <- get_table_2c_region(eng_wf$wf_2223,
                                                fin_year = "2022/2023")
reg_joiners_leavers_2324 <- get_table_2c_region(eng_wf$wf_2324,
                                                fin_year = "2023/2024")
reg_joiners_leavers_2425 <- get_table_2c_region(eng_wf$wf_2425,
                                                fin_year = "2024/2025") |>
  dplyr::filter(`ODS code` != 'Unknown')


table_2c_wf <- rbind(reg_joiners_leavers_2021,
                  icb_joiners_leavers_2021,
                  reg_joiners_leavers_2122,
                  icb_joiners_leavers_2122,
                  reg_joiners_leavers_2223,
                  icb_joiners_leavers_2223,
                  reg_joiners_leavers_2324,
                  icb_joiners_leavers_2324,
                  reg_joiners_leavers_2425,
                  icb_joiners_leavers_2425) 

#Table 2d SICBL performers

sicbl_wf_1920 <- get_table_2d(eng_wf$wf_1920)
sicbl_wf_2021 <- get_table_2d(eng_wf$wf_2021)
sicbl_wf_2122 <- get_table_2d(eng_wf$wf_2122)
sicbl_wf_2223 <- get_table_2d(eng_wf$wf_2223)
sicbl_wf_2324 <- get_table_2d(eng_wf$wf_2324)
sicbl_wf_2425 <- get_table_2d(eng_wf$wf_2425)

table_2d_wf <- rbind(sicbl_wf_1920,
                  sicbl_wf_2021,
                  sicbl_wf_2122,
                  sicbl_wf_2223,
                  sicbl_wf_2324,
                  sicbl_wf_2425) |>
  dplyr::filter(!(`ODS code` %in% welsh_lhbs))

#Table 2e SICBL joiners and leavers

sicbl_joiners_leavers_2021 <- get_table_2e(eng_wf$wf_2021,
                                           fin_year = "2020/2021")
sicbl_joiners_leavers_2122 <- get_table_2e(eng_wf$wf_2122,
                                           fin_year = "2021/2022")
sicbl_joiners_leavers_2223 <- get_table_2e(eng_wf$wf_2223,
                                           fin_year = "2022/2023")
sicbl_joiners_leavers_2324 <- get_table_2e(eng_wf$wf_2324,
                                           fin_year = "2023/2024")
sicbl_joiners_leavers_2425 <- get_table_2e(eng_wf$wf_2425,
                                           fin_year = "2024/2025")

table_2e_wf <- rbind(sicbl_joiners_leavers_2021,
                  sicbl_joiners_leavers_2122,
                  sicbl_joiners_leavers_2223,
                  sicbl_joiners_leavers_2324,
                  sicbl_joiners_leavers_2425) |>
  dplyr::filter(!(`ODS code` %in% welsh_lhbs))

View(eng_wf_fact |>
       dplyr::filter(is.na(CCG_CODE)) |>
       dplyr::filter(UDA > 0 | UOA > 0) |>
       dplyr::filter((TREATMENT_YEAR == "2024/2025")) |>
  distinct(PERFORMER_NUMBER))

#Table 2f - Dental Care Professionals

#check data but DCPs generally only appearing in 2024/25
#if so, limit to 1 year

dcp <- list()

dcp$wf_2425$active_performers <- get_eng_wf(eng_roles_distinct$roles_2425_1yr,
                                                      comb_1yr_files,
                                                      eng_wf_raw$wf_2425) 

dcp_nat_2425 <- dcp[["wf_2425"]][["active_performers"]][["nat_output"]] |>
  dplyr::filter(DentistType == "Dental Care Professional")


dcp_icb_2425 <- dcp[["wf_2425"]][["active_performers"]][["ICB_output"]] |>
  dplyr::filter(DentistType == "Dental Care Professional")

dcp$wf_2324$active_performers <- get_eng_wf(eng_roles_distinct$roles_2324_1yr,
                                               eng_roles_distinct$roles_2324_3yr,
                                               eng_wf_raw$wf_2324)
#can't find DCPs in 2023/24 data
dcp_nat_2324 <- dcp[["wf_2324"]][["active_performers"]][["nat_output"]] |>
  dplyr::filter(DentistType == "Dental Care Professional")

#Table 3 - national DCP by contract
#Need to caveat this is only DCPs who were main performer number associated with the activity 
#(i.e no assists?)
table_3a_wf <- dcp_nat_2425 |>
  dplyr::group_by(Year,
                  DentistType,
                  ContractType) |>
  dplyr::summarise(Dentists = n_distinct(PerformerNumber)) |>
  dplyr::select(`Financial year` = Year,
                `Performer type` = `DentistType`,
                `Contract type` = ContractType,
                `Number of DCPs` = Dentists)

### Workforce csv files 

#Geographical area performers csv

icb_wf_csv_1920 <- get_wf_csv_icb(eng_wf$wf_1920)
icb_wf_csv_2021 <- get_wf_csv_icb(eng_wf$wf_2021)
icb_wf_csv_2122 <- get_wf_csv_icb(eng_wf$wf_2122)
icb_wf_csv_2223 <- get_wf_csv_icb(eng_wf$wf_2223)
icb_wf_csv_2324 <- get_wf_csv_icb(eng_wf$wf_2324)
icb_wf_csv_2425 <- get_wf_csv_icb(eng_wf$wf_2425) |>
  dplyr::mutate(GEOG_NAME = case_when(GEOG_ODS_CODE == 'HJ1' ~ "H&J North East and Yorkshire",
                                      GEOG_ODS_CODE == 'HJ2' ~ "H&J North West",
                                      GEOG_ODS_CODE == 'HJ3' ~ "H&J Midlands",
                                      GEOG_ODS_CODE == 'HJ4' ~ "H&J East of England",
                                      GEOG_ODS_CODE == 'HJ5' ~ "H&J London",
                                      GEOG_ODS_CODE == 'HJ6' ~ "H&J South East",
                                      GEOG_ODS_CODE == 'HJ7' ~ "H&J South West",
                                      TRUE ~ as.character(GEOG_NAME)))

icb_wf_csv_2425_totals <- icb_wf_csv_2425 |>
  dplyr::group_by(GEOG_ODS_CODE) |>
  dplyr::summarise(sum(DENTIST_COUNT))

view(sicbl_wf_csv_1920 |>
       group_by(GEOG_ODS_CODE, GEOG_NAME) |>
       dplyr::summarise(total_dentists = sum(DENTIST_COUNT)))
view(eng_wf$wf_1920$active_performers$ICB_output |>
       dplyr::filter(ICB_Code == "QF7"))

reg_wf_csv_1920 <- get_wf_csv_region(eng_wf$wf_1920)
reg_wf_csv_2021 <- get_wf_csv_region(eng_wf$wf_2021)
reg_wf_csv_2122 <- get_wf_csv_region(eng_wf$wf_2122)
reg_wf_csv_2223 <- get_wf_csv_region(eng_wf$wf_2223)
reg_wf_csv_2324 <- get_wf_csv_region(eng_wf$wf_2324)
#get_wf_csv_region() function removes rows with blank region
#as this is H&J codes that can't be mapped to region
#and H&J dentists already included in this table elsewhere
reg_wf_csv_2425 <- get_wf_csv_region(eng_wf$wf_2425)

#Check dentist totals
# View(reg_wf_csv_2425 |>
#        group_by(GEOG_ODS_CODE, GEOG_NAME) |>
#        dplyr::summarise(total_dentists = sum(DENTIST_COUNT)))

sicbl_wf_csv_1920 <- get_wf_csv_sicbl(eng_wf$wf_1920)
sicbl_wf_csv_2021 <- get_wf_csv_sicbl(eng_wf$wf_2021)
sicbl_wf_csv_2122 <- get_wf_csv_sicbl(eng_wf$wf_2122)
sicbl_wf_csv_2223 <- get_wf_csv_sicbl(eng_wf$wf_2223)
sicbl_wf_csv_2324 <- get_wf_csv_sicbl(eng_wf$wf_2324)
sicbl_wf_csv_2425 <- get_wf_csv_sicbl(eng_wf$wf_2425)

workforce_csv_performers <- rbind(reg_wf_csv_1920,
                                  reg_wf_csv_2021,
                                  reg_wf_csv_2122,
                                  reg_wf_csv_2223,
                                  reg_wf_csv_2324,
                                  reg_wf_csv_2425,
                                  icb_wf_csv_1920,
                                  icb_wf_csv_2021,
                                  icb_wf_csv_2122,
                                  icb_wf_csv_2223,
                                  icb_wf_csv_2324,
                                  icb_wf_csv_2425,
                                  sicbl_wf_csv_1920,
                                  sicbl_wf_csv_2021,
                                  sicbl_wf_csv_2122,
                                  sicbl_wf_csv_2223,
                                  sicbl_wf_csv_2324,
                                  sicbl_wf_csv_2425) |>
  dplyr::arrange(FINANCIAL_YEAR,
                 match(GEOG_TYPE, c("Region", "ICB", "SICBL")),
                 GEOG_ODS_CODE,
                 CONTRACT_TYPE,
                 match(AGE_GROUP, c("Under 35", "35-44", "45-54", "55+")),
                 GENDER,
                 DENTIST_TYPE)

###workforce joiners leavers csv

icb_csv_joiners_leavers_2021 <- get_wf_csv_joiners_leavers_icb(eng_wf$wf_2021,
                                                               fin_year = "2020/2021")
icb_csv_joiners_leavers_2122 <- get_wf_csv_joiners_leavers_icb(eng_wf$wf_2122,
                                                               fin_year = "2021/2022")
icb_csv_joiners_leavers_2223 <- get_wf_csv_joiners_leavers_icb(eng_wf$wf_2223,
                                                               fin_year = "2022/2023")
icb_csv_joiners_leavers_2324 <- get_wf_csv_joiners_leavers_icb(eng_wf$wf_2324,
                                                               fin_year = "2023/2024")
icb_csv_joiners_leavers_2425 <- get_wf_csv_joiners_leavers_icb(eng_wf$wf_2425,
                                                               fin_year = "2024/2025")

#check totals against excel outputs for all contract types, dentist types, ages and genders
View(icb_csv_joiners_leavers_2021 |>
       dplyr::group_by(FINANCIAL_YEAR, GEOG_NAME, JOINER_LEAVER) |>
       dplyr::summarise(t_dentists = sum(DENTIST_COUNT)))

#TO DO combine below into a function

#get region wf at performer level
#then calculate joiners leavers

eng_wf$wf_1920$active_performers$reg_output <- get_region_wf(eng_wf$wf_1920)
eng_wf$wf_2021$active_performers$reg_output <- get_region_wf(eng_wf$wf_2021)
eng_wf$wf_2122$active_performers$reg_output <- get_region_wf(eng_wf$wf_2122)
eng_wf$wf_2223$active_performers$reg_output <- get_region_wf(eng_wf$wf_2223)
eng_wf$wf_2324$active_performers$reg_output <- get_region_wf(eng_wf$wf_2324)
eng_wf$wf_2425$active_performers$reg_output <- get_region_wf(eng_wf$wf_2425)

eng_wf$wf_2021$reg_joiners_leavers <- get_region_joiners_leavers(eng_wf$wf_1920$active_performers$reg_output,
                                                                 eng_wf$wf_2021$active_performers$reg_output,
                                                                 "01/04/2020",
                                                                 "01/04/2019")
eng_wf$wf_2122$reg_joiners_leavers <- get_region_joiners_leavers(eng_wf$wf_2021$active_performers$reg_output,
                                                                 eng_wf$wf_2122$active_performers$reg_output,
                                                                 "01/04/2021",
                                                                 "01/04/2020")
eng_wf$wf_2223$reg_joiners_leavers <- get_region_joiners_leavers(eng_wf$wf_2122$active_performers$reg_output,
                                                                 eng_wf$wf_2223$active_performers$reg_output,
                                                                 "01/04/2022",
                                                                 "01/04/2021")
eng_wf$wf_2324$reg_joiners_leavers <- get_region_joiners_leavers(eng_wf$wf_2223$active_performers$reg_output,
                                                                 eng_wf$wf_2324$active_performers$reg_output,
                                                                 "01/04/2023",
                                                                 "01/04/2022")
eng_wf$wf_2425$reg_joiners_leavers <- get_region_joiners_leavers(eng_wf$wf_2324$active_performers$reg_output,
                                                                 eng_wf$wf_2425$active_performers$reg_output,
                                                                 "01/04/2024",
                                                                 "01/04/2023")

reg_csv_joiners_leavers_2021 <- get_wf_reg_joiners_leavers(eng_wf$wf_2021,
                                                           fin_year = "2020/2021")
reg_csv_joiners_leavers_2122 <- get_wf_reg_joiners_leavers(eng_wf$wf_2122,
                                                           fin_year = "2021/2022")
reg_csv_joiners_leavers_2223 <- get_wf_reg_joiners_leavers(eng_wf$wf_2223,
                                                           fin_year = "2022/2023")
reg_csv_joiners_leavers_2324 <- get_wf_reg_joiners_leavers(eng_wf$wf_2324,
                                                           fin_year = "2023/2024")
reg_csv_joiners_leavers_2425 <- get_wf_reg_joiners_leavers(eng_wf$wf_2425,
                                                           fin_year = "2024/2025")

#check totals against excel outputs for all contract types, dentist types, ages and genders
View(reg_csv_joiners_leavers_2122 |>
       dplyr::group_by(GEOG_ODS_CODE, GEOG_NAME, JOINER_LEAVER) |>
       dplyr::summarise(sum(DENTIST_COUNT)))

sicbl_csv_joiners_leavers_2021 <- get_csv_sicbl_joiners_leavers(eng_wf$wf_2021,
                                                                fin_year = "2020/2021")
sicbl_csv_joiners_leavers_2122 <- get_csv_sicbl_joiners_leavers(eng_wf$wf_2122,
                                                                fin_year = "2021/2022")
sicbl_csv_joiners_leavers_2223 <- get_csv_sicbl_joiners_leavers(eng_wf$wf_2223,
                                                                fin_year = "2022/2023")
sicbl_csv_joiners_leavers_2324 <- get_csv_sicbl_joiners_leavers(eng_wf$wf_2324,
                                                                fin_year = "2023/2024")
sicbl_csv_joiners_leavers_2425 <- get_csv_sicbl_joiners_leavers(eng_wf$wf_2425,
                                                                fin_year = "2024/2025")

#check totals against excel outputs for all contract types, dentist types, ages and genders
View(sicbl_csv_joiners_leavers_2122 |>
       dplyr::group_by(GEOG_ODS_CODE, GEOG_NAME, JOINER_LEAVER) |>
       dplyr::summarise(sum(DENTIST_COUNT)))

workforce_csv_joiners_leavers <- rbind(reg_csv_joiners_leavers_2021,
                                       reg_csv_joiners_leavers_2122,
                                       reg_csv_joiners_leavers_2223,
                                       reg_csv_joiners_leavers_2324,
                                       reg_csv_joiners_leavers_2425,
                                       icb_csv_joiners_leavers_2021,
                                       icb_csv_joiners_leavers_2122,
                                       icb_csv_joiners_leavers_2223,
                                       icb_csv_joiners_leavers_2324,
                                       icb_csv_joiners_leavers_2425,
                                       sicbl_csv_joiners_leavers_2021,
                                       sicbl_csv_joiners_leavers_2122,
                                       sicbl_csv_joiners_leavers_2223,
                                       sicbl_csv_joiners_leavers_2324,
                                       sicbl_csv_joiners_leavers_2425) |>
  dplyr::arrange(FINANCIAL_YEAR,
                 match(GEOG_TYPE, c("Region", "ICB", "SICBL")),
                 GEOG_ODS_CODE,
                 JOINER_LEAVER,
                 CONTRACT_TYPE,
                 match(AGE_GROUP, c("Under 35", "35-44", "45-54", "55+")),
                 GENDER,
                 DENTIST_TYPE)

#write data to CSVs
#change file name and path if needed
fwrite(workforce_csv_performers, "C:\\Users\\GRALI\\R\\NHS-Dental-Statistics-for-England\\outputs\\dental_performers_201920_202425.csv")
fwrite(workforce_csv_joiners_leavers, "C:\\Users\\GRALI\\R\\NHS-Dental-Statistics-for-England\\outputs\\dental_joiners_leavers_202021_202425.csv")

setwd("C:\\Users\\GRALI\\R\\NHS-Dental-Statistics-for-England\\outputs")

#get all geo data .csv files path name
den_act_csv_files <- list.files(pattern = "^dental.*\\.csv$",
                                full.names = TRUE)

#save geo data to .zip
zip("dental_workforce_201920_202425.zip",
    files = c(den_act_csv_files))