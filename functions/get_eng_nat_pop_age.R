#version of ons_nat_pop() function to get national mid year estimates 
#excludes Isles of Scilly Local Authority due to dental data coverage
#data available by dental publication age bands or by adult/child split
#data from https://www.ons.gov.uk/peoplepopulationandcommunity/populationandmigration/populationestimates/bulletins/populationestimatesforenglandandwales/mid2023
#to include data from mid-2023 and get agebands, function gets local authority level data
#for single year of age, then aggregates this up to national and ageband level.
#also returns flag for if ageband is for adult or child
#example    eng_ageband_pop <- get_eng_nat_pop_age()

get_eng_nat_pop_age <-
  function(url = "https://www.ons.gov.uk/file?uri=/peoplepopulationandcommunity/populationandmigration/populationestimates/datasets/estimatesofthepopulationforenglandandwales/mid2011tomid2023detailedtimeserieseditionofthisdataset/myebtablesenglandwales20112023.xlsx") {
    
    df <- invisible(openxlsx::read.xlsx(
      xlsxFile = url,
      sheet = 5,
      startRow = 2,
      colNames = TRUE,
      cols = c(1,2,3,4,5,14,15,16,17,18)
    ))
    
    pop_df <- df |>
      dplyr::filter(country == "E" & ladcode23 != "E06000053") |>
      tidyr::pivot_longer(
        cols = starts_with("population_"),
        names_to = "year",
        names_prefix = "population_",
        values_to = "total_population",
        values_drop_na = TRUE
      ) |>
      dplyr::group_by(country, age, year) |>
      dplyr::summarise(band_population = sum(total_population)) |>
      ungroup() |>
      dplyr::mutate(
        age_band = dplyr::case_when(
          age >= 85 ~ "85+",
          age >= 75 ~ "75-84",
          age >= 65 ~ "65-74",
          age >= 18 ~ "18-64",
          age >= 15 ~ "15-17",
          age >= 10 ~ "10-14",
          age >= 5 ~ "05-09",
          TRUE ~ "00-04"
        )) |>
      dplyr::mutate(
        adult_child = dplyr::case_when(
          age >= 18 ~ "Adult",
          TRUE ~ "Child"
        )
      ) |>
      dplyr::group_by(country, year, age_band, adult_child) |>
      dplyr::summarise(population = sum(band_population)) |>
      ungroup()
    
    return(pop_df)
    
  }