#functions for use in workforce_fact_data R script

#function to split data into list of individual datasets by treatment year
#and filter to only performers who had activity in that year

wf_year_split <- function(raw_data){
  
  wf_fact_year <- list()
  
  wf_fact_year$wf_1920 <- raw_data |>
    dplyr::filter(TREATMENT_YEAR == "2019/2020" & (UOA > 0 | UDA > 0))
  wf_fact_year$wf_2021 <- raw_data |>
    dplyr::filter(TREATMENT_YEAR == "2020/2021" & (UOA > 0 | UDA > 0))
  wf_fact_year$wf_2122 <- raw_data |>
    dplyr::filter(TREATMENT_YEAR == "2021/2022" & (UOA > 0 | UDA > 0))
  wf_fact_year$wf_2223 <- raw_data |>
    dplyr::filter(TREATMENT_YEAR == "2022/2023" & (UOA > 0 | UDA > 0))
  wf_fact_year$wf_2324 <- raw_data |>
    dplyr::filter(TREATMENT_YEAR == "2023/2024" & (UOA > 0 | UDA > 0))
  wf_fact_year$wf_2425 <- raw_data |>
    dplyr::filter(TREATMENT_YEAR == "2024/2025" & (UOA > 0 | UDA > 0))
    
    return(wf_fact_year)
    
}

# age calculation function [from stack overflow]

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

#functions to get unique performers in a year, filter to performers with activity
#in the year, calculate performer age and sum of activity 
#TO DO: amend function to take list inputs for data arguments, loop over list elements

#England national level
get_eng_wf <- function(roles_data_1yr,
                       roles_data_3yr,
                       active_perf_data){
  
  midyear_date <- paste0(paste(as.numeric(substr(active_perf_data$TREATMENT_YEAR, 1, 4)), "09/30", sep = "/"))
  
  active_workforce <- active_perf_data |>
    dplyr::mutate(PERFORMERAGE = as.numeric(age_calc(from = DATE_OF_BIRTH,
                                                     to = midyear_date))) |>
    dplyr::mutate(TYPEOFCONTRACT = case_when(PAID_BY_BSA == "N" ~ "TDS",
                                             TRUE ~ CONTRACT_TYPE)) |>
    dplyr::mutate(
      GDS_FLAG = case_when(TYPEOFCONTRACT == "GDS" ~ 1,
                           TRUE ~ 0),
      PDS_FLAG = case_when(TYPEOFCONTRACT == "PDS" ~ 1,
                           TYPEOFCONTRACT == "PDS Plus" ~ 1,
                           TRUE ~ 0),
      TDS_FLAG = case_when(TYPEOFCONTRACT == "TDS" ~ 1,
                           TRUE ~ 0),
      AGEGROUP = case_when(
        PERFORMERAGE <= 34 ~ "Under 35",
        PERFORMERAGE <= 44 ~ "35-44",
        PERFORMERAGE <= 54 ~ "45-54",
        PERFORMERAGE >= 55 ~ "55+",
        TRUE ~ as.character(PERFORMERAGE)
      )
    ) |>
    dplyr::group_by(
      TREATMENT_YEAR,
      GENDER,
      GDC_NUMBER,
      LTST_COMM_CODE,
      LTST_COMM_NAME,
      PERFORMER_NUMBER,
      TYPEOFCONTRACT,
#      FOUNDATION_DENTIST,
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
  
  eng_workforce_roles <- active_workforce |>
    dplyr::left_join(
      select(roles_data_1yr, Performer.Id, Role),
      by = join_by(PERFORMER_NUMBER == Performer.Id)
    ) |>
#    dplyr::mutate(Role = case_when(
#      (is.na(Role) & FOUNDATION_DENTIST == 'Y') ~ "Foundation Dentist",
#       TRUE ~ Role)) |>
    dplyr::left_join(
      select(roles_data_3yr, Performer.Id, Role),
      by = join_by(PERFORMER_NUMBER == Performer.Id)
    ) |>
    dplyr::mutate(Role = coalesce(Role.x, Role.y)) |>
    dplyr::select(-c(Role.x, Role.y))
  
  eng_wf_ICB <- eng_workforce_roles |>
    dplyr::group_by(
      TREATMENT_YEAR,
      PERFORMER_NUMBER,
      GENDER,
      GDC_NUMBER,
      LTST_COMM_CODE,
      LTST_COMM_NAME,
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
        Role == "Dental Care Professional" ~ "Dental Care Professional",
        TRUE ~ "Unknown"
      )
    )
  
  eng_wf <- list()
  
  eng_wf$nat_output <- eng_workforce_roles |>
    dplyr::group_by(
      TREATMENT_YEAR,
      PERFORMER_NUMBER,
      GENDER,
      GDC_NUMBER,
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
        Role == "Dental Care Professional" ~ "Dental Care Professional",
        TRUE ~ "Unknown"
      )
    ) |> 
    dplyr::select(Year = TREATMENT_YEAR,
                  PerformerNumber = PERFORMER_NUMBER,
                  PerformerGDCRegistrationNumber = GDC_NUMBER,
                  ContractType = CONTRACT_TYPE,
                  AgeGroup = AGEGROUP,
                  PerformerGender = GENDER,
                  DentistType = DENTIST_TYPE)
  
  eng_wf$ICB_output <- eng_wf_ICB |>
    dplyr::select(
      Year = TREATMENT_YEAR,
      ICB_Code = LTST_COMM_CODE,
      ICB_NAME = LTST_COMM_NAME,
      PerformerNumber = PERFORMER_NUMBER,
      PerformerGDCRegistrationNumber = GDC_NUMBER,
      ContractType = CONTRACT_TYPE,
      AgeGroup = AGEGROUP,
      PerformerGender = GENDER,
      DentistType = DENTIST_TYPE
    )
  
  return(eng_wf)
  
}

#Wales national level
get_wal_wf <- function(roles_data_1yr,
                       roles_data_3yr,
                       active_perf_data){
  
  midyear_date <- paste0(paste(as.numeric(substr(active_perf_data$TREATMENT_YEAR, 1, 4)), "09/30", sep = "/"))
  
  active_workforce <- active_perf_data |>
    dplyr::mutate(PERFORMERAGE = as.numeric(age_calc(from = DATE_OF_BIRTH,
                                                     to = midyear_date))) |>
    dplyr::mutate(TYPEOFCONTRACT = case_when(PAID_BY_BSA == "N" ~ "TDS",
                                             TRUE ~ CONTRACT_TYPE)) |>
    dplyr::mutate(
      GDS_FLAG = case_when(TYPEOFCONTRACT == "GDS" ~ 1,
                           TRUE ~ 0),
      PDS_FLAG = case_when(TYPEOFCONTRACT == "PDS" ~ 1,
                           TYPEOFCONTRACT == "PDS Plus" ~ 1,
                           TRUE ~ 0),
      TDS_FLAG = case_when(TYPEOFCONTRACT == "TDS" ~ 1,
                           TRUE ~ 0),
      AGEGROUP = case_when(
        PERFORMERAGE <= 34 ~ "Under 35",
        PERFORMERAGE <= 44 ~ "35-44",
        PERFORMERAGE <= 54 ~ "45-54",
        PERFORMERAGE >= 55 ~ "55+",
        TRUE ~ as.character(PERFORMERAGE)
      )
    ) |>
    dplyr::group_by(
      TREATMENT_YEAR,
      GENDER,
      GDC_NUMBER,
      COMMISSIONER_CODE,
      PERFORMER_NUMBER,
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
  
  wal_workforce_roles <- active_workforce |>
    dplyr::left_join(
      select(roles_data_1yr, Performer.Id, Role),
      by = join_by(PERFORMER_NUMBER == Performer.Id)
    ) |>
    dplyr::left_join(
      select(roles_data_3yr, Performer.Id, Role),
      by = join_by(PERFORMER_NUMBER == Performer.Id)
    ) |>
    dplyr::mutate(Role = coalesce(Role.x, Role.y)) |>
    dplyr::select(-c(Role.x, Role.y))
  
  wal_wf_LHB <- wal_workforce_roles |>
    dplyr::group_by(
      TREATMENT_YEAR,
      PERFORMER_NUMBER,
      GENDER,
      GDC_NUMBER,
      COMMISSIONER_CODE,
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
        Role == "Dental Care Professional" ~ "Dental Care Professional",
        TRUE ~ "Unknown"
      )
    )
  
  wal_wf <- list()
  
  wal_wf$nat_output <- wal_workforce_roles |>
    dplyr::group_by(
      TREATMENT_YEAR,
      PERFORMER_NUMBER,
      GENDER,
      GDC_NUMBER,
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
        Role == "Dental Care Professional" ~ "Dental Care Professional",
        TRUE ~ "Unknown"
      )
    ) |> 
    dplyr::select(Year = TREATMENT_YEAR,
                  PerformerNumber = PERFORMER_NUMBER,
                  PerformerGDCRegistrationNumber = GDC_NUMBER,
                  ContractType = CONTRACT_TYPE,
                  AgeGroup = AGEGROUP,
                  PerformerGender = GENDER,
                  DentistType = DENTIST_TYPE)
  
  wal_wf$LHB_output <- wal_wf_LHB |>
    dplyr::select(
      Year = TREATMENT_YEAR,
      LHB_Code = COMMISSIONER_CODE,
      PerformerNumber = PERFORMER_NUMBER,
      PerformerGDCRegistrationNumber = GDC_NUMBER,
      ContractType = CONTRACT_TYPE,
      AgeGroup = AGEGROUP,
      PerformerGender = GENDER,
      DentistType = DENTIST_TYPE
    )
  
  return(wal_wf)
  
}

#England sub-ICB level
get_eng_wf_sicbl <- function(roles_data_1yr,
                             roles_data_3yr,
                             active_perf_data){
  
  midyear_date <- paste0(paste(as.numeric(substr(active_perf_data$TREATMENT_YEAR, 1, 4)), "09/30", sep = "/"))
  
  active_workforce <- active_perf_data |>
    dplyr::mutate(PERFORMERAGE = as.numeric(age_calc(from = DATE_OF_BIRTH,
                                                     to = midyear_date))) |>
    dplyr::mutate(TYPEOFCONTRACT = case_when(PAID_BY_BSA == "N" ~ "TDS",
                                             TRUE ~ CONTRACT_TYPE)) |>
    dplyr::mutate(
      GDS_FLAG = case_when(TYPEOFCONTRACT == "GDS" ~ 1,
                           TRUE ~ 0),
      PDS_FLAG = case_when(TYPEOFCONTRACT == "PDS" ~ 1,
                           TYPEOFCONTRACT == "PDS Plus" ~ 1,
                           TRUE ~ 0),
      TDS_FLAG = case_when(TYPEOFCONTRACT == "TDS" ~ 1,
                           TRUE ~ 0),
      AGEGROUP = case_when(
        PERFORMERAGE <= 34 ~ "Under 35",
        PERFORMERAGE <= 44 ~ "35-44",
        PERFORMERAGE <= 54 ~ "45-54",
        PERFORMERAGE >= 55 ~ "55+",
        TRUE ~ as.character(PERFORMERAGE)
      )
    ) |>
    dplyr::group_by(
      TREATMENT_YEAR,
      GENDER,
      GDC_NUMBER,
      CCG_CODE,
      PERFORMER_NUMBER,
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
  
  eng_workforce_roles <- active_workforce |>
    dplyr::left_join(
      select(roles_data_1yr, Performer.Id, Role),
      by = join_by(PERFORMER_NUMBER == Performer.Id)
    ) |>
    dplyr::left_join(
      select(roles_data_3yr, Performer.Id, Role),
      by = join_by(PERFORMER_NUMBER == Performer.Id)
    ) |>
    dplyr::mutate(Role = coalesce(Role.x, Role.y)) |>
    dplyr::select(-c(Role.x, Role.y))
  
  eng_wf_SICBL <- eng_workforce_roles |>
    dplyr::group_by(
      TREATMENT_YEAR,
      PERFORMER_NUMBER,
      GENDER,
      GDC_NUMBER,
      CCG_CODE,
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
        Role == "Dental Care Professional" ~ "Dental Care Professional",
        TRUE ~ "Unknown"
      )
    )
  
  eng_wf <- list()
  
  eng_wf$nat_output <- eng_workforce_roles |>
    dplyr::group_by(
      TREATMENT_YEAR,
      PERFORMER_NUMBER,
      GENDER,
      GDC_NUMBER,
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
        Role == "Dental Care Professional" ~ "Dental Care Professional",
        TRUE ~ "Unknown"
      )
    ) |> 
    dplyr::select(Year = TREATMENT_YEAR,
                  PerformerNumber = PERFORMER_NUMBER,
                  PerformerGDCRegistrationNumber = GDC_NUMBER,
                  ContractType = CONTRACT_TYPE,
                  AgeGroup = AGEGROUP,
                  PerformerGender = GENDER,
                  DentistType = DENTIST_TYPE)
  
  eng_wf$SICBL_output <- eng_wf_SICBL |>
    dplyr::select(
      Year = TREATMENT_YEAR,
      SICBL_Code = CCG_CODE,
      PerformerNumber = PERFORMER_NUMBER,
      PerformerGDCRegistrationNumber = GDC_NUMBER,
      ContractType = CONTRACT_TYPE,
      AgeGroup = AGEGROUP,
      PerformerGender = GENDER,
      DentistType = DENTIST_TYPE
    )
  
  return(eng_wf)
  
}


#function to get joiners and leavers at national level
#TO DO: calculate year and start date for joiners and leavers
#from year in prev_year_wf table name instead of specifying as arguments

get_nat_joiners_leavers <- function(prev_year_wf,
                        current_year_wf,
                        year_start_date_join,
                        year_start_date_leave){
  
  names(prev_year_wf)[2] <- "Performer"
  names(current_year_wf)[2] <- "Performer"
  joiners_wal <- anti_join(current_year_wf, prev_year_wf, by = "Performer")
  joiners_wal$Year_Start_Date <- year_start_date_join
  joiners_wal$Year <- NULL
  joiners_wal$Joiners_Leavers <- "Joiners"
  joiners_wal <- joiners_wal[,c(7,1,2,3,5,4,6,8)]
  names(joiners_wal)[2] <- "PerformerNumber"
  
  leavers_wal <- anti_join(prev_year_wf, current_year_wf, by= "Performer")
  leavers_wal$Year_Start_Date <- year_start_date_leave
  leavers_wal$Year <- NULL
  leavers_wal$Joiners_Leavers <- "Leavers"
  leavers_wal <- leavers_wal[,c(7,1,2,3,5,4,6,8)]
  names(leavers_wal)[2] <- "PerformerNumber"
  
  nat_joiners_leavers <- list()
  nat_joiners_leavers$joiners <- joiners_wal
  nat_joiners_leavers$leavers <- leavers_wal
  
  return(nat_joiners_leavers)
  
}

get_icb_joiners_leavers <- function(prev_year_wf_icb,
                                    current_year_wf_icb,
                                    year_start_date_join,
                                    year_start_date_leave){
  
  names(current_year_wf_icb)[4] <- "Performer"
  names(prev_year_wf_icb)[4] <- "Performer"
  joiners_icb_codes <-  anti_join(current_year_wf_icb, prev_year_wf_icb, by= "Performer")
  joiners_icb_codes$Year_Start_Date <- year_start_date_join
  joiners_icb_codes$Year <- NULL
  joiners_icb_codes$Joiners_Leavers <- "Joiners"
  joiners_icb_codes <- joiners_icb_codes[,c(9,1,2,3,4,6,5,7,8)]
  names(joiners_icb_codes)[4] <- "PerformerNumber"
  
  leavers_icb_codes <-  anti_join(prev_year_wf_icb, current_year_wf_icb, by= c("Performer"))
  leavers_icb_codes <- filter(leavers_icb_codes, !is.na(Performer))
  leavers_icb_codes$Year_Start_Date <- year_start_date_leave
  leavers_icb_codes$Year <- NULL
  leavers_icb_codes$Joiners_Leavers <- "Leavers"
  leavers_icb_codes <- leavers_icb_codes[,c(9,1,2,3,4,6,5,7,8)]
  names(leavers_icb_codes)[4] <- "PerformerNumber"
  
  icb_joiners_leavers <- list()
  icb_joiners_leavers$joiners <- joiners_icb_codes
  icb_joiners_leavers$leavers <- leavers_icb_codes
  
  return(icb_joiners_leavers)
  
}

get_region_joiners_leavers <- function(prev_year_wf_reg,
                                       current_year_wf_reg,
                                       year_start_date_join,
                                       year_start_date_leave){
  
  names(current_year_wf_reg)[5] <- "Performer"
  names(prev_year_wf_reg)[5] <- "Performer"
  joiners_reg_codes <-  anti_join(current_year_wf_reg, prev_year_wf_reg, by= "Performer")
  joiners_reg_codes$Year_Start_Date <- year_start_date_join
  joiners_reg_codes$Year <- NULL
  joiners_reg_codes$Joiners_Leavers <- "Joiners"
  joiners_reg_codes <- joiners_reg_codes[,c(9,1,2,3,4,6,5,7,8)]
  names(joiners_reg_codes)[5] <- "PerformerNumber"
  
  leavers_reg_codes <-  anti_join(prev_year_wf_reg, current_year_wf_reg, by= c("Performer"))
  leavers_reg_codes <- filter(leavers_reg_codes, !is.na(Performer))
  leavers_reg_codes$Year_Start_Date <- year_start_date_leave
  leavers_reg_codes$Year <- NULL
  leavers_reg_codes$Joiners_Leavers <- "Leavers"
  leavers_reg_codes <- leavers_reg_codes[,c(9,1,2,3,4,6,5,7,8)]
  names(leavers_reg_codes)[5] <- "PerformerNumber"
  
  reg_joiners_leavers <- list()
  reg_joiners_leavers$joiners <- joiners_reg_codes
  reg_joiners_leavers$leavers <- leavers_reg_codes
  
  return(reg_joiners_leavers)
  
}

get_sicbl_joiners_leavers <- function(prev_year_wf_sicbl,
                                      current_year_wf_sicbl,
                                      year_start_date_join,
                                      year_start_date_leave){
  
  names(current_year_wf_sicbl)[3] <- "Performer"
  names(prev_year_wf_sicbl)[3] <- "Performer"
  joiners_eng_codes <-  anti_join(current_year_wf_sicbl, prev_year_wf_sicbl, by = "Performer")
  joiners_eng_codes$Year_Start_Date <- year_start_date_join
  joiners_eng_codes$Year <- NULL
  joiners_eng_codes$Joiners_Leavers <- "Joiners"
  joiners_eng_codes <- joiners_eng_codes[,c(8,1,2,3,4,6,5,7,9)]
  names(joiners_eng_codes)[3] <- "PerformerNumber"
  
  leavers_eng_codes <-  anti_join(prev_year_wf_sicbl, current_year_wf_sicbl, by = c("Performer"))
  leavers_eng_codes <- filter(leavers_eng_codes, !is.na(Performer))
  leavers_eng_codes$Year_Start_Date <- year_start_date_leave
  leavers_eng_codes$Year <- NULL
  leavers_eng_codes$Joiners_Leavers <- "Leavers"
  leavers_eng_codes <- leavers_eng_codes[,c(8,1,2,3,4,6,5,7,9)]
  names(leavers_eng_codes)[3] <- "PerformerNumber"
  
  sicbl_joiners_leavers <- list()
  sicbl_joiners_leavers$joiners <- joiners_eng_codes
  sicbl_joiners_leavers$leavers <- leavers_eng_codes
  
  return(sicbl_joiners_leavers)
  
}

#function to get joiners and leavers at Wales Local Health Board (LHB) level
#TO DO: calculate year and start date for joiners and leavers
#from year in prev_year_wf table name instead of specifying as arguments

get_lhb_joiners_leavers <- function(prev_year_wf_lhb,
                                    current_year_wf_lhb,
                                    year_start_date_join,
                                    year_start_date_leave){
  
  names(current_year_wf_lhb)[3] <- "Performer"
  names(prev_year_wf_lhb)[3] <- "Performer"
  joiners_wales_codes <-  anti_join(current_year_wf_lhb, prev_year_wf_lhb, by= "Performer")
  joiners_wales_codes$Year_Start_Date <- year_start_date_join
  joiners_wales_codes$Year <- NULL
  joiners_wales_codes$Joiners_Leavers <- "Joiners"
  joiners_wales_codes <- joiners_wales_codes[,c(8,1,2,3,4,6,5,7,9)]
  names(joiners_wales_codes)[3] <- "PerformerNumber"
  
  leavers_wales_codes <-  anti_join(prev_year_wf_lhb, current_year_wf_lhb, by= c("Performer"))
  leavers_wales_codes <- filter(leavers_wales_codes, !is.na(Performer))
  leavers_wales_codes$Year_Start_Date <- year_start_date_leave
  leavers_wales_codes$Year <- NULL
  leavers_wales_codes$Joiners_Leavers <- "Leavers"
  leavers_wales_codes <- leavers_wales_codes[,c(8,1,2,3,4,6,5,7,9)]
  names(leavers_wales_codes)[3] <- "PerformerNumber"
  
  lhb_joiners_leavers <- list()
  lhb_joiners_leavers$joiners <- joiners_wales_codes
  lhb_joiners_leavers$leavers <- leavers_wales_codes
  
  return(lhb_joiners_leavers)
  
}

# functions to aggregate and format data into tables

get_table_1a <- function(year_list,
                         fin_year){
  
  year_nat <- year_list$active_performers$nat_output |>
    dplyr::group_by(`Year`) |>
    dplyr::summarise(Dentists = n_distinct(PerformerNumber)) |>
    ungroup()
  
  year_joiners <- year_list$nat_joiners_leavers$joiners |>
    dplyr::group_by(Year_Start_Date) |>
    dplyr::summarise(Joiners = n_distinct(PerformerNumber)) |>
    ungroup() |>
    dplyr::mutate(`Year` = fin_year) |>
    dplyr::select(-(Year_Start_Date))
  
  year_leavers <- year_list$nat_joiners_leavers$leavers |>
    dplyr::group_by(Year_Start_Date) |>
    dplyr::summarise(Leavers = n_distinct(PerformerNumber)) |>
    ungroup() |>
    dplyr::mutate(`Year` = fin_year) |>
    dplyr::select(-(Year_Start_Date))
  
  nat_wf <- year_nat |>
    dplyr::left_join(year_joiners, by = c("Year")) |>
    dplyr::left_join(year_leavers, by = c("Year"))
  
  return(nat_wf)
}

get_table_1b <- function(year_data,
                         fin_year){
  
  type_nat <- year_data$active_performers$nat_output |>
    dplyr::mutate(DentistType = case_when(DentistType == "PP" ~ "Provider/Performer",
                                          DentistType == "PO" ~ "Associates",
                                          DentistType == "Foundation Dentist" ~ "Associates",
                                          TRUE ~ DentistType)) |>
    dplyr::group_by(Year, DentistType, ContractType) |>
    dplyr::summarise(Dentists = n_distinct(PerformerNumber)) |>
    ungroup()
  
  contract_totals <- type_nat |>
    group_by(ContractType) |>
    summarise(Dentists = sum(Dentists)) |>
    ungroup() |>
    dplyr::mutate(`Year` = fin_year)
  
  type_nat <- type_nat |>
    add_row(contract_totals)
  
  type_totals <- type_nat |>
    group_by(DentistType) |>
    summarise(Dentists = sum(Dentists)) |>
    ungroup() |>
    dplyr::mutate(`Year` = fin_year)
  
  type_nat <- type_nat |>
    add_row(type_totals) |>
    replace_na(list(DentistType = "All", ContractType = "All")) |>
    dplyr::arrange(DentistType, ContractType)
  
  return(type_nat)
  
}

get_table_1c <- function(year_data,
                         fin_year){
  
  agegen_nat <- year_data$active_performers$nat_output |>
    dplyr::group_by(Year, AgeGroup, PerformerGender) |>
    dplyr::summarise(Dentists = n_distinct(PerformerNumber)) |>
    ungroup()
  
  gen_totals <- agegen_nat |>
    group_by(PerformerGender) |>
    summarise(Dentists = sum(Dentists)) |>
    ungroup() |>
    dplyr::mutate(`Year` = fin_year)
  
  agegen_nat <- agegen_nat |>
    add_row(gen_totals)
  
  age_totals <- agegen_nat |>
    group_by(AgeGroup) |>
    summarise(Dentists = sum(Dentists)) |>
    ungroup() |>
    dplyr::mutate(`Year` = fin_year)
  
  agegen_nat <- agegen_nat |>
    add_row(age_totals) |>
    replace_na(list(AgeGroup = "All", PerformerGender = "All")) |>
    dplyr::arrange(AgeGroup, PerformerGender)
  
  return(agegen_nat)
  
}

#may need to change population dataset name, if named differently in pipeline
get_table_2b_icb <- function(year_data){
  
  icb_totals <- year_data$active_performers$ICB_output |>
    dplyr::group_by(Year, ICB_Code) |>
    dplyr::summarise(Dentists = n_distinct(PerformerNumber)) |>
    ungroup()
  
  icb_pop_dentists <- icb_totals |>
    dplyr::left_join(icb_lookup_distinct, by = c("ICB_Code" = "ICB23CDH")) |>
    dplyr::left_join(icb_pop_fill, by = c("Year" = "FINANCIAL_YEAR", "ICB23CD" = "ICB_CODE")) |>
    dplyr::mutate(`Population per dentist` = (POPULATION / Dentists),
                  `Dentists per 100,000 population` = (Dentists / (POPULATION / 100000))) |>
    dplyr::select(`Financial year` = Year,
                  `ODS code` = ICB_Code,
                  `ONS code` = ICB23CD,
                  `Area name` = ICB23NM,
                  Dentists,
                  `Mid-year population year` = CALENDAR_YEAR,
                  Population = POPULATION,
                  `Population per dentist`,
                  `Dentists per 100,000 population`)
  
  return(icb_pop_dentists)
  
}  

#may need to change population dataset name, if named differently in pipeline
get_table_2b_region <- function(year_data){
  
  
  region_totals <- year_data$active_performers$ICB_output |>
    dplyr::left_join(icb_lookup, by = c("ICB_Code" = "ICB23CDH")) |>
    dplyr::group_by(Year,
                    NHSER23CDH,
                    NHSER23CD,
                    NHSER23NM) |>
    dplyr::summarise(Dentists = n_distinct(PerformerNumber)) |>
    ungroup() |>
    dplyr::left_join(nhser_pop_fill, by = c("NHSER23CD" = "NHSER_CODE",
                                            "Year" = "FINANCIAL_YEAR")) |>
    replace_na(list(NHSER23CDH = "Unknown", NHSER23CD = "Unknown", NHSER23NM = "Unknown")) |>
    dplyr::mutate(`Population per dentist` = (POPULATION / Dentists),
                  `Dentists per 100,000 population` = (Dentists / (POPULATION / 100000))) |>
    dplyr::select(`Financial year` = Year,
                  `ODS code` = NHSER23CDH,
                  `ONS code` = NHSER23CD,
                  `Area name` = NHSER23NM,
                  Dentists,
                  `Mid-year population year` = CALENDAR_YEAR,
                  Population = POPULATION,
                  `Population per dentist`,
                  `Dentists per 100,000 population`)
  
  return(region_totals)
  
}

get_table_2c_icb <- function(year_list,
                             fin_year){
  
  year_icb <- year_list$active_performers$ICB_output |>
    dplyr::group_by(Year, ICB_Code) |>
    dplyr::summarise(Total_dentists = n_distinct(PerformerNumber)) |>
    ungroup() |>
    dplyr::rename(`Financial year` = Year)
  
  icb_names_data <- table_2b_wf |>
    dplyr::select(`Financial year`, `ODS code`, `ONS code`, `Area name`)
  
  year_joiners <- year_list$icb_joiners_leavers$joiners |>
    dplyr::group_by(Year_Start_Date, ICB_Code) |>
    dplyr::summarise(Joiners = n_distinct(PerformerNumber)) |>
    ungroup() |>
    dplyr::mutate(`Financial year` = fin_year) |>
    dplyr::select(-(Year_Start_Date))
  
  year_leavers <- year_list$icb_joiners_leavers$leavers |>
    dplyr::group_by(Year_Start_Date, ICB_Code) |>
    dplyr::summarise(Leavers = n_distinct(PerformerNumber)) |>
    ungroup() |>
    dplyr::mutate(`Financial year` = fin_year) |>
    dplyr::select(-(Year_Start_Date))
  
  icb_wf <- year_icb |>
    dplyr::left_join(year_joiners, by = c("Financial year" = "Financial year",
                                          "ICB_Code" = "ICB_Code")) |>
    dplyr::left_join(year_leavers, by = c("Financial year" = "Financial year",
                                          "ICB_Code" = "ICB_Code")) |>
    tidyr::pivot_longer(cols = c("Joiners", "Leavers"), 
                        names_to = "Workforce_type",
                        values_to = "Number_of_dentists") |>
    dplyr::left_join(icb_names_data, by = c("Financial year" = "Financial year", 
                                            "ICB_Code" = "ODS code")) |>
    dplyr::select(`Financial year`,
                  `ONS code`,
                  `ODS code` = ICB_Code,
                  `Area name`,
                  `Total dentists` = Total_dentists,
                  `Workforce type` = Workforce_type,
                  `Number of dentists of type` = Number_of_dentists) |>
    dplyr::mutate(`Percentage of total dentists` = ((`Number of dentists of type`/ `Total dentists`)*100))
  
  return(icb_wf)
  
}

get_table_2c_region <- function(year_list,
                                fin_year){
  
  region_lookup <- icb_lookup |>
    dplyr::select(ICB23CDH, NHSER23CD, NHSER23CDH, NHSER23NM)
  
  year_region <- year_list$active_performers$ICB_output |>
    dplyr::left_join(region_lookup, by = c("ICB_Code" = "ICB23CDH")) |>
    dplyr::group_by(Year, NHSER23CD, NHSER23CDH, NHSER23NM) |>
    dplyr::summarise(Total_dentists = n_distinct(PerformerNumber)) |>
    ungroup() |>
    dplyr::rename(`Financial year` = Year)
  
  year_joiners <- year_list$icb_joiners_leavers$joiners |>
    dplyr::mutate(`Financial year` = fin_year) |>
    dplyr::left_join(region_lookup, by = c("ICB_Code" = "ICB23CDH")) |>
    dplyr::group_by(Year_Start_Date, NHSER23CD, NHSER23CDH, NHSER23NM) |>
    dplyr::summarise(Joiners = n_distinct(PerformerNumber)) |>
    ungroup() |>
    dplyr::mutate(`Financial year` = fin_year) |>
    dplyr::select(-(Year_Start_Date))
  
  year_leavers <- year_list$icb_joiners_leavers$leavers |>
    dplyr::mutate(`Financial year` = fin_year) |>
    dplyr::left_join(region_lookup, by = c("ICB_Code" = "ICB23CDH")) |>
    dplyr::group_by(Year_Start_Date, NHSER23CD, NHSER23CDH, NHSER23NM) |> 
    dplyr::summarise(Leavers = n_distinct(PerformerNumber)) |>
    ungroup() |>
    dplyr::mutate(`Financial year` = fin_year) |>
    dplyr::select(-(Year_Start_Date))
  
  region_wf <- year_region |>
    dplyr::left_join(year_joiners, by = c("Financial year" = "Financial year",
                                          "NHSER23CDH" = "NHSER23CDH")) |>
    dplyr::left_join(year_leavers, by = c("Financial year" = "Financial year",
                                          "NHSER23CDH" = "NHSER23CDH")) |>
    tidyr::pivot_longer(cols = c("Joiners", "Leavers"), 
                        names_to = "Workforce_type",
                        values_to = "Number_of_dentists") |>
    dplyr::select(`Financial year`,
                  `ONS code` = NHSER23CD,
                  `ODS code` = NHSER23CDH,
                  `Area name` = NHSER23NM,
                  `Total dentists` = Total_dentists,
                  `Workforce type` = Workforce_type,
                  `Number of dentists of type` = Number_of_dentists) |>
    dplyr::mutate(`Percentage of total dentists` = ((`Number of dentists of type`/ `Total dentists`)*100))
  
  return(region_wf)
  
}

get_table_2d <- function(year_data){
  
  sicbl_totals <- year_data$sicbl_performers$SICBL_output |>
    dplyr::left_join(nhs_lookups$region_23, by = c("SICBL_Code" = "SICBL23CDH")) |>
    dplyr::group_by(Year, 
                    SICBL23CD,
                    SICBL_Code,
                    SICBL23NM) |>
    dplyr::summarise(Dentists = n_distinct(PerformerNumber)) |>
    ungroup()
  
  sicbl_pop_dentists <- sicbl_totals |>
    dplyr::left_join(sicbl_pop_fill, by = c("Year" = "FINANCIAL_YEAR", "SICBL23CD" = "SICBL_CODE")) |>
    replace_na(list(SICBL_Code = "Unknown", SICBL23CD = "Unknown", SICBL23NM = "Unknown", 
                    ICBCD = "Unknown", ICBCDH = "Unknown", ICBNM = "Unknown")) |>
    dplyr::mutate(`Population per dentist` = (POPULATION / Dentists),
                  `Dentists per 100,000 population` = (Dentists / (POPULATION / 100000))) |>
    dplyr::select(`Financial year` = Year,
                  `ONS code` = SICBL23CD,
                  `ODS code` = SICBL_Code,
                  `SICBL name` = SICBL23NM,
                  Dentists,
                  `Mid-year population year` = CALENDAR_YEAR,
                  Population = POPULATION,
                  `Population per dentist`,
                  `Dentists per 100,000 population`)
  
  return(sicbl_pop_dentists)
  
}  

get_table_2e <- function(year_list,
                         fin_year){
  
  year_sicbl <- year_list$sicbl_performers$SICBL_output |>
    dplyr::group_by(`Year`, SICBL_Code) |>
    dplyr::summarise(Total_dentists = n_distinct(PerformerNumber)) |>
    ungroup() |>
    dplyr::rename(`Financial year` = Year)
  
  sicbl_names_data <- table_2d_wf |>
    dplyr::select(`Financial year`, `ODS code`, `ONS code`, `SICBL name`)
  
  year_joiners <- year_list$sicbl_joiners_leavers$joiners |>
    dplyr::group_by(Year_Start_Date, SICBL_Code) |>
    dplyr::summarise(Joiners = n_distinct(PerformerNumber)) |>
    ungroup() |>
    dplyr::mutate(`Financial year` = fin_year) |>
    dplyr::select(-(Year_Start_Date))
  
  year_leavers <- year_list$sicbl_joiners_leavers$leavers |>
    dplyr::group_by(Year_Start_Date, SICBL_Code) |>
    dplyr::summarise(Leavers = n_distinct(PerformerNumber)) |>
    ungroup() |>
    dplyr::mutate(`Financial year` = fin_year) |>
    dplyr::select(-(Year_Start_Date))
  
  sicbl_wf <- year_sicbl |>
    dplyr::left_join(year_joiners, by = c("Financial year" = "Financial year",
                                          "SICBL_Code" = "SICBL_Code")) |>
    dplyr::left_join(year_leavers, by = c("Financial year" = "Financial year",
                                          "SICBL_Code" = "SICBL_Code")) |>
    tidyr::pivot_longer(cols = c("Joiners", "Leavers"), 
                        names_to = "Workforce_type",
                        values_to = "Number_of_dentists") |>
    dplyr::left_join(sicbl_names_data, by = c("Financial year" = "Financial year", 
                                              "SICBL_Code" = "ODS code")) |>
    dplyr::select(`Financial year`,
                  `ONS code`,
                  `ODS code` = SICBL_Code,
                  `SICBL name`,
                  `Total dentists` = Total_dentists,
                  `Workforce type` = Workforce_type,
                  `Number of dentists of type` = Number_of_dentists) |>
    replace_na(list(`ONS code` = "Unknown", `ODS code` = "Unknown", `SICBL name` = "Unknown")) |>
    dplyr::mutate(`Percentage of total dentists` = ((`Number of dentists of type`/ `Total dentists`)*100))
  
  return(sicbl_wf)
  
}

#function to write Wales performer datasets to xlsx file output

write_wf_xlsx <- function(year_data_list,
                          wf_file_name){
  
  wal_datasets_year <- list("WALES" = year_data_list$active_performers$nat_output,
                            "LHB" = year_data_list$active_performers$LHB_output,
                            "WALES_Joiners" = year_data_list$nat_joiners_leavers$joiners,
                            "WALES_Leavers" = year_data_list$nat_joiners_leavers$leavers,
                            "LHB_Joiners" = year_data_list$lhb_joiners_leavers$joiners,
                            "LHB_Leavers" = year_data_list$lhb_joiners_leavers$leavers) 
  
  openxlsx::write.xlsx(wal_datasets_year, file = wf_file_name)
  
}

#functions to aggregate data for CSV outputs by area 
get_wf_csv_icb <- function(year_data){
  
  icb_csv_totals <- year_data$active_performers$ICB_output |>
    dplyr::mutate(DentistType = case_when(DentistType == "PP" ~ "Provider/Performer",
                                          DentistType == "PO" ~ "Associates",
                                          DentistType == "Foundation Dentist" ~ "Associates",
                                          TRUE ~ DentistType)) |>
    dplyr::group_by(Year, ICB_Code, ICB_NAME, ContractType, AgeGroup, PerformerGender, DentistType) |>
    dplyr::summarise(DentistCount = n_distinct(PerformerNumber)) |>
    ungroup()
  
  #lookup already created in pipeline
  # icb_lookup_distinct <- lookups_list$region_23 |>
  #   select(ICB23CDH, ICB23CD, ICB23NM) |>
  #   distinct(ICB23CDH, ICB23CD, ICB23NM)
  
  icb_csv_dentists <- icb_csv_totals |>
    dplyr::left_join(icb_lookup_distinct, by = c("ICB_Code" = "ICB23CDH")) |>
    dplyr::mutate(GEOG_TYPE = "ICB") |>
    dplyr::select(FINANCIAL_YEAR = Year,
                  GEOG_TYPE,
                  GEOG_ODS_CODE = ICB_Code,
                  GEOG_ONS_CODE = ICB23CD,
                  GEOG_NAME = ICB23NM,
                  CONTRACT_TYPE = ContractType,
                  AGE_GROUP = AgeGroup,
                  GENDER = PerformerGender,
                  DENTIST_TYPE = DentistType,
                  DENTIST_COUNT = DentistCount)
  
  return(icb_csv_dentists)
  
}

get_wf_csv_sicbl <- function(year_data){
  
  sicbl_csv_totals <- year_data$sicbl_performers$SICBL_output |>
    dplyr::mutate(DentistType = case_when(DentistType == "PP" ~ "Provider/Performer",
                                          DentistType == "PO" ~ "Associates",
                                          DentistType == "Foundation Dentist" ~ "Associates",
                                          TRUE ~ DentistType)) |>
    dplyr::group_by(Year, SICBL_Code, ContractType, AgeGroup, PerformerGender, DentistType) |>
    dplyr::summarise(DentistCount = n_distinct(PerformerNumber)) |>
    ungroup()
  
  sicbl_lookup_distinct <- nhs_lookups$region_23 |>
    select(SICBL23CDH, SICBL23CD, SICBL23NM) |>
    distinct(SICBL23CDH, SICBL23CD, SICBL23NM)
  
  sicbl_csv_dentists <- sicbl_csv_totals |>
    dplyr::left_join(sicbl_lookup_distinct, by = c("SICBL_Code" = "SICBL23CDH")) |>
    dplyr::mutate(GEOG_TYPE = "SICBL") |>
    dplyr::select(FINANCIAL_YEAR = Year,
                  GEOG_TYPE,
                  GEOG_ODS_CODE = SICBL_Code,
                  GEOG_ONS_CODE = SICBL23CD,
                  GEOG_NAME = SICBL23NM,
                  CONTRACT_TYPE = ContractType,
                  AGE_GROUP = AgeGroup,
                  GENDER = PerformerGender,
                  DENTIST_TYPE = DentistType,
                  DENTIST_COUNT = DentistCount)
  
  return(sicbl_csv_dentists)
  
}

get_wf_csv_joiners_leavers_icb <- function(year_list,
                                           fin_year){
  
  icb_names_data <- table_2b_wf |>
    dplyr::select(`Financial year`, `ODS code`, `ONS code`, `Area name`)
  
  year_joiners <- year_list$icb_joiners_leavers$joiners |>
    dplyr::mutate(DentistType = case_when(DentistType == "PP" ~ "Provider/Performer",
                                          DentistType == "PO" ~ "Associates",
                                          DentistType == "Foundation Dentist" ~ "Associates",
                                          TRUE ~ DentistType)) |>
    dplyr::group_by(Year_Start_Date, ICB_Code, ICB_NAME, ContractType, AgeGroup, PerformerGender, DentistType) |>
    dplyr::summarise(Joiners = n_distinct(PerformerNumber)) |>
    ungroup() |>
    dplyr::mutate(`Financial year` = fin_year,
                  WorkforceType = "Joiners") |>
    dplyr::select(-(Year_Start_Date)) |>
    dplyr::rename(DentistCount = Joiners)
  
  year_leavers <- year_list$icb_joiners_leavers$leavers |>
    dplyr::mutate(DentistType = case_when(DentistType == "PP" ~ "Provider/Performer",
                                          DentistType == "PO" ~ "Associates",
                                          DentistType == "Foundation Dentist" ~ "Associates",
                                          TRUE ~ DentistType)) |>
    dplyr::group_by(Year_Start_Date, ICB_Code, ICB_NAME, ContractType, AgeGroup, PerformerGender, DentistType) |>
    dplyr::summarise(Leavers = n_distinct(PerformerNumber)) |>
    ungroup() |>
    dplyr::mutate(`Financial year` = fin_year,
                  WorkforceType = "Leavers") |>
    dplyr::select(-(Year_Start_Date)) |>
    dplyr::rename(DentistCount = Leavers)
  
  icb_wf <- rbind(year_joiners,
                  year_leavers) |>
    dplyr::left_join(icb_names_data, by = c("Financial year" = "Financial year", 
                                            "ICB_Code" = "ODS code")) |>
    dplyr::mutate(GEOG_TYPE = "ICB") |>
    dplyr::select(FINANCIAL_YEAR = `Financial year`,
                  GEOG_TYPE,
                  GEOG_ODS_CODE = ICB_Code,
                  GEOG_ONS_CODE = `ONS code`,
                  GEOG_NAME = ICB_NAME,
                  JOINER_LEAVER = WorkforceType,
                  CONTRACT_TYPE = ContractType,
                  AGE_GROUP = AgeGroup,
                  GENDER = PerformerGender,
                  DENTIST_TYPE = DentistType,
                  DENTIST_COUNT = DentistCount)
  
  return(icb_wf)
  
}

get_wf_csv_region <- function(year_data){
  
  # region_lookup_distinct <- lookups_list$region_23 |>
  #   select(ICB23CDH, NHSER23CD, NHSER23CDH, NHSER23NM) |>
  #   distinct(ICB23CDH, NHSER23CD, NHSER23CDH, NHSER23NM)
  
  region_csv_totals <- year_data$active_performers$ICB_output |>
    #remove H&J codes as these appear in ICB totals instead and will have unknown region
    dplyr::filter(!(ICB_Code %in% c('HJ1',
                            'HJ2',
                            'HJ3',
                            'HJ4',
                            'HJ5',
                            'HJ6',
                            'HJ7'))) |>
    dplyr::mutate(DentistType = case_when(DentistType == "PP" ~ "Provider/Performer",
                                          DentistType == "PO" ~ "Associates",
                                          DentistType == "Foundation Dentist" ~ "Associates",
                                          TRUE ~ DentistType)) |>
    dplyr::left_join(icb_lookup, by = c("ICB_Code" = "ICB23CDH")) |>
    dplyr::mutate(
      GDS_FLAG = case_when(ContractType == "GDS" ~ 1,
                           TRUE ~ 0),
      PDS_FLAG = case_when(ContractType == "PDS" ~ 1,
                           ContractType == "PDS Plus" ~ 1,
                           TRUE ~ 0),
      TDS_FLAG = case_when(ContractType == "TDS" ~ 1,
                           TRUE ~ 0),
      MIXED_FLAG = case_when(ContractType == "Mixed" ~ 1,
                             TRUE ~ 0)) |>
    dplyr::group_by(Year, NHSER23CDH, NHSER23CD, NHSER23NM, PerformerNumber, AgeGroup, PerformerGender, DentistType) |>
    dplyr::summarise(
      GDS_FLAG = max(GDS_FLAG),
      PDS_FLAG = max(PDS_FLAG),
      TDS_FLAG = max(TDS_FLAG),
      MIXED_FLAG = max(MIXED_FLAG),
      .groups = "drop"
    ) |>
    group_by(Year, NHSER23CDH, PerformerNumber, AgeGroup, PerformerGender, DentistType) |>
    dplyr::mutate(
      ContractType = case_when(
        MIXED_FLAG > 0 ~ "Mixed",
        GDS_FLAG > 0 & PDS_FLAG > 0 & TDS_FLAG > 0 ~ "Mixed",
        GDS_FLAG > 0 & PDS_FLAG > 0 ~ "Mixed",
        GDS_FLAG > 0 & TDS_FLAG > 0 & PDS_FLAG == 0 ~ "GDS",
        GDS_FLAG == 0 & TDS_FLAG > 0 & PDS_FLAG > 0 ~ "PDS",
        GDS_FLAG == 0 & PDS_FLAG == 0 & TDS_FLAG > 0 ~ "TDS",
        GDS_FLAG > 0 & PDS_FLAG == 0 & TDS_FLAG == 0 ~ "GDS",
        GDS_FLAG == 0 & PDS_FLAG > 0 & TDS_FLAG == 0 ~ "PDS",
        TRUE ~ "Unknown"
      )) |>
    dplyr::group_by(Year, NHSER23CDH, NHSER23CD, NHSER23NM, ContractType, AgeGroup, PerformerGender, DentistType) |>
    summarise(DentistCount = n_distinct(PerformerNumber)) |>
    ungroup()
  
  region_csv_dentists <- region_csv_totals |>
    dplyr::mutate(GEOG_TYPE = "Region") |>
    dplyr::select(FINANCIAL_YEAR = Year,
                  GEOG_TYPE,
                  GEOG_ODS_CODE = NHSER23CDH,
                  GEOG_ONS_CODE = NHSER23CD,
                  GEOG_NAME = NHSER23NM,
                  CONTRACT_TYPE = ContractType,
                  AGE_GROUP = AgeGroup,
                  GENDER = PerformerGender,
                  DENTIST_TYPE = DentistType,
                  DENTIST_COUNT = DentistCount)
  
  return(region_csv_dentists)
  
}

get_csv_sicbl_joiners_leavers <- function(year_list,
                                          fin_year){
  
  sicbl_names_data <- table_2d_wf |>
    dplyr::select(`Financial year`, `ODS code`, `ONS code`, `SICBL name`)
  
  year_joiners <- year_list$sicbl_joiners_leavers$joiners |>
    dplyr::mutate(DentistType = case_when(DentistType == "PP" ~ "Provider/Performer",
                                          DentistType == "PO" ~ "Associates",
                                          DentistType == "Foundation Dentist" ~ "Associates",
                                          TRUE ~ DentistType)) |>
    dplyr::group_by(Year_Start_Date, SICBL_Code, ContractType, AgeGroup, PerformerGender, DentistType) |>
    dplyr::summarise(Joiners = n_distinct(PerformerNumber)) |>
    ungroup() |>
    dplyr::mutate(`Financial year` = fin_year,
                  WorkforceType = "Joiners") |>
    dplyr::select(-(Year_Start_Date)) |>
    dplyr::rename(DentistCount = Joiners)
  
  year_leavers <- year_list$sicbl_joiners_leavers$leavers |>
    dplyr::mutate(DentistType = case_when(DentistType == "PP" ~ "Provider/Performer",
                                          DentistType == "PO" ~ "Associates",
                                          DentistType == "Foundation Dentist" ~ "Associates",
                                          TRUE ~ DentistType)) |>
    dplyr::group_by(Year_Start_Date, SICBL_Code, ContractType, AgeGroup, PerformerGender, DentistType) |>
    dplyr::summarise(Leavers = n_distinct(PerformerNumber)) |>
    ungroup() |>
    dplyr::mutate(`Financial year` = fin_year,
                  WorkforceType = "Leavers") |>
    dplyr::select(-(Year_Start_Date)) |>
    dplyr::rename(DentistCount = Leavers)
  
  sicbl_wf <- rbind(year_joiners,
                    year_leavers) |>
    dplyr::left_join(sicbl_names_data, by = c("Financial year" = "Financial year", 
                                              "SICBL_Code" = "ODS code")) |>
    dplyr::mutate(GEOG_TYPE = "SICBL") |>
    dplyr::select(FINANCIAL_YEAR = `Financial year`,
                  GEOG_TYPE,
                  GEOG_ODS_CODE = SICBL_Code,
                  GEOG_ONS_CODE = `ONS code`,
                  GEOG_NAME = `SICBL name`,
                  JOINER_LEAVER = WorkforceType,
                  CONTRACT_TYPE = ContractType,
                  AGE_GROUP = AgeGroup,
                  GENDER = PerformerGender,
                  DENTIST_TYPE = DentistType,
                  DENTIST_COUNT = DentistCount)
  
  return(sicbl_wf)
  
}

#same function as used for the 2023/24 publication CSV output

get_region_wf <- function(year_list){
  
  # region_lookup_distinct <- icb_lookup |>
  #   select(ICB23CDH, NHSER23CD, NHSER23CDH, NHSER23NM) |>
  #   distinct(ICB23CDH, NHSER23CD, NHSER23CDH, NHSER23NM)
  
  region_wf_total <- year_list$active_performers$ICB_output |>
    dplyr::mutate(DentistType = case_when(DentistType == "PP" ~ "Provider/Performer",
                                          DentistType == "PO" ~ "Associates",
                                          DentistType == "Foundation Dentist" ~ "Associates",
                                          TRUE ~ DentistType)) |>
    dplyr::left_join(icb_lookup, by = c("ICB_Code" = "ICB23CDH")) |>
    dplyr::mutate(
      GDS_FLAG = case_when(ContractType == "GDS" ~ 1,
                           TRUE ~ 0),
      PDS_FLAG = case_when(ContractType == "PDS" ~ 1,
                           ContractType == "PDS Plus" ~ 1,
                           TRUE ~ 0),
      TDS_FLAG = case_when(ContractType == "TDS" ~ 1,
                           TRUE ~ 0),
      MIXED_FLAG = case_when(ContractType == "Mixed" ~ 1,
                             TRUE ~ 0)) |>
    dplyr::group_by(Year, NHSER23CDH, NHSER23CD, NHSER23NM, PerformerNumber, AgeGroup, PerformerGender, DentistType) |>
    dplyr::summarise(
      GDS_FLAG = max(GDS_FLAG),
      PDS_FLAG = max(PDS_FLAG),
      TDS_FLAG = max(TDS_FLAG),
      MIXED_FLAG = max(MIXED_FLAG),
      .groups = "drop"
    ) |>
    group_by(Year, NHSER23CDH, PerformerNumber, AgeGroup, PerformerGender, DentistType) |>
    dplyr::mutate(
      ContractType = case_when(
        MIXED_FLAG > 0 ~ "Mixed",
        GDS_FLAG > 0 & PDS_FLAG > 0 & TDS_FLAG > 0 ~ "Mixed",
        GDS_FLAG > 0 & PDS_FLAG > 0 ~ "Mixed",
        GDS_FLAG > 0 & TDS_FLAG > 0 & PDS_FLAG == 0 ~ "GDS",
        GDS_FLAG == 0 & TDS_FLAG > 0 & PDS_FLAG > 0 ~ "PDS",
        GDS_FLAG == 0 & PDS_FLAG == 0 & TDS_FLAG > 0 ~ "TDS",
        GDS_FLAG > 0 & PDS_FLAG == 0 & TDS_FLAG == 0 ~ "GDS",
        GDS_FLAG == 0 & PDS_FLAG > 0 & TDS_FLAG == 0 ~ "PDS",
        TRUE ~ "Unknown"
      )) |>
    dplyr::select(-(c(GDS_FLAG,
                      PDS_FLAG,
                      TDS_FLAG,
                      MIXED_FLAG)))
  
  return(region_wf_total)
  
}

get_wf_reg_joiners_leavers <- function(year_list,
                                       fin_year){
  
  year_joiners <- year_list$reg_joiners_leavers$joiners |>
    dplyr::mutate(Year = fin_year) |>
    dplyr::group_by(Year_Start_Date, NHSER23CD, NHSER23CDH, NHSER23NM, ContractType, AgeGroup, PerformerGender, DentistType) |>
    dplyr::summarise(DentistCount = n_distinct(PerformerNumber)) |>
    ungroup() |>
    dplyr::mutate(`Year` = fin_year,
                  WorkforceType = "Joiners") |>
    dplyr::select(-(Year_Start_Date))
  
  year_leavers <- year_list$reg_joiners_leavers$leavers |>
    dplyr::mutate(Year = fin_year) |>
    dplyr::group_by(Year_Start_Date, NHSER23CD, NHSER23CDH, NHSER23NM, ContractType, AgeGroup, PerformerGender, DentistType) |> 
    dplyr::summarise(DentistCount = n_distinct(PerformerNumber)) |>
    ungroup() |>
    dplyr::mutate(`Year` = fin_year,
                  WorkforceType = "Leavers") |>
    dplyr::select(-(Year_Start_Date))
  
  region_wf <- rbind(year_joiners,
                     year_leavers) |>
    dplyr::mutate(GEOG_TYPE = "Region") |>
    dplyr::select(FINANCIAL_YEAR = Year,
                  GEOG_TYPE,
                  GEOG_ODS_CODE = NHSER23CDH,
                  GEOG_ONS_CODE = NHSER23CD,
                  GEOG_NAME = NHSER23NM,
                  JOINER_LEAVER = WorkforceType,
                  CONTRACT_TYPE = ContractType,
                  AGE_GROUP = AgeGroup,
                  GENDER = PerformerGender,
                  DENTIST_TYPE = DentistType,
                  DENTIST_COUNT = DentistCount)
  
  return(region_wf)
  
}
