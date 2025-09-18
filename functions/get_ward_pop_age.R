#function to get population by ward,
#by single year of age (0 to 17) or ageband (18+, 18-64, 65-74, 75-84, 85+)

#csv files for years 2019 to 2022 have been downloaded from nomis and can be found in the Y drive
#example code:
#ward_pop_age <-get_ward_pop_age(file_path = "Y:/Official Stats/Dental/2024_25/Data")

get_ward_pop_age <- function(file_path, ward_code_col = "mnemonic",
                                    ward_name_col = "2023 ward" ) {
  for (i in 19:22) {
    tryCatch({
      file_name <- paste0(file_path, "/nomis_ward_population_estimates_20", i, ".csv")
      df <- read.csv(file_name, skip = 6, check.names = FALSE)
      
      # Add a year column
      df$CALENDAR_YEAR <- paste0("20", i)
      
      # Reorder columns
      df <- df[, c("CALENDAR_YEAR", setdiff(names(df), "CALENDAR_YEAR"))]
      
      # Load data into global environment
      assign(paste0("pop_est_20", i), df, envir = .GlobalEnv)
      
      message("Successfully loaded: ", file_name)
    }, error = function(e) {
      warning("Failed to load file for year 20", i, ": ", conditionMessage(e))
    })
  }
  
  #join data frames into 1
  full_data<- rbind(pop_est_2019, pop_est_2020, pop_est_2021, pop_est_2022)
  
  # Check if the necessary columns exist
  if (!all(c(ward_code_col, ward_name_col) %in% colnames(full_data))) {
    stop("The specified columns do not exist in the data.")
  }
  
  tidy_data <- full_data |> 
    tidyr::pivot_longer(
      cols = starts_with("Age"),
      names_to = "age",
      names_prefix = "Age ",
      values_to = "POPULATION"
    ) |> 
    dplyr::mutate(
      age = stringr::str_extract(age, "\\d+"),
      age = as.numeric(age)
    ) |>  
    dplyr::mutate(
      AGE_BAND = dplyr::case_when(age >= 85 ~ "85+",
                                  age >= 75 ~  "75-84",
                                  age >= 65 ~ "65-74",
                                  age >= 18 ~ "18-64",
                                  age <= 17 ~ as.character(age)),
      CHILD_ADULT = dplyr::case_when(age <= 17 ~ "CHILD",
                                     age > 17 ~ "ADULT"),
      CALENDAR_YEAR = as.numeric(CALENDAR_YEAR),
      FINANCIAL_YEAR = paste0(CALENDAR_YEAR, "/", CALENDAR_YEAR + 1)
    ) |>
    dplyr::group_by(
      FINANCIAL_YEAR,
      CALENDAR_YEAR,
      !!rlang::sym(ward_code_col),
      !!rlang::sym(ward_name_col),
      AGE_BAND,
      CHILD_ADULT
    ) |>
    dplyr::summarise(
      POPULATION = sum(POPULATION, na.rm = T),
      .groups = "drop"
    ) |>
    dplyr::rename(
      WARD_CODE = 3,
      WARD_NAME = 4
    ) |>
    dplyr::arrange(CALENDAR_YEAR,
                   WARD_CODE,
                   (factor(CHILD_ADULT, levels = c('CHILD',
                                                   'ADULT'))),
                   (factor(AGE_BAND, levels = c('0','1', '2', '3',
                                                '4', '5', '6', '7',
                                                '8', '9', '10', '11',
                                                '12', '13', '14', '15',
                                                '16', '17', '18-64', '65-74',
                                                '75-84', '85+')))) |>
    dplyr::select(1,2,3,4,6,5,7)
  
  return(tidy_data)
  
}