#version of ons_nat_pop() function to get national mid year estimates
#removes population of Isles of Scilly Local Authority
#data from https://www.ons.gov.uk/peoplepopulationandcommunity/populationandmigration/populationestimates/bulletins/populationestimatesforenglandandwales/mid2023
#example  eng_national_pop <- get_eng_nat_pop()

get_eng_nat_pop <-
  function(url = "https://www.ons.gov.uk/file?uri=/peoplepopulationandcommunity/populationandmigration/populationestimates/datasets/estimatesofthepopulationforenglandandwales/mid2011tomid2023detailedtimeserieseditionofthisdataset/myebtablesenglandwales20112023.xlsx") {
    
    df <- invisible(openxlsx::read.xlsx(
      xlsxFile = url,
      sheet = 5,
      startRow = 2,
      colNames = TRUE,
      cols = c(1,2,3,4,5,14,15,16,17,18)
    ))
     
    #remove Isles of Scilly local authority by filtering on LA 23 code 
      pop_df <- df |>
        dplyr::filter(country == "E" & ladcode23 != "E06000053") |>
        tidyr::pivot_longer(
          cols = starts_with("population_"),
          names_to = "year",
          names_prefix = "population_",
          values_to = "total_population",
          values_drop_na = TRUE
        ) |>
        dplyr::group_by(country, year) |>
        dplyr::summarise(population = sum(total_population)) |>
        ungroup()
      
    return(pop_df)
      
  }