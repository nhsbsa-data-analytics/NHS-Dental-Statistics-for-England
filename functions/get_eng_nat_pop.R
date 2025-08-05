#version of ons_nat_pop() function to get national mid year estimates
#updated August 2025 to get latest ONS data for 2019 to 2024
#data from https://www.ons.gov.uk/peoplepopulationandcommunity/populationandmigration/populationestimates/datasets/estimatesofthepopulationforenglandandwales
#example  

eng_national_pop <- get_eng_nat_pop()

get_eng_nat_pop <-
  function(url = "https://www.ons.gov.uk/file?uri=/peoplepopulationandcommunity/populationandmigration/populationestimates/datasets/estimatesofthepopulationforenglandandwales/mid20242023localauthorityboundaries/mye24tablesew.xlsx") {
    df <- invisible(openxlsx::read.xlsx(
      xlsxFile = url,
      sheet = 11,
      startRow = 8,
      colNames = TRUE,
      cols = c(1, 2, 3, 4, 5, 6, 7, 8, 9)
    ))
    
    pop_df <- df |>
      dplyr::filter(Name == "ENGLAND") |>
      tidyr::pivot_longer(
        cols = starts_with("Mid-"),
        names_to = "year",
        names_prefix = "population_",
        values_to = "population",
        values_drop_na = TRUE
      ) |>
      ungroup() |>
      dplyr::mutate(
        year = as.numeric(stringr::str_extract(year, "\\d{4}")),
        financial_year = paste0(year, "/", year + 1)
      ) |>
      dplyr::select(
        code = Code,
        country = Name,
        geography = Geography,
        year,
        financial_year,
        population
      )
    
    return(pop_df)
    
  }