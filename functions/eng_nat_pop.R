#version of ons_nat_pop() function to get national mid year estimates 
#data from https://www.ons.gov.uk/peoplepopulationandcommunity/populationandmigration/populationestimates/bulletins/populationestimatesforenglandandwales/mid2023
#amended function as mid-year 2023 estimates currently only available for England and Wales nationally

ons_national_pop <-
  function(url = "https://www.ons.gov.uk/file?uri=/peoplepopulationandcommunity/populationandmigration/populationestimates/datasets/estimatesofthepopulationforenglandandwales/mid20232023localauthorityboundarieseditionofthisdataset/mye23tablesew.xlsx") {

    df <- invisible(openxlsx::read.xlsx(
      xlsxFile = url,
        sheet = 11,
      startRow = 8,
      colNames = TRUE,
      cols = c(1:8)
      ))
      
      pop_df <- df |>
        dplyr::select(
          Code,
          Name,
          `Mid-2023`,
          `Mid-2022`,
          `Mid-2021`,
          `Mid-2020`,
          `Mid-2019`
        ) |>
        dplyr::filter(Name == "ENGLAND") |>
        tidyr::pivot_longer(
          cols = starts_with("Mid-"),
          names_to = "Year",
          names_prefix = "Mid-",
          values_to = "Population",
          values_drop_na = TRUE
        )
      
    return(pop_df)
      
  }