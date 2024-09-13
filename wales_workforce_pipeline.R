#install and library packages --------------------------------------------------

#install.packages(c("openxlsx", "tidyverse", "lubridate", "vroom"))

library(openxlsx)
library(tidyverse)
library(lubridate)
library(vroom)

#read in raw workforce activity data -------------------------------------------

#set raw data path
path <-
  "Y:\\Official Stats\\Dental\\2023_24\\Data\\Workforce\\raw\\"
save_path <-
  "Y:\\Official Stats\\Dental\\2023_24\\Data\\Workforce\\"

#get all .xlsx files in folder
files <- list.files(path = path, pattern = "\\.xlsx$")

combined_data <- data.frame()

#loop through all files in folder
for (i in 1:length(files)) {
  print(i)
  
  #read data
  raw_data <- openxlsx::read.xlsx(paste0(path, files[i]),
                                  sheet = "Data")
  
  #get FY from file name
  raw_fy <- substr(as.character(files[i]), 13, 19)
  split_fy <- strsplit(raw_fy, "-")[[1]]
  formatted_fy <- paste0(split_fy[1], "/", "20", split_fy[2])
  
  #add fy to raw data
  data <- raw_data |>
    mutate(FINANCIAL_YEAR = formatted_fy)
  
  #remove unused columns
  data <- data |>
    select(-PerfTitle,-PerformerInitials,-PerformerSurname)
  
  #make finanacial year first column
  data <-
    data[, c("FINANCIAL_YEAR", setdiff(names(data), "FINANCIAL_YEAR"))]
  
  #add column NHS.Clinical.Commissioning.Group.(CCG).Code missing if missing (is in 2022/23 data)
  if (formatted_fy %in% c("2019/2020", "2020/2021", "2021/2022")) {
    data[["NHS.Clinical.Commissioning.Group.(CCG).Code"]] <- NA
  }
  
  #format dates
  data <- data |>
    mutate(
      PerformerDateofBirth = as.Date(PerformerDateofBirth, origin = "1899-12-30"),
      ContractStartDate = as.Date(ContractStartDate, origin = "1899-12-30"),
      ContractEndDate = as.Date(ContractEndDate, origin = "1899-12-30"),
      PerformerStartDate = as.Date(PerformerStartDate, origin = "1899-12-30"),
      PerformerEndDate = as.Date(PerformerEndDate, origin = "1899-12-30")
    )
  
  #tidy column names and relocate missing column
  data <- data |>
    rename_with(~ gsub(" ", "_", toupper(gsub(
      "[^[:alnum:] £]", "", .
    ))), everything()) |>
    relocate(NHSCLINICALCOMMISSIONINGGROUPCCGCODE, .after = NHSAREATEAMCODE)
  
  combined_data <- rbind(combined_data, data)
}

#previous extract already saved in filepath
#save data as .rda
#save(combined_data, file = paste0(save_path, "DWG_EXTRACT_COMB_WALES.rda"))

#investigate combined data -----------------------------------------------------

#for 2022/23 distinct performer column values in england with activity
#is 24151, which matches NHSE
eng_dents_2223 <- combined_data |>
  dplyr::filter(
    FINANCIALYEAR == "2022/2023"
    &
      !NHSAREATEAMCODE %in% c("7A1", '7A2', '7A3', '7A4', '7A5', '7A6', '7A7')
    & (UOA > 0 | UDA > 0)
  ) |>
  dplyr::distinct(PERFORMER)

eng_dents_2122 <- combined_data |>
  dplyr::filter(
    FINANCIALYEAR == "2021/2022"
    &
      !NHSAREATEAMCODE %in% c("7A1", '7A2', '7A3', '7A4', '7A5', '7A6', '7A7')
    & (UOA > 0 | UDA > 0)
  ) |>
  dplyr::distinct(PERFORMER)

eng_dents_2021 <- combined_data |>
  dplyr::filter(
    FINANCIALYEAR == "2020/2021"
    &
      !NHSAREATEAMCODE %in% c("7A1", '7A2', '7A3', '7A4', '7A5', '7A6', '7A7')
    & (UOA > 0 | UDA > 0)
  ) |>
  dplyr::distinct(PERFORMER)

eng_dents_1920 <- combined_data |>
  dplyr::filter(
    FINANCIALYEAR == "2019/2020"
    &
      !NHSAREATEAMCODE %in% c("7A1", '7A2', '7A3', '7A4', '7A5', '7A6', '7A7')
    & (UOA > 0 | UDA > 0)
  ) |>
  dplyr::distinct(PERFORMER)

eng_dents_2324 <- combined_data |>
  dplyr::filter(
    FINANCIALYEAR == "2023/2024"
    &
      !NHSAREATEAMCODE %in% c("7A1", '7A2', '7A3', '7A4', '7A5', '7A6', '7A7')
    & (UOA > 0 | UDA > 0)
  ) |>
  dplyr::distinct(PERFORMER)

# #try using GDC registration number in case any doubles of performer number
# eng_dents_2223_GDC <- combined_data |>
#   dplyr::filter(FINANCIALYEAR == "2022/2023"
#                 & ! NHSAREATEAMCODE %in% c("7A1",'7A2','7A3','7A4','7A5','7A6','7A7')
#                 & (UOA > 0 | UDA > 0)) |>
#   dplyr::distinct(PERFORMERGDCREGISTRATIONNUMBER)

# #try using GDC registration number in case any doubles of performer number
# eng_dents_2122_GDC <- combined_data |>
#   dplyr::filter(FINANCIALYEAR == "2021/2022"
#                 & ! NHSAREATEAMCODE %in% c("7A1",'7A2','7A3','7A4','7A5','7A6','7A7')
#                 & (UOA > 0 | UDA > 0)) |>
#   dplyr::distinct(PERFORMERGDCREGISTRATIONNUMBER)

#read in workforce roles data --------------------------------------------------

#set roles data path
eng_roles_path <-
  "Y:\\Official Stats\\Dental\\2023_24\\Data\\Workforce\\Old_Current_Extracts\\England"
wal_roles_path <-
  "Y:\\Official Stats\\Dental\\2023_24\\Data\\Workforce\\Old_Current_Extracts\\Wales"

#roles_save_path <- "Y:\\Official Stats\\Dental\\2023_24\\Data\\Workforce\\"

#wrap into a loop later (code below doesn't work)
# get all .xlsx files in folder
# wal_files <- list.files(path = wal_roles_path, pattern = "\\.xlsx$")
#
# wal_roles_data <- data.frame()
#
# #loop through all files in folder
# for(i in 1:length(wal_files)) {
#
#   print(i)
#
#   #read data
#   raw_data_wal <- openxlsx::read.xlsx(
#     paste0(wal_roles_path, wal_files[i]),
#     sheet = "Sheet1"
#   )
#
#   #get FY from file name
#   raw_cy <- substr(as.character(wal_files[i]), 19, 22)
#
#   #TO DO: format calendar year as financial year
#   #mutate case when statement eg. when 2020, then 2020/2021
#   #add fy to raw data
#   data_wal <- raw_data_wal |>
#     dplyr::mutate(FINANCIAL_YEAR = raw_cy) |>
#     dplyr::mutate(FINANCIAL_YEAR =
#                     case_when(FINANCIAL_YEAR == "2020" ~ "2019/2020",
#                               FINANCIAL_YEAR == "2021" ~ "2020/2021",
#                               FINANCIAL_YEAR == "2022" ~ "2021/2022",
#                               FINANCIAL_YEAR == "2023" ~ "2022/2023",
#                               FINANCIAL_YEAR == "2024" ~ "2023/2024",
#                               TRUE ~ "unknown"))
#
#   #remove unused columns
#   data_wal <- data_wal |>
#     dplyr::filter(Role != c("Dental Care Professional", "Foundation Dentist") &
#                     Status == "Current") |>
#     dplyr::select(
#       -Name,
#       -(`Email Address`),
#       `Business Owner Flag`
#     )
#
#   #make finanacial year first column
#   data_wal <- data_wal[, c("FINANCIAL_YEAR", setdiff(names(data_wal), "FINANCIAL_YEAR"))]
#
#   #tidy column names and relocate missing column
#   data_wal <- data_wal |>
#     rename_with( ~ gsub(" ", "_", toupper(gsub(
#       "[^[:alnum:] £]", "", .
#     ))), everything())
#
#   combined_role_data_wal <- rbind(wal_roles_data, data_wal)
# }

#read in raw roles data files --------------------------------------------------

#TO DO: wrap into loop/list as above

#full roles dataset 
wal_roles_full <- data.frame()

wal_roles_1920 <-
  openxlsx::read.xlsx(
    "Y:\\Official Stats\\Dental\\2023_24\\Data\\Workforce\\Old_Current_Extracts\\Wales\\Perfs_Wal_Current_2020.xlsx",
    sheet = "Sheet1"
  ) |>
  dplyr::mutate(FINANCIAL_YEAR = "2019/2020") |>
  dplyr::select(!(Email.Address))

wal_roles_2021 <-
  openxlsx::read.xlsx(
    "Y:\\Official Stats\\Dental\\2023_24\\Data\\Workforce\\Old_Current_Extracts\\Wales\\Perfs_Wal_Current_2021.xlsx",
    sheet = "Sheet1"
  ) |>
  dplyr::mutate(FINANCIAL_YEAR = "2020/2021") |>
  dplyr::select(!(Email.Address))

wal_roles_2122 <-
  openxlsx::read.xlsx(
    "Y:\\Official Stats\\Dental\\2023_24\\Data\\Workforce\\Old_Current_Extracts\\Wales\\Perfs_Wal_Current_2022.xlsx",
    sheet = "Sheet1"
  ) |>
  dplyr::mutate(FINANCIAL_YEAR = "2021/2022")

wal_roles_2223 <-
  openxlsx::read.xlsx(
    "Y:\\Official Stats\\Dental\\2023_24\\Data\\Workforce\\Old_Current_Extracts\\Wales\\Perfs_Wal_Current_2023.xlsx",
    sheet = "Sheet1"
  ) |>
  dplyr::mutate(FINANCIAL_YEAR = "2022/2023")

wal_roles_2324 <-
  openxlsx::read.xlsx(
    "Y:\\Official Stats\\Dental\\2023_24\\Data\\Workforce\\Old_Current_Extracts\\Wales\\Perfs_Wal_Current_2024.xlsx",
    sheet = "Sheet1"
  ) |>
  dplyr::mutate(FINANCIAL_YEAR = "2023/2024") |>
  dplyr::rename(Performer.Id = Personal.Id)

role_data_wal_full <- rbind(
  wal_roles_full,
  wal_roles_1920,
  wal_roles_2021,
  wal_roles_2122,
  wal_roles_2223,
  wal_roles_2324
)

wal_roles_data <- data.frame()

raw_data_wal_1920 <-
  openxlsx::read.xlsx(
    "Y:\\Official Stats\\Dental\\2023_24\\Data\\Workforce\\Old_Current_Extracts\\Wales\\Perfs_Wal_Current_2020.xlsx",
    sheet = "Sheet1"
  ) |>
  dplyr::mutate(FINANCIAL_YEAR = "2019/2020") |>
  dplyr::select(FINANCIAL_YEAR,
                Role,
                Performer.Id) |>
  dplyr::filter(Role != c("Foundation Dentist"))

raw_data_wal_2021 <-
  openxlsx::read.xlsx(
    "Y:\\Official Stats\\Dental\\2023_24\\Data\\Workforce\\Old_Current_Extracts\\Wales\\Perfs_Wal_Current_2021.xlsx",
    sheet = "Sheet1"
  ) |>
  dplyr::mutate(FINANCIAL_YEAR = "2020/2021") |>
  dplyr::select(FINANCIAL_YEAR,
                Role,
                Performer.Id) |>
  dplyr::filter(Role != c("Foundation Dentist"))

raw_data_wal_2122 <-
  openxlsx::read.xlsx(
    "Y:\\Official Stats\\Dental\\2023_24\\Data\\Workforce\\Old_Current_Extracts\\Wales\\Perfs_Wal_Current_2022.xlsx",
    sheet = "Sheet1"
  ) |>
  dplyr::mutate(FINANCIAL_YEAR = "2021/2022") |>
  dplyr::select(FINANCIAL_YEAR,
                Role,
                Performer.Id) |>
  dplyr::filter(Role != c("Foundation Dentist"))

raw_data_wal_2223 <-
  openxlsx::read.xlsx(
    "Y:\\Official Stats\\Dental\\2023_24\\Data\\Workforce\\Old_Current_Extracts\\Wales\\Perfs_Wal_Current_2023.xlsx",
    sheet = "Sheet1"
  ) |>
  dplyr::mutate(FINANCIAL_YEAR = "2022/2023") |>
  dplyr::select(FINANCIAL_YEAR,
                Role,
                Performer.Id) |>
  dplyr::filter(Role != c("Foundation Dentist"))

raw_data_wal_2324 <-
  openxlsx::read.xlsx(
    "Y:\\Official Stats\\Dental\\2023_24\\Data\\Workforce\\Old_Current_Extracts\\Wales\\Perfs_Wal_Current_2024.xlsx",
    sheet = "Sheet1"
  ) |>
  dplyr::mutate(FINANCIAL_YEAR = "2023/2024") |>
  dplyr::select(FINANCIAL_YEAR,
                Role,
                Performer.Id = Personal.Id) |>
  dplyr::filter(Role != "Foundation Dentist") |>
  dplyr::filter(Role != "Dental Care Professional")

combined_role_data_wal <- rbind(
  wal_roles_data,
  raw_data_wal_1920,
  raw_data_wal_2021,
  raw_data_wal_2122,
  raw_data_wal_2223,
  raw_data_wal_2324
)

#data manipulation -------------------------------------------------------------

#check if any foundation dentists left in combined wales role dataset

#join to combined data for wales on performer ID
#filter combined data to wales-only performers first

wal_raw_2324_distinct <- combined_data |>
  dplyr::filter(
    FINANCIALYEAR == "2023/2024"
    &
      NHSAREATEAMCODE %in% c("7A1", '7A2', '7A3', '7A4', '7A5', '7A6', '7A7')
    & (UOA > 0 | UDA > 0)
  ) |>
  dplyr::distinct(PERFORMER)

#1210 distinct performers in roles data
wal_roles_2324_distinct <- raw_data_wal_2324 |>
  dplyr::distinct(Performer.Id)

#1398 distinct performers in raw workforce data
#but performers may have multiple types of contract
#and raw data includes 192 rows of foundation dentists
wal_dents_2324_fd <- wal_dents_2324 |>
  dplyr::filter(FD == "Y")

#below code to exclude foundation dentists
#but this shouldn't need to be done in addition to previous
#filtering on roles data to remove foundation dentists?

#wal_dents_2324_no_fd <- wal_dents_2324 |>
#  dplyr::filter(FD %in% c(NA, "N"))

#age calculation function [from stack overflow]
#used as it accounts for leap years and gives argument for which date to calc to
age_calc = function(from, to) {
  from_lt = as.POSIXlt(from)
  to_lt = as.POSIXlt(to)
  
  age = to_lt$year - from_lt$year
  
  ifelse(
    to_lt$mon < from_lt$mon |
      (to_lt$mon == from_lt$mon & to_lt$mday < from_lt$mday),
    age - 1,
    age
  )
}

#test age function for age at 30th September 2023 (mid-year in fin year 23/24)
#spot checks done on ages gained from function and they're as expected
wal_age_test <- combined_data |>
  dplyr::filter(
    FINANCIALYEAR == "2023/2024"
    &
      NHSAREATEAMCODE %in% c("7A1", '7A2', '7A3', '7A4', '7A5', '7A6', '7A7')
    & (UOA > 0 | UDA > 0)
  ) |>
  dplyr::mutate(PERFORMERAGE = age_calc(from = PERFORMERDATEOFBIRTH,
                                        to = "2023/09/30"))

#check min and max ages to se if in sensible range
#min age 23 max age 80
wal_age_max <- wal_age_test |>
  dplyr::summarise(max(PERFORMERAGE))
wal_age_min <- wal_age_test |>
  dplyr::summarise(min(PERFORMERAGE))

wal_type_distinct <- combined_data |>
  dplyr::distinct(TYPEOFCONTRACT)

#add age column, TDS contract type, and contract type flags to welsh data 2023/24
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
    GDS_FLAG = case_when(TYPEOFCONTRACT == "GDS" ~ "Y",
                         TRUE ~ "N"),
    PDS_FLAG = case_when(
      TYPEOFCONTRACT == "PDS" ~ "Y",
      TYPEOFCONTRACT == "PDS Plus" ~ "Y",
      TRUE ~ "N"
    ),
    TDS_FLAG = case_when(TYPEOFCONTRACT == "TDS" ~ "Y",
                         TRUE ~ "N"),
    AGEGROUP = case_when(
      PERFORMERAGE <= 35 ~ "Under 35",
      PERFORMERAGE <= 44 ~ "35-44",
      PERFORMERAGE <= 54 ~ "45-54",
      PERFORMERAGE >= 55 ~ "55+",
      TRUE ~ as.character(PERFORMERAGE)
    )
  )

#class(wal_2324_workforce$PERFORMERAGE)

#wal_agegroup_distinct <- wal_2324_workforce |>
#  dplyr::distinct(AGEGROUP)

#1398 distinct performer numbers in workforce data
wal_perf_distinct <- wal_2324_workforce |>
  dplyr::distinct(PERFORMER)
#1210 distinct performer numbers in roles data
wal_role_distinct <- raw_data_wal_2324 |>
  dplyr::distinct(Performer.Id)

#try removing foundation dentists
#1281 rows
wal_perf_distinct_no_fd <- wal_2324_workforce |>
  dplyr::filter(FD %in% c(NA, "N")) |>
  dplyr::distinct(PERFORMER)

wal_2324_join <- wal_2324_workforce |>
  dplyr::filter(FD %in% c(NA, "N")) |>
  dplyr::left_join(raw_data_wal_2324, by = join_by(PERFORMER == Performer.Id))

#row 124 of x (workforce activity) matching multiple in y (roles)
#row 932 of y (roles) matching multiple in x (workforce activity)

#463 performer numbers with multiple rows
wal_wf_duplicate <- wal_2324_workforce |> 
  dplyr::filter(FD %in% c(NA, "N")) |>
  dplyr::group_by(PERFORMER) |>
  count() |> 
  dplyr::filter(n > 1)

#447 rows of performers in roles data w multiple activity rows
#443 distinct performers 
wal_wf_role_check <- wal_roles_2324 |>
  dplyr::filter(
    Role != "Foundation Dentist"
    & Role != "Dental Care Professional"
    & Performer.Id %in% c(wal_wf_duplicate$PERFORMER)) |>
  dplyr::group_by(Performer.Id) |>
  count() |> 
  dplyr::filter(n > 1)

wal_wf_duplicate_roles <- wal_2324_workforce |>
  dplyr::filter(PERFORMER %in% wal_wf_role_check$Performer.Id)

wal_wf_activity_check <- wal_2324_workforce |>
  dplyr::filter(FD %in% c(NA, "N")) |>
  
  