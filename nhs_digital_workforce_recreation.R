#recreate workforce data for Wales using NHS Digital inputs
#files from Y:\Official Stats\Dental\2023_24\Data\Workforce\NHS Digital files\Files for R Process

#file sent for workforce activity has had additional unknown steps applied by NHS D
#all data including the final output dataset includes foundation dentists

#read in workforce activity data -----------------------------------------------
nhsd_wal_wf <- list()

nhsd_wal_wf$activity_2223 <- readr::read_csv(
  "Y:\\Official Stats\\Dental\\2023_24\\Data\\Workforce\\NHS Digital files\\Files for R Process\\DW_2324_data2011_23.csv",
  col_names = TRUE
) |>
  dplyr::filter(Year_Start_Date == "01/04/2022")

#view(nhsd_wal_wf$annual_2223)

#read in wales roles data ------------------------------------------------------

nhsd_wal_wf$roles_2223 <- openxlsx::read.xlsx(
  "Y:\\Official Stats\\Dental\\2023_24\\Data\\Workforce\\NHS Digital files\\Role indicators for Grace (from Debs)\\Perfs_Wal_Current (202223).xlsx"
) |>
  dplyr::mutate(Financial.Year = "2022/2023") |>
  
  #view(nhsd_wal_wf$roles_2223)
  
  nhsd_wal_wf$nat_data_2223 <-
  openxlsx::read.xlsx(
    "Y:\\Official Stats\\Dental\\2023_24\\Data\\Workforce\\NHS Digital files\\Wales_Dental_Workforce_2022-23.xlsx"
    ,
    sheet = "Wales"
  )
#view(nhsd_wal_wf$nat_data_2223)

#1434 unique performer numbers in final data (each performer only appears once)
nhsd_wal_wf$nat_data_2223 |>
  dplyr::summarise(unique_performer = n_distinct(PerformerNumber))

#try using code from wales_workforce_pipeline.R to recreate 2022/23 financial year
#keep foundation dentists to see if can reconcile

wal_2223_workforce <- combined_data |>
  dplyr::filter(
    FINANCIALYEAR == "2022/2023"
    &
      NHSAREATEAMCODE %in% c("7A1", '7A2', '7A3', '7A4', '7A5', '7A6', '7A7')
    & (UOA > 0 | UDA > 0)
  ) |>
  dplyr::mutate(PERFORMERAGE = as.numeric(age_calc(from = PERFORMERDATEOFBIRTH,
                                                   to = "2022/09/30"))) |>
  dplyr::mutate(TYPEOFCONTRACT = case_when(PAIDNOTPAIDBYNHSBSA == "N" ~ "TDS",
                                           TRUE ~ TYPEOFCONTRACT)) |>
  dplyr::mutate(
    GDS_FLAG = case_when(TYPEOFCONTRACT == "GDS" ~ 1,
                         TRUE ~ 0),
    PDS_FLAG = case_when(TYPEOFCONTRACT == "PDS" ~ 1,
                         TYPEOFCONTRACT == "PDS Plus" ~ 1,
                         TRUE ~ 0),
    TDS_FLAG = case_when(TYPEOFCONTRACT == "TDS" ~ 1,
                         TRUE ~ 0),
    AGEGROUP = case_when(
      PERFORMERAGE <= 35 ~ "Under 35",
      PERFORMERAGE <= 44 ~ "35-44",
      PERFORMERAGE <= 54 ~ "45-54",
      PERFORMERAGE >= 55 ~ "55+",
      TRUE ~ as.character(PERFORMERAGE)
    )
  ) |>
  dplyr::group_by(
    PERFORMERGENDER,
    PERFORMERGDCREGISTRATIONNUMBER,
    NHSAREATEAMCODE,
    PERFORMER,
    TYPEOFCONTRACT,
    GDS_FLAG,
    PDS_FLAG,
    TDS_FLAG,
    AGEGROUP
  ) |>
  dplyr::summarise(
    TOTAL_UDA = sum(UDA),
    TOTAL_UOA = sum(UOA),
    GDS_FLAG = max(GDS_FLAG),
    PDS_FLAG = max(PDS_FLAG),
    TDS_FLAG = max(TDS_FLAG),
    .groups = "drop"
  )

#after above code, 1436 unique performer numbers
wal_2223_workforce |> dplyr::summarise(unique_performer = n_distinct(PERFORMER))

wal_roles_full$unique_2223 <- wal_roles_full$wal_roles_2223 |>
  dplyr::select(Role, Name, Performer.Id, Status, FINANCIAL_YEAR) |>
  dplyr::distinct()

#who appears in activity but not roles
#performer numbers 221821 and 824402 in Shrewsbury (near Welsh border)
#but some records under 7A7 Wales area
wal_2223_workforce |>
  dplyr::filter(!(PERFORMER %in% c(
    nhsd_wal_wf$nat_data_2223$PerformerNumber
  )))

#try running 2022/23 data using NHS Digital methodology of assigning roles from
#1. roles current extract for the year
#2 if not in above, assign using 3-year roles data file
#3. if not in either of above assign as "unknown"

#read in unique roles from 3-year extract
wal_roles_full$three_yr_2223 <- openxlsx::read.xlsx(
  "Y:\\Official Stats\\Dental\\2023_24\\Data\\Workforce\\NHS Digital files\\Role indicators for Grace (from Debs)\\Perfs_Wal_200401 (from 202223).xlsx"
) |>
  dplyr::mutate(FINANCIAL_YEAR = "2022/2023") |>
  dplyr::select(Role, Name, Performer.Id, Status, FINANCIAL_YEAR) |>
  dplyr::distinct()

#view(wal_roles_full$three_yr_2223)

wal_roles_full$unique_2223

wal_2223_workforce_roles <- wal_2223_workforce |>
  dplyr::left_join(
    select(wal_roles_full$unique_2223, Performer.Id, Role),
    by = join_by(PERFORMER == Performer.Id)
  ) |>
  dplyr::left_join(
    select(wal_roles_full$three_yr_2223, Performer.Id, Role),
    by = join_by(PERFORMER == Performer.Id)
  ) |>
  dplyr::mutate(Role = coalesce(Role.x, Role.y)) |>
  dplyr::select(-c(Role.x, Role.y))

wal_2223_workforce_roles |>
  dplyr::filter(GDS_FLAG == 0
                & PDS_FLAG == 1)
wal_2223_workforce_roles |>
  distinct(TYPEOFCONTRACT)


#get new contract type column through summarise, then add these values back to main data
wal_2223_wf_LHB <- wal_2223_workforce_roles |>
  dplyr::group_by(
    PERFORMER,
    PERFORMERGENDER,
    PERFORMERGDCREGISTRATIONNUMBER,
    NHSAREATEAMCODE,
    AGEGROUP,
    Role
  ) |>
  dplyr::summarise(
    GDS_FLAG = max(GDS_FLAG),
    PDS_FLAG = max(PDS_FLAG),
    TDS_FLAG = max(TDS_FLAG),
    .groups = "drop"
  ) |>
  dplyr::mutate(
    CONTRACT_TYPE = case_when(
      GDS_FLAG > 0 & PDS_FLAG > 0 & TDS_FLAG > 0 ~ "Mixed",
      GDS_FLAG > 0 & PDS_FLAG > 0 ~ "Mixed",
      GDS_FLAG > 0 & TDS_FLAG > 0 & PDS_FLAG == 0 ~ "GDS",
      GDS_FLAG == 0 & TDS_FLAG > 0 & PDS_FLAG > 0 ~ "PDS",
      GDS_FLAG == 0 & PDS_FLAG == 0 & TDS_FLAG > 0 ~ "TDS",
      GDS_FLAG > 0 & PDS_FLAG == 0 & TDS_FLAG == 0 ~ "GDS",
      GDS_FLAG == 0 & PDS_FLAG > 0 & TDS_FLAG == 0 ~ "PDS",
      TRUE ~ "Unknown"
    ),
    DENTIST_TYPE = case_when(
      Role == "Provider/Performer" ~ "PP",
      Role == "Performer" ~ "PO",
      Role == "Foundation Dentist" ~ "Foundation Dentist",
      TRUE ~ "Unknown"
    ),
    FINANCIAL_YEAR = "2022/23"
  )


#wal_2223_wf_LHB |>
#  dplyr::filter(!(DENTIST_TYPE %in% c("PO", "PP")))

# write final excel sheet ------------------------------------------------------

wal_2223_wf <- list()

#write 2022/23 national level data to sheet for qr checking against last year's output

# wal_2223_wf_nat_output <- wal_2223_wf_LHB |>
#   dplyr::group_by(
#     FINANCIAL_YEAR,
#     PERFORMER,
#     PERFORMERGDCREGISTRATIONNUMBER,
#     CONTRACT_TYPE,
#     AGEGROUP,
#     PERFORMERGENDER,
#     DENTIST_TYPE
#   ) |>
#   dplyr::summarise() |>
#   dplyr::ungroup() |>
#   dplyr::group_by(PERFORMER) |>
#   count() |>
#   dplyr::filter(n > 1)

wal_2223_wf$nat_output <- wal_2223_workforce_roles |>
  dplyr::group_by(
    PERFORMER,
    PERFORMERGENDER,
    PERFORMERGDCREGISTRATIONNUMBER,
    AGEGROUP,
    Role
  ) |>
  dplyr::summarise(
    GDS_FLAG = max(GDS_FLAG),
    PDS_FLAG = max(PDS_FLAG),
    TDS_FLAG = max(TDS_FLAG),
    .groups = "drop"
  ) |>
  dplyr::mutate(
    CONTRACT_TYPE = case_when(
      GDS_FLAG > 0 & PDS_FLAG > 0 & TDS_FLAG > 0 ~ "Mixed",
      GDS_FLAG > 0 & PDS_FLAG > 0 ~ "Mixed",
      GDS_FLAG > 0 & TDS_FLAG > 0 & PDS_FLAG == 0 ~ "GDS",
      GDS_FLAG == 0 & TDS_FLAG > 0 & PDS_FLAG > 0 ~ "PDS",
      GDS_FLAG == 0 & PDS_FLAG == 0 & TDS_FLAG > 0 ~ "TDS",
      GDS_FLAG > 0 & PDS_FLAG == 0 & TDS_FLAG == 0 ~ "GDS",
      GDS_FLAG == 0 & PDS_FLAG > 0 & TDS_FLAG == 0 ~ "PDS",
      TRUE ~ "Unknown"
    ),
    DENTIST_TYPE = case_when(
      Role == "Provider/Performer" ~ "PP",
      Role == "Performer" ~ "PO",
      Role == "Foundation Dentist" ~ "Foundation Dentist",
      TRUE ~ "Unknown"
    ),
    FINANCIAL_YEAR = "2022/23"
  ) |> 
  dplyr::select(Year = FINANCIAL_YEAR,
                PerformerNumber = PERFORMER,
                PerformerGDCRegistrationNumber = PERFORMERGDCREGISTRATIONNUMBER,
                ContractType = CONTRACT_TYPE,
                AgeGroup = AGEGROUP,
                PerformerGender = PERFORMERGENDER,
                DentistType = DENTIST_TYPE)

#write 2022/23 LHB level data to sheet for qr checking against last year's output

wal_2223_wf$LHB_output <- wal_2223_wf_LHB |>
  dplyr::select(
    Year = FINANCIAL_YEAR,
    LHB_Code = NHSAREATEAMCODE,
    PerformerNumber = PERFORMER,
    PerformerGDCRegistrationNumber = PERFORMERGDCREGISTRATIONNUMBER,
    ContractType = CONTRACT_TYPE,
    AgeGroup = AGEGROUP,
    PerformerGender = PERFORMERGENDER,
    DentistType = DENTIST_TYPE
  )

sheetNames <- c(
  "Wales",
  "LHB"
)

wb <- accessibleTables::create_wb(sheetNames)

#Sheet for Wales workforce
accessibleTables::write_sheet(
  workbook = wb,
  sheetname = "Wales",
  title = "Wales national workforce by performer number",
  notes = c("notes go here"),
  dataset = wal_2223_wf$nat_output,
  column_a_width = 20
)

accessibleTables::format_data(wb,
                              "Wales",
                              c("A", "D", "E", "F", "G"),
                              "left",
                              "")

accessibleTables::format_data(wb,
                              "Wales",
                              c("B", "C"),
                              "right",
                              "")

#Sheet for LHB workforce
accessibleTables::write_sheet(
  workbook = wb,
  sheetname = "LHB",
  title = "Wales Local Health Board (LHB) workforce by performer number",
  notes = c("notes go here"),
  dataset = wal_2223_wf$LHB_output,
  column_a_width = 20
)

accessibleTables::format_data(wb,
                              "LHB",
                              c("A", "B", "E", "F", "G", "H"),
                              "left",
                              "")

accessibleTables::format_data(wb,
                              "LHB",
                              c("C", "D"),
                              "right",
                              "")

openxlsx::saveWorkbook(
  wb,
  "Y:\\Official Stats\\Dental\\2023_24\\Data\\Workforce\\Outputs\\wales_dental_workforce_202223.xlsx",
  overwrite = TRUE
)

### repeat for 2023/24 data ----------------------------------------------------

wal_roles_full$unique_2324 <- wal_roles_full$wal_roles_2324 |>
  dplyr::select(Role, Name, Performer.Id, Status, FINANCIAL_YEAR) |>
  dplyr::distinct()

wal_roles_full$three_yr_2324 <- openxlsx::read.xlsx(
  "Y:\\Official Stats\\Dental\\2023_24\\Data\\Workforce\\Old_Current_Extracts\\Wales\\Perfs_Wal_210401.xlsx"
) |>
  dplyr::mutate(FINANCIAL_YEAR = "2023/2024") |>
  dplyr::select(Role, Name, Performer.Id = Personal.Id, Status, FINANCIAL_YEAR) |>
  dplyr::distinct()

wal_2324_workforce <- combined_data |>
  dplyr::filter(
    FINANCIALYEAR == "2023/2024"
    &
      NHSAREATEAMCODE %in% c("7A1", '7A2', '7A3', '7A4', '7A5', '7A6', '7A7')
    & (UOA > 0 | UDA > 0)
  ) |>
  dplyr::mutate(PERFORMERAGE = as.numeric(age_calc(from = PERFORMERDATEOFBIRTH,
                                                   to = "2023/09/30"))) |>
  dplyr::mutate(TYPEOFCONTRACT = case_when(PAIDNOTPAIDBYNHSBSA == "N" ~ "TDS",
                                           TRUE ~ TYPEOFCONTRACT)) |>
  dplyr::mutate(
    GDS_FLAG = case_when(TYPEOFCONTRACT == "GDS" ~ 1,
                         TRUE ~ 0),
    PDS_FLAG = case_when(TYPEOFCONTRACT == "PDS" ~ 1,
                         TYPEOFCONTRACT == "PDS Plus" ~ 1,
                         TRUE ~ 0),
    TDS_FLAG = case_when(TYPEOFCONTRACT == "TDS" ~ 1,
                         TRUE ~ 0),
    AGEGROUP = case_when(
      PERFORMERAGE <= 35 ~ "Under 35",
      PERFORMERAGE <= 44 ~ "35-44",
      PERFORMERAGE <= 54 ~ "45-54",
      PERFORMERAGE >= 55 ~ "55+",
      TRUE ~ as.character(PERFORMERAGE)
    )
  ) |>
  dplyr::group_by(
    PERFORMERGENDER,
    PERFORMERGDCREGISTRATIONNUMBER,
    NHSAREATEAMCODE,
    PERFORMER,
    TYPEOFCONTRACT,
    GDS_FLAG,
    PDS_FLAG,
    TDS_FLAG,
    AGEGROUP
  ) |>
  dplyr::summarise(
    TOTAL_UDA = sum(UDA),
    TOTAL_UOA = sum(UOA),
    GDS_FLAG = max(GDS_FLAG),
    PDS_FLAG = max(PDS_FLAG),
    TDS_FLAG = max(TDS_FLAG),
    .groups = "drop"
  )

wal_2324_workforce_roles <- wal_2324_workforce |>
  dplyr::left_join(
    select(wal_roles_full$unique_2324, Performer.Id, Role),
    by = join_by(PERFORMER == Performer.Id)
  ) |>
  dplyr::left_join(
    select(wal_roles_full$three_yr_2324, Performer.Id, Role),
    by = join_by(PERFORMER == Performer.Id)
  ) |>
  dplyr::mutate(Role = coalesce(Role.x, Role.y)) |>
  dplyr::select(-c(Role.x, Role.y))

wal_2324_wf_LHB <- wal_2324_workforce_roles |>
  dplyr::group_by(
    PERFORMER,
    PERFORMERGENDER,
    PERFORMERGDCREGISTRATIONNUMBER,
    NHSAREATEAMCODE,
    AGEGROUP,
    Role
  ) |>
  dplyr::summarise(
    GDS_FLAG = max(GDS_FLAG),
    PDS_FLAG = max(PDS_FLAG),
    TDS_FLAG = max(TDS_FLAG),
    .groups = "drop"
  ) |>
  dplyr::mutate(
    CONTRACT_TYPE = case_when(
      GDS_FLAG > 0 & PDS_FLAG > 0 & TDS_FLAG > 0 ~ "Mixed",
      GDS_FLAG > 0 & PDS_FLAG > 0 ~ "Mixed",
      GDS_FLAG > 0 & TDS_FLAG > 0 & PDS_FLAG == 0 ~ "GDS",
      GDS_FLAG == 0 & TDS_FLAG > 0 & PDS_FLAG > 0 ~ "PDS",
      GDS_FLAG == 0 & PDS_FLAG == 0 & TDS_FLAG > 0 ~ "TDS",
      GDS_FLAG > 0 & PDS_FLAG == 0 & TDS_FLAG == 0 ~ "GDS",
      GDS_FLAG == 0 & PDS_FLAG > 0 & TDS_FLAG == 0 ~ "PDS",
      TRUE ~ "Unknown"
    ),
    DENTIST_TYPE = case_when(
      Role == "Provider/Performer" ~ "PP",
      Role == "Performer" ~ "PO",
      Role == "Foundation Dentist" ~ "Foundation Dentist",
      TRUE ~ "Unknown"
    ),
    FINANCIAL_YEAR = "2023/24"
  )

wal_2324_wf <- list()

wal_2324_wf$nat_output <- wal_2324_workforce_roles |>
  dplyr::group_by(
    PERFORMER,
    PERFORMERGENDER,
    PERFORMERGDCREGISTRATIONNUMBER,
    AGEGROUP,
    Role
  ) |>
  dplyr::summarise(
    GDS_FLAG = max(GDS_FLAG),
    PDS_FLAG = max(PDS_FLAG),
    TDS_FLAG = max(TDS_FLAG),
    .groups = "drop"
  ) |>
  dplyr::mutate(
    CONTRACT_TYPE = case_when(
      GDS_FLAG > 0 & PDS_FLAG > 0 & TDS_FLAG > 0 ~ "Mixed",
      GDS_FLAG > 0 & PDS_FLAG > 0 ~ "Mixed",
      GDS_FLAG > 0 & TDS_FLAG > 0 & PDS_FLAG == 0 ~ "GDS",
      GDS_FLAG == 0 & TDS_FLAG > 0 & PDS_FLAG > 0 ~ "PDS",
      GDS_FLAG == 0 & PDS_FLAG == 0 & TDS_FLAG > 0 ~ "TDS",
      GDS_FLAG > 0 & PDS_FLAG == 0 & TDS_FLAG == 0 ~ "GDS",
      GDS_FLAG == 0 & PDS_FLAG > 0 & TDS_FLAG == 0 ~ "PDS",
      TRUE ~ "Unknown"
    ),
    DENTIST_TYPE = case_when(
      Role == "Provider/Performer" ~ "PP",
      Role == "Performer" ~ "PO",
      Role == "Foundation Dentist" ~ "Foundation Dentist",
      TRUE ~ "Unknown"
    ),
    FINANCIAL_YEAR = "2023/24"
  ) |> 
  dplyr::select(Year = FINANCIAL_YEAR,
                PerformerNumber = PERFORMER,
                PerformerGDCRegistrationNumber = PERFORMERGDCREGISTRATIONNUMBER,
                ContractType = CONTRACT_TYPE,
                AgeGroup = AGEGROUP,
                PerformerGender = PERFORMERGENDER,
                DentistType = DENTIST_TYPE)

#write 2023/24 LHB level data to sheet for qr checking against last year's output

wal_2324_wf$LHB_output <- wal_2324_wf_LHB |>
  dplyr::select(
    Year = FINANCIAL_YEAR,
    LHB_Code = NHSAREATEAMCODE,
    PerformerNumber = PERFORMER,
    PerformerGDCRegistrationNumber = PERFORMERGDCREGISTRATIONNUMBER,
    ContractType = CONTRACT_TYPE,
    AgeGroup = AGEGROUP,
    PerformerGender = PERFORMERGENDER,
    DentistType = DENTIST_TYPE
  )

wb <- createWorkbook()

## Add worksheets
addWorksheet(wb, "Wales")
addWorksheet(wb, "LHB")

writeData(wb, "Wales", wal_2324_wf$nat_output, startCol = 1, startRow = 1, rowNames = TRUE)
writeData(wb, "LHB", wal_2324_wf$LHB_output, startCol = 1, startRow = 1, rowNames = TRUE)

openxlsx::saveWorkbook(
  wb,
  "Y:\\Official Stats\\Dental\\2023_24\\Data\\Workforce\\Outputs\\wales_dental_workforce_202324.xlsx",
  overwrite = TRUE
)


