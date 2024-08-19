#function to get population by local authority, 
#by single year of age (0 to 17) or ageband (18+, 18-64, 65-74, 75-84, 85+)
#example  link <- "https://www.ons.gov.uk/file?uri=/peoplepopulationandcommunity/populationandmigration/populationestimates/datasets/estimatesofthepopulationforenglandandwales/mid2011tomid2023detailedtimeserieseditionofthisdataset/myebtablesenglandwales20112023.xlsx"
#         la_pop_ageband <- get_la_population_age(link = link)

get_la_population_age <- function(link,
                                          la_code_col = "ladcode23",
                                          la_name_col = "laname23") {
  # Load the data with error handling
  raw_data <- tryCatch({
    openxlsx::read.xlsx(link, sheet = "MYEB1", startRow = 2)
  }, error = function(e) {
    stop("Error reading Excel file: ", e$message)
  })
  
  # Check if the necessary columns exist
  if (!all(c(la_code_col, la_name_col) %in% colnames(raw_data))) {
    stop("The specified columns do not exist in the data.")
  }
  
  tidy_data <- raw_data |> 
    tidyr::pivot_longer(
      cols = starts_with("population"),
      names_to = "CALENDAR_YEAR",
      values_to = "POPULATION"
    ) |>
    dplyr::mutate(
      AGE_BAND = dplyr::case_when(age >= 18 ~ "18-64",
                                  age >= 65 ~ "65-74",
                                  age >= 75 ~  "75-84",
                                  age >= 85 ~ "85+",
                                  age <= 17 ~ as.character(age)),
      CHILD_ADULT = dplyr::case_when(age <= 17 ~ "CHILD",
                                     age > 17 ~ "ADULT"),
      CALENDAR_YEAR = as.numeric(stringr::str_extract(CALENDAR_YEAR, "\\d{4}")),
      FINANCIAL_YEAR = paste0(CALENDAR_YEAR, "/", CALENDAR_YEAR + 1)
    ) |>
    dplyr::group_by(
      FINANCIAL_YEAR,
      CALENDAR_YEAR,
      !!rlang::sym(la_code_col),
      !!rlang::sym(la_name_col),
      AGE_BAND,
      CHILD_ADULT
    ) |>
    dplyr::summarise(
      POPULATION = sum(POPULATION, na.rm = T),
      .groups = "drop"
    ) |>
    dplyr::rename(
      LA_CODE = 3,
      LA_NAME = 4
    )
  
  return(tidy_data)
  
}