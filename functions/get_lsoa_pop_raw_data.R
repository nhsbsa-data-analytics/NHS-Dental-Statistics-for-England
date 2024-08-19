#function to get Lower Super Output Area (LSOA) population data from ONS
#as raw data for use in aggregating up to health geography populations
#example  lsoa_pop <- get_lsoa_pop_raw_data()

get_lsoa_pop_raw_data <-
  function(link_2021_22 = "https://www.ons.gov.uk/file?uri=/peoplepopulationandcommunity/populationandmigration/populationestimates/datasets/lowersuperoutputareamidyearpopulationestimates/mid2021andmid2022/sapelsoasyoatablefinal.xlsx",
           link_2020 = "https://www.ons.gov.uk/file?uri=/peoplepopulationandcommunity/populationandmigration/populationestimates/datasets/lowersuperoutputareamidyearpopulationestimates/mid2020sape23dt2/sape23dt2mid2020lsoasyoaestimatesunformatted.xlsx",
           link_2019 = "https://www.ons.gov.uk/file?uri=/peoplepopulationandcommunity/populationandmigration/populationestimates/datasets/lowersuperoutputareamidyearpopulationestimates/mid2019sape22dt2/sape22dt2mid2019lsoasyoaestimatesunformatted.zip") {

    #download, extract, and read in 2019 data from zip folder using temp file links
    temp <- tempfile()
    temp2 <- tempfile()
    
    download.file(link_2019, temp)
    unzip(zipfile = temp, exdir = temp2)
    lsoa_2019 <-
      openxlsx::read.xlsx(
        xlsxFile = file.path(
          temp2,
          "SAPE22DT2-mid-2019-lsoa-syoa-estimates-unformatted.xlsx"
        ),
        sheet = 4,
        startRow = 5,
        colNames = TRUE
      )
    unlink(c(temp, temp2))
    
    #download and read in 2020, 2021, and 2022 lsoa data
    lsoa_2020 <-
      openxlsx::read.xlsx(
        xlsxFile = link_2020,
        sheet = 4,
        startRow = 5,
        colNames = TRUE)
    
    lsoa_2021 <-
      openxlsx::read.xlsx(
        xlsxFile = link_2021_22,
        sheet = 5,
        startRow = 4,
        colNames = TRUE
      )
    
    #read in 2022 data with single year of age columns
    lsoa_2022 <-
      openxlsx::read.xlsx(
        xlsxFile = link_2021_22,
        sheet = 6,
        startRow = 4,
        colNames = TRUE
      )
    
    lsoa_pop <- list()
    lsoa_pop$lsoa_2019 <- lsoa_2019
    lsoa_pop$lsoa_2020 <- lsoa_2020
    lsoa_pop$lsoa_2021 <- lsoa_2021
    lsoa_pop$lsoa_2022 <- lsoa_2022
    
    return(lsoa_pop)
    
  }