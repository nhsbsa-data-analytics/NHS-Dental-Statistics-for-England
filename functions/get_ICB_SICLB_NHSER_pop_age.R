#function to get population by ICB, SICBL, or NHSER
#by single year of age (0 to 17) or ageband (18+, 18-64, 65-74, 75-84, 85+)
#data from https://www.ons.gov.uk/file?uri=/peoplepopulationandcommunity/populationandmigration/populationestimates/datasets/clinicalcommissioninggroupmidyearpopulationestimates/mid2011tomid2022integratedcareboards2023geography/sapeicb202320112022.xlsx"

# --- example ---
link <- "https://www.ons.gov.uk/file?uri=/peoplepopulationandcommunity/populationandmigration/populationestimates/datasets/clinicalcommissioninggroupmidyearpopulationestimates/mid2011tomid2022integratedcareboards2023geography/sapeicb202320112022.xlsx"
location_measure <- "ICB"        #must be one of c("ICB", "SICBL", "NHSER")
pop_age <- get_ICB_SICBL_NHSER_pop_age(link,location_measure)

# --- function ---
get_ICB_SICBL_NHSER_pop_age <- function(link, location_measure){
  
  # --- load packages here for now ---
  #library(tidyverse)
  #library(openxlsx)
  
  # --- check location_measure is of correct form ---
  if (!location_measure %in% c("ICB", "SICBL", "NHSER")){
    stop("Invalid location_measure: must be one of 'ICB', 'SICBL', or 'NHSER'.")
  }
  
  start_year <- 2019
  end_year <- 2022
  
  # initialise empty dataframe
  master_df <- data.frame()
  
  # loop over years
  for ( year in start_year:end_year){
    sheet_name <- paste0("Mid-", year, " ICB 2023")
    
    # Load the data with error handling
    raw_data <- tryCatch({
      read.xlsx(link, sheet = sheet_name, startRow = 4)
    }, error = function(e) {
      stop("Error reading Excel file: ", e$message)
    })
    
    # Hide rows not relevant to location measure of choice
    if (location_measure == "ICB"){
      location_data <- raw_data %>%
        select(-starts_with("SICBL.2023"), -starts_with("NHSER.2023")) %>%
        group_by(ICB.2023.Code, ICB.2023.Name) %>%
        summarise(across(where(is.numeric), \(x) sum(x, na.rm = TRUE)), .groups = "drop")
    } else if (location_measure == "SICBL"){
      location_data <- raw_data %>%
        select(-starts_with("ICB.2023"), -starts_with("NHSER.2023")) %>%
        group_by(SICBL.2023.Code, SICBL.2023.Name) %>%
        summarise(across(where(is.numeric), \(x) sum(x, na.rm = TRUE)), .groups = "drop")
    } else if (location_measure == "NHSER"){
      location_data <- raw_data %>%
        select(-starts_with("ICB.2023"), -starts_with("SICBL.2023")) %>%
        group_by(NHSER.2023.Code, NHSER.2023.Name) %>%
        summarise(across(where(is.numeric), \(x) sum(x, na.rm = TRUE)), .groups = "drop")
    } else {
      stop("Invalid location_measure: must be one of 'ICB', 'SICBL', or 'NHSER'.")
    }
    
    # Rename columns
    location_data_renamed <- location_data %>%
      rename_with(~ "LOCATION_CODE", .cols = ends_with(".Code")) %>%
      rename_with(~ "LOCATION_NAME", .cols = ends_with(".Name"))
    
    
    # --- pivot ---
    location_data_pivot <- location_data_renamed %>%
      pivot_longer(cols = `F0`:`M90`, names_to = "Gender.Age", values_to = "Population")%>%
      mutate(Age =  as.numeric( str_sub(Gender.Age, 2) )  ) %>%
      select(-Total, -Gender.Age) %>%
      group_by(LOCATION_CODE, LOCATION_NAME, Age) %>%
      summarise(across(where(is.numeric), \(x) sum(x, na.rm = TRUE)), .groups = "drop") %>%
      mutate( Age.Band = case_when(Age >= 85 ~ "85+",
                                   Age >= 75 ~  "75-84",
                                   Age >= 65 ~ "65-74",
                                   Age >= 18 ~ "18-64",
                                   Age <= 17 ~ as.character(Age)),
              Child.Adult = if_else(Age <= 17, "CHILD", "ADULT")
      ) %>%
      select( -Age) %>%
      group_by(LOCATION_CODE, LOCATION_NAME, Child.Adult, Age.Band) %>%
      summarise(across(where(is.numeric), \(x) sum(x, na.rm = TRUE)), .groups = "drop")
    
    Total_per_location <- location_data_pivot %>%
      group_by(LOCATION_CODE, LOCATION_NAME) %>%
      summarise(across(where(is.numeric), \(x) sum(x, na.rm = TRUE)), .groups = "drop") %>%
      mutate(Age.Band = "TOTAL",
             Child.Adult = "TOTAL") %>%
      select(LOCATION_CODE, LOCATION_NAME, Child.Adult, Age.Band, Population)
    
    Total_adults <- location_data_pivot %>%
      filter(Age.Band %in% c('18-64', '65-74','75-84', '85+')) %>%
      group_by(LOCATION_CODE, LOCATION_NAME, Child.Adult) %>%
      summarise(across(where(is.numeric), \(x) sum(x, na.rm = TRUE)), .groups = "drop") %>%
      mutate(Age.Band = "TOTAL") %>%
      select(LOCATION_CODE, LOCATION_NAME, Child.Adult, Age.Band, Population)
    
    Total_children <- location_data_pivot %>%
      filter(!Age.Band %in% c('18-64', '65-74','75-84', '85+')) %>%
      group_by(LOCATION_CODE, LOCATION_NAME, Child.Adult) %>%
      summarise(across(where(is.numeric), \(x) sum(x, na.rm = TRUE)), .groups = "drop") %>%
      mutate(Age.Band = "TOTAL") %>%
      select(LOCATION_CODE, LOCATION_NAME, Child.Adult, Age.Band, Population)
    
    Yearly_table <- bind_rows(location_data_pivot, Total_per_location, Total_adults, Total_children) %>%
      # add year column
      mutate( CALENDAR_YEAR = year,
              FINANCIAL_YEAR = paste0(year, "/", year + 1)) %>%
      relocate(FINANCIAL_YEAR, CALENDAR_YEAR, .before = everything()) %>%
      arrange(FINANCIAL_YEAR,
              CALENDAR_YEAR, 
              LOCATION_CODE, 
              LOCATION_NAME,
              factor(Child.Adult, levels = c('TOTAL','CHILD',
                                             'ADULT')),
              factor(Age.Band, levels = c('TOTAL',
                                          '0','1', '2', '3',
                                          '4', '5', '6', '7',
                                          '8', '9', '10', '11',
                                          '12', '13', '14', '15',
                                          '16', '17', '18-64', '65-74',
                                          '75-84', '85+')),
              Population) %>%
      rename("CHILD_ADULT" = Child.Adult,
             "AGE_BAND" = Age.Band,
             "POPULATION" = Population,
             !!paste0(location_measure, "_CODE") := LOCATION_CODE,
             !!paste0(location_measure, "_NAME") := LOCATION_NAME) 
    
    
    # add data for current year to master dataframe
    master_df <- bind_rows(master_df, Yearly_table)
  }
  
  return(master_df)
}
