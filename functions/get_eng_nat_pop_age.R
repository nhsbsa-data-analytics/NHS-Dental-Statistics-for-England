#version of ons_nat_pop() function to get national mid year estimates 
#data available by dental publication age bands or by adult/child split
#data from https://www.ons.gov.uk/peoplepopulationandcommunity/populationandmigration/populationestimates/bulletins/populationestimatesforenglandandwales/mid2023
#to include data from mid-2019 to mid-2024 and get agebands, function gets local authority level data
#for single year of age, then aggregates this up to national and ageband level.
#also returns flag for if ageband is for adult or child
#example  eng_ageband_pop <- get_eng_nat_pop_age()

get_eng_nat_pop_age <-
  function(url = "https://www.ons.gov.uk/file?uri=/peoplepopulationandcommunity/populationandmigration/populationestimates/datasets/estimatesofthepopulationforenglandandwales/mid2011tomid2024detailedtimeseries/myebtablesenglandwales20112024.xlsx") {

    #TO DO: amend code to not include explicit column selection
    #currently used to avoid missing out 2024 column when auto selecting
  raw_data <- invisible(openxlsx::read.xlsx(
      xlsxFile = url,
      sheet = 5,
      startRow = 2,
      colNames = TRUE,
      cols = c(1,2,3,4,5,14,15,16,17,18,19)
    ))
    
    tidy_data <- raw_data |>
      dplyr::filter(country == "E") |>
      tidyr::pivot_longer(
        cols = starts_with("population_"),
        names_to = "calendar_year",
        names_prefix = "population_",
        values_to = "total_population",
        values_drop_na = TRUE
      ) |>
      dplyr::group_by(country, age, calendar_year) |>
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
        ),
        calendar_year = as.numeric(stringr::str_extract(calendar_year, "\\d{4}")),
        financial_year = paste0(calendar_year, "/", calendar_year + 1)
      ) |>
      dplyr::group_by(country, financial_year, calendar_year, age_band, adult_child) |>
      dplyr::summarise(population = sum(band_population)) |>
      ungroup() |>
      dplyr::filter(as.numeric(substr(financial_year, 1,4)) >= 2019) |>
      dplyr::arrange(calendar_year,
                     (factor(adult_child, levels = c('Child',
                                                     'Adult'))),
                     (factor(age_band, levels = c('0','1', '2', '3',
                                                  '4', '5', '6', '7',
                                                  '8', '9', '10', '11',
                                                  '12', '13', '14', '15',
                                                  '16', '17', '18-64', '65-74',
                                                  '75-84', '85+')))) |>
      dplyr::select(2,3,1,5,4,6)
    
    return(tidy_data)
    
  }