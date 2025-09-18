#function to get population by sub-ICB
#example
#mid-year population estimates by LSOA from https://www.ons.gov.uk/peoplepopulationandcommunity/populationandmigration/populationestimates/datasets/lowersuperoutputareamidyearpopulationestimates
#LSOA population by year rolled up to sub-ICB level
#example  eng_sicb_pop <- get_eng_sicb_pop

get_eng_sicb_pop <- function(lsoa11_lookup,
                             lsoa21_lookup,
                             lsoa_df_2019,
                             lsoa_df_2020,
                             lsoa_df_2021,
                             lsoa_df_2022){
  
  
  #read in 2019 data and add lookup columns
  lsoa_2019 <- lsoa_df_2019 |>
    dplyr::select(LSOA.Code, 
                  LSOA.Name,
                  All.Ages) |>
    #remove welsh lsoa
    dplyr::filter(!grepl("^W", LSOA.Code)) |>
    dplyr::left_join(lsoa11_lookup, by = c("LSOA.Code" = "LSOA11CD")) |>
    dplyr::group_by(SICBL22CD, SICBL22CDH, SICBL22NM,
                    ICB22CD, ICB22CDH, ICB22NM) |>
    dplyr::summarise(population = sum(All.Ages)) |>
    dplyr::ungroup() |>
    dplyr::rename(SICBLCD = 1,
                  SICBLCDH = 2,
                  SICBLNM = 3,
                  ICBCD = 4,
                  ICBCDH = 5,
                  ICBNM = 6,
                  population_2019 = 7
    ) |>
    tidyr::pivot_longer(cols = "population_2019",
                        names_to = "year",
                        names_prefix = "population_",
                        values_to = "sicbl_population", values_drop_na = TRUE)
  
  lsoa_2020 <- lsoa_df_2020 |>
    dplyr::select(LSOA.Code, 
                  LSOA.Name,
                  All.Ages) |>
    #remove welsh lsoas
    dplyr::filter(!grepl("^W", LSOA.Code)) |>
    dplyr::left_join(lsoa11_lookup, by = c("LSOA.Code" = "LSOA11CD")) |>
    dplyr::group_by(SICBL22CD, SICBL22CDH, SICBL22NM,
                    ICB22CD, ICB22CDH, ICB22NM) |>
    dplyr::summarise(population = sum(All.Ages)) |>
    dplyr::ungroup() |>
    dplyr::rename(SICBLCD = 1,
                  SICBLCDH = 2,
                  SICBLNM = 3,
                  ICBCD = 4,
                  ICBCDH = 5,
                  ICBNM = 6,
                  population_2020 = 7
    ) |>
    tidyr::pivot_longer(cols = "population_2020",
                        names_to = "year",
                        names_prefix = "population_",
                        values_to = "sicbl_population", values_drop_na = TRUE)
    
  lsoa_2021 <- lsoa_df_2021 |>
    dplyr::select(LSOA.2021.Code,
                  LSOA.2021.Name,
                  Total) |>
    #remove welsh lsoa
    dplyr::filter(!grepl("^W", LSOA.2021.Code)) |>
    dplyr::left_join(lsoa21_lookup, by = c("LSOA.2021.Code" = "LSOA21CD")) |>
    dplyr::group_by(SICBL23CD, SICBL23CDH, SICBL23NM,
                    ICB23CD, ICB23CDH, ICB23NM) |>
    dplyr::summarise(population_2021 = sum(Total)) |>
    dplyr::ungroup() |>
    dplyr::rename(SICBLCD = 1,
                  SICBLCDH = 2,
                  SICBLNM = 3,
                  ICBCD = 4,
                  ICBCDH = 5,
                  ICBNM = 6,
                  population_2021 = 7
    ) |>
    tidyr::pivot_longer(cols = "population_2021",
                        names_to = "year",
                        names_prefix = "population_",
                        values_to = "sicbl_population", values_drop_na = TRUE)
  
  lsoa_2022 <- lsoa_df_2022 |>
    dplyr::select(LSOA.2021.Code,
                  LSOA.2021.Name,
                  Total) |>
    #remove welsh lsoa
    dplyr::filter(!grepl("^W", LSOA.2021.Code)) |>
    dplyr::left_join(lsoa21_lookup, by = c("LSOA.2021.Code" = "LSOA21CD")) |> 
    dplyr::group_by(SICBL23CD, SICBL23CDH, SICBL23NM,
                    ICB23CD, ICB23CDH, ICB23NM) |>
    dplyr::summarise(population = sum(Total)) |>
    dplyr::ungroup() |>
    dplyr::rename(SICBLCD = 1,
                  SICBLCDH = 2,
                  SICBLNM = 3,
                  ICBCD = 4,
                  ICBCDH = 5,
                  ICBNM = 6,
                  population_2022 = 7
    ) |>
    tidyr::pivot_longer(cols = "population_2022",
                        names_to = "year",
                        names_prefix = "population_",
                        values_to = "sicbl_population", values_drop_na = TRUE)
  
  sicbl_pop <- rbind(
    lsoa_2019,
    lsoa_2020,
    lsoa_2021,
    lsoa_2022
  )
  
  return(sicbl_pop)
    
}