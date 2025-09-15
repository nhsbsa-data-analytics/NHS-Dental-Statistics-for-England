#Script to create Wales workforce data to send to external team
#extracts, formats, and writes data to excel files needed
#for Wales national and Wales Local Health Board (LHB) level
#data covers active performers by financial year as well as joiners and leavers

#extract base data -------------------------------------------------------------

#Database connection created in main publication pipeline.R script

#Main workforce table extracted in England workforce pipeline script

# workforce_fact <- dplyr::tbl(con,
#                              from = dbplyr::in_schema("OST", "DS_WORKFORCE_FACT_202503")) |>
#   collect()

#switch to using Wales specific table due to change in how activity is assigned to treatment year
wal_workforce_fact <- dplyr::tbl(con,
                             from = dbplyr::in_schema("OST", "DS_WORKFORCE_FACT_202503_WALES")) |>
  collect()

#import roles data -------------------------------------------------------------
#using import_roles_data_2425.R script
#already loaded if England workforce pipeline run before Wales workforce pipeline

#source(import_roles_data.R)

#explore data ------------------------------------------------------------------

#if using combined England and Wales fact table, limit to Wales data only using ONS country code
#wales_wf_fact <- workforce_fact |>
#  dplyr::filter(ONS_COUNTRY == "W92000004")

#check if all activity has LHB commissioner
#no rows without LHB commissioner code
# View(wales_wf_fact |>
#        dplyr::filter(!(
#          COMMISSIONER_CODE %in% c("7A1", '7A2', '7A3', '7A4', '7A5', '7A6', '7A7')
#        )))

#some rows have non-LHB in CCG_CODE column
# View(wal_workforce_fact |>
#        dplyr::filter(!(
#          CCG_CODE %in% c("7A1", '7A2', '7A3', '7A4', '7A5', '7A6', '7A7')
#        )))

#commissioner code matches latest commissioner code for all rows
# View(wal_workforce_fact |>
#        dplyr::filter(COMMISSIONER_CODE != LTST_COMM_CODE))

#check for rows with no activity (UDA or UOA)
#some minus values, probably contra forms/corrections
# View(wal_workforce_fact |>
#        dplyr::filter(UDA < 1 & UOA < 1))

#split fact table data into dataset for each financial year
wal_wf_raw <- wf_year_split(wal_workforce_fact)

#create list of active performers in each financial year dataset
#uses roles data to map performer role to performer ID number
wal_wf <- list()

wal_wf$wf_1920$active_performers <- get_wal_wf(wal_roles_distinct$roles_1920_1yr,
                                               wal_roles_distinct$roles_1920_3yr,
                                               wal_wf_raw$wf_1920)
wal_wf$wf_2021$active_performers <- get_wal_wf(wal_roles_distinct$roles_2021_1yr,
                                               wal_roles_distinct$roles_2021_3yr,
                                               wal_wf_raw$wf_2021)
wal_wf$wf_2122$active_performers <- get_wal_wf(wal_roles_distinct$roles_2122_1yr,
                                               wal_roles_distinct$roles_2122_3yr,
                                               wal_wf_raw$wf_2122)
wal_wf$wf_2223$active_performers <- get_wal_wf(wal_roles_distinct$roles_2223_1yr,
                                               wal_roles_distinct$roles_2223_3yr,
                                               wal_wf_raw$wf_2223)
wal_wf$wf_2324$active_performers <- get_wal_wf(wal_roles_distinct$roles_2324_1yr,
                                               wal_roles_distinct$roles_2324_3yr,
                                               wal_wf_raw$wf_2324)
wal_wf$wf_2425$active_performers <- get_wal_wf(wal_roles_distinct$roles_2425_1yr,
                                               comb_1yr_files_wal,
                                               wal_wf_raw$wf_2425)


#if need to remove DCPs

# wal_wf$wf_2324$active_performers$nat_output <- wal_wf[["wf_2324"]][["active_performers"]][["nat_output"]] |>
#   dplyr::filter(!(DentistType == "Dental Care Professional"))
# wal_wf$wf_2324$active_performers$LHB_output <- wal_wf[["wf_2324"]][["active_performers"]][["LHB_output"]] |>
#   dplyr::filter(!(DentistType == "Dental Care Professional"))
# wal_wf$wf_2425$active_performers$nat_output <- wal_wf[["wf_2425"]][["active_performers"]][["nat_output"]] |>
#   dplyr::filter(!(DentistType == "Dental Care Professional"))
# wal_wf$wf_2425$active_performers$LHB_output <- wal_wf[["wf_2425"]][["active_performers"]][["LHB_output"]] |>
#   dplyr::filter(!(DentistType == "Dental Care Professional"))

# View(wal_wf[["wf_2425"]][["nat_joiners_leavers"]][["leavers"]] |>
#    dplyr::filter(!(DentistType == "Dental Care Professional")))

#compare 2023/24 performers against output sent to Wales team last year

#national sheet
wal_wf_2324_output <- openxlsx::read.xlsx(
  "Y:\\Official Stats\\Dental\\2023_24\\Data\\Workforce\\Outputs\\wales_dental_workforce_202324_v001.xlsx",
  sheet = 1) |>
  dplyr::mutate(FINANCIAL_YEAR = "2023/2024")

#LHB sheet
wal_wf_2324_output_LHB <- openxlsx::read.xlsx(
  "Y:\\Official Stats\\Dental\\2023_24\\Data\\Workforce\\Outputs\\wales_dental_workforce_202324_v001.xlsx",
  sheet = 2) |>
  dplyr::mutate(FINANCIAL_YEAR = "2023/2024")

#distinct performers in last year's 2023/24 national active performers
wal_wf_2324_output_distinct <- wal_wf_2324_output |>
       dplyr::distinct(PerformerNumber)

#distinct performers in new 2023/24 national active performers
wal_wf_new_output_distinct <- wal_wf$wf_2324$active_performers$nat_output |>
  dplyr::distinct(PerformerNumber)

#1 extra performer in new output

res <-setdiff(wal_wf_2324_output_distinct, wal_wf_new_output_distinct) 
res_2 <-setdiff(wal_wf_new_output_distinct, wal_wf_2324_output_distinct) 

#distinct performers in last year's 2023/24 LHB active performers (same as national)
wal_wf_2324_output_distinct_LHB <- wal_wf_2324_output_LHB |>
  dplyr::distinct(PerformerNumber)
#distinct performers in new 2023/24 LHB active performers (same as national)
wal_wf_new_output_distinct_LHB <- wal_wf$wf_2324$active_performers$LHB_output |>
  dplyr::distinct(PerformerNumber)  

#get joiners and leavers at Wales national level
wal_wf$wf_2021$nat_joiners_leavers <- get_nat_joiners_leavers(wal_wf$wf_1920$active_performers$nat_output,
                                                              wal_wf$wf_2021$active_performers$nat_output,
                                                              "01/04/2020",
                                                              "01/04/2019")
wal_wf$wf_2122$nat_joiners_leavers <- get_nat_joiners_leavers(wal_wf$wf_2021$active_performers$nat_output,
                                                              wal_wf$wf_2122$active_performers$nat_output,
                                                              "01/04/2021",
                                                              "01/04/2020")
wal_wf$wf_2223$nat_joiners_leavers <- get_nat_joiners_leavers(wal_wf$wf_2122$active_performers$nat_output,
                                                              wal_wf$wf_2223$active_performers$nat_output,
                                                              "01/04/2022",
                                                              "01/04/2021")
wal_wf$wf_2324$nat_joiners_leavers <- get_nat_joiners_leavers(wal_wf$wf_2223$active_performers$nat_output,
                                                              wal_wf$wf_2324$active_performers$nat_output,
                                                              "01/04/2023",
                                                              "01/04/2022")
wal_wf$wf_2425$nat_joiners_leavers <- get_nat_joiners_leavers(wal_wf$wf_2324$active_performers$nat_output,
                                                              wal_wf$wf_2425$active_performers$nat_output,
                                                              "01/04/2024",
                                                              "01/04/2023")

#get joiners and leavers at Wales LHB level
wal_wf$wf_2021$LHB_joiners_leavers <- get_lhb_joiners_leavers(wal_wf$wf_1920$active_performers$LHB_output,
                                                              wal_wf$wf_2021$active_performers$LHB_output,
                                                              "01/04/2020",
                                                              "01/04/2019")
wal_wf$wf_2122$LHB_joiners_leavers <- get_lhb_joiners_leavers(wal_wf$wf_2021$active_performers$LHB_output,
                                                              wal_wf$wf_2122$active_performers$LHB_output,
                                                              "01/04/2021",
                                                              "01/04/2020")
wal_wf$wf_2223$LHB_joiners_leavers <- get_lhb_joiners_leavers(wal_wf$wf_2122$active_performers$LHB_output,
                                                              wal_wf$wf_2223$active_performers$LHB_output,
                                                              "01/04/2022",
                                                              "01/04/2021")
wal_wf$wf_2324$LHB_joiners_leavers <- get_lhb_joiners_leavers(wal_wf$wf_2223$active_performers$LHB_output,
                                                              wal_wf$wf_2324$active_performers$LHB_output,
                                                              "01/04/2023",
                                                              "01/04/2022")
wal_wf$wf_2425$LHB_joiners_leavers <- get_lhb_joiners_leavers(wal_wf$wf_2324$active_performers$LHB_output,
                                                              wal_wf$wf_2425$active_performers$LHB_output,
                                                              "01/04/2024",
                                                              "01/04/2023")

  
# optional code for writing to worksheet ---------------------------------------

#write workbook for each year 2019/20 to 2024/25
#TO DO: automate codeto reduce duplicated code lines

wb <- createWorkbook()

## Add worksheets
addWorksheet(wb, "Wales")
addWorksheet(wb, "Wales_joiners")
addWorksheet(wb, "Wales_leavers")
addWorksheet(wb, "LHB")
addWorksheet(wb, "LHB_joiners")
addWorksheet(wb, "LHB_leavers")

writeData(wb, "Wales", wal_wf$wf_2425$active_performers$nat_output, startCol = 1, startRow = 1, rowNames = TRUE)
writeData(wb, "Wales_joiners", wal_wf$wf_2425$nat_joiners_leavers$joiners, startCol = 1, startRow = 1, rowNames = TRUE)
writeData(wb, "Wales_leavers", wal_wf$wf_2425$nat_joiners_leavers$leavers, startCol = 1, startRow = 1, rowNames = TRUE)
writeData(wb, "LHB", wal_wf$wf_2425$active_performers$LHB_output, startCol = 1, startRow = 1, rowNames = TRUE)
writeData(wb, "LHB_joiners", wal_wf$wf_2425$LHB_joiners_leavers$joiners, startCol = 1, startRow = 1, rowNames = TRUE)
writeData(wb, "LHB_leavers", wal_wf$wf_2425$LHB_joiners_leavers$leavers, startCol = 1, startRow = 1, rowNames = TRUE)

openxlsx::saveWorkbook(
  wb,
  "Y:\\Official Stats\\Dental\\2024_25\\Data\\Workforce\\Outputs\\wales_dental_workforce_202425.xlsx",
  overwrite = TRUE)

wb <- createWorkbook()

## Add worksheets
addWorksheet(wb, "Wales")
addWorksheet(wb, "Wales_joiners")
addWorksheet(wb, "Wales_leavers")
addWorksheet(wb, "LHB")
addWorksheet(wb, "LHB_joiners")
addWorksheet(wb, "LHB_leavers")

writeData(wb, "Wales", wal_wf$wf_2324$active_performers$nat_output, startCol = 1, startRow = 1, rowNames = TRUE)
writeData(wb, "Wales_joiners", wal_wf$wf_2324$nat_joiners_leavers$joiners, startCol = 1, startRow = 1, rowNames = TRUE)
writeData(wb, "Wales_leavers", wal_wf$wf_2324$nat_joiners_leavers$leavers, startCol = 1, startRow = 1, rowNames = TRUE)
writeData(wb, "LHB", wal_wf$wf_2324$active_performers$LHB_output, startCol = 1, startRow = 1, rowNames = TRUE)
writeData(wb, "LHB_joiners", wal_wf$wf_2324$LHB_joiners_leavers$joiners, startCol = 1, startRow = 1, rowNames = TRUE)
writeData(wb, "LHB_leavers", wal_wf$wf_2324$LHB_joiners_leavers$leavers, startCol = 1, startRow = 1, rowNames = TRUE)

openxlsx::saveWorkbook(
  wb,
  "Y:\\Official Stats\\Dental\\2024_25\\Data\\Workforce\\Outputs\\wales_dental_workforce_202324.xlsx",
  overwrite = TRUE)

wb <- createWorkbook()

## Add worksheets
addWorksheet(wb, "Wales")
addWorksheet(wb, "Wales_joiners")
addWorksheet(wb, "Wales_leavers")
addWorksheet(wb, "LHB")
addWorksheet(wb, "LHB_joiners")
addWorksheet(wb, "LHB_leavers")

writeData(wb, "Wales", wal_wf$wf_2223$active_performers$nat_output, startCol = 1, startRow = 1, rowNames = TRUE)
writeData(wb, "Wales_joiners", wal_wf$wf_2223$nat_joiners_leavers$joiners, startCol = 1, startRow = 1, rowNames = TRUE)
writeData(wb, "Wales_leavers", wal_wf$wf_2223$nat_joiners_leavers$leavers, startCol = 1, startRow = 1, rowNames = TRUE)
writeData(wb, "LHB", wal_wf$wf_2223$active_performers$LHB_output, startCol = 1, startRow = 1, rowNames = TRUE)
writeData(wb, "LHB_joiners", wal_wf$wf_2223$LHB_joiners_leavers$joiners, startCol = 1, startRow = 1, rowNames = TRUE)
writeData(wb, "LHB_leavers", wal_wf$wf_2223$LHB_joiners_leavers$leavers, startCol = 1, startRow = 1, rowNames = TRUE)

openxlsx::saveWorkbook(
  wb,
  "Y:\\Official Stats\\Dental\\2024_25\\Data\\Workforce\\Outputs\\wales_dental_workforce_202223.xlsx",
  overwrite = TRUE)

wb <- createWorkbook()

## Add worksheets
addWorksheet(wb, "Wales")
addWorksheet(wb, "Wales_joiners")
addWorksheet(wb, "Wales_leavers")
addWorksheet(wb, "LHB")
addWorksheet(wb, "LHB_joiners")
addWorksheet(wb, "LHB_leavers")

writeData(wb, "Wales", wal_wf$wf_2122$active_performers$nat_output, startCol = 1, startRow = 1, rowNames = TRUE)
writeData(wb, "Wales_joiners", wal_wf$wf_2122$nat_joiners_leavers$joiners, startCol = 1, startRow = 1, rowNames = TRUE)
writeData(wb, "Wales_leavers", wal_wf$wf_2122$nat_joiners_leavers$leavers, startCol = 1, startRow = 1, rowNames = TRUE)
writeData(wb, "LHB", wal_wf$wf_2122$active_performers$LHB_output, startCol = 1, startRow = 1, rowNames = TRUE)
writeData(wb, "LHB_joiners", wal_wf$wf_2122$LHB_joiners_leavers$joiners, startCol = 1, startRow = 1, rowNames = TRUE)
writeData(wb, "LHB_leavers", wal_wf$wf_2122$LHB_joiners_leavers$leavers, startCol = 1, startRow = 1, rowNames = TRUE)

openxlsx::saveWorkbook(
  wb,
  "Y:\\Official Stats\\Dental\\2024_25\\Data\\Workforce\\Outputs\\wales_dental_workforce_202122.xlsx",
  overwrite = TRUE)

wb <- createWorkbook()

## Add worksheets
addWorksheet(wb, "Wales")
addWorksheet(wb, "Wales_joiners")
addWorksheet(wb, "Wales_leavers")
addWorksheet(wb, "LHB")
addWorksheet(wb, "LHB_joiners")
addWorksheet(wb, "LHB_leavers")

writeData(wb, "Wales", wal_wf$wf_2021$active_performers$nat_output, startCol = 1, startRow = 1, rowNames = TRUE)
writeData(wb, "Wales_joiners", wal_wf$wf_2021$nat_joiners_leavers$joiners, startCol = 1, startRow = 1, rowNames = TRUE)
writeData(wb, "Wales_leavers", wal_wf$wf_2021$nat_joiners_leavers$leavers, startCol = 1, startRow = 1, rowNames = TRUE)
writeData(wb, "LHB", wal_wf$wf_2021$active_performers$LHB_output, startCol = 1, startRow = 1, rowNames = TRUE)
writeData(wb, "LHB_joiners", wal_wf$wf_2021$LHB_joiners_leavers$joiners, startCol = 1, startRow = 1, rowNames = TRUE)
writeData(wb, "LHB_leavers", wal_wf$wf_2021$LHB_joiners_leavers$leavers, startCol = 1, startRow = 1, rowNames = TRUE)

openxlsx::saveWorkbook(
  wb,
  "Y:\\Official Stats\\Dental\\2024_25\\Data\\Workforce\\Outputs\\wales_dental_workforce_202021.xlsx",
  overwrite = TRUE)

wb <- createWorkbook()

## Add worksheets
addWorksheet(wb, "Wales")
addWorksheet(wb, "LHB")

writeData(wb, "Wales", wal_wf$wf_1920$active_performers$nat_output, startCol = 1, startRow = 1, rowNames = TRUE)
writeData(wb, "LHB", wal_wf$wf_1920$active_performers$LHB_output, startCol = 1, startRow = 1, rowNames = TRUE)

openxlsx::saveWorkbook(
  wb,
  "Y:\\Official Stats\\Dental\\2024_25\\Data\\Workforce\\Outputs\\wales_dental_workforce_201920.xlsx",
  overwrite = TRUE)