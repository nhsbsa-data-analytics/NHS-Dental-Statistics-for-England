#script to import latest ONS mid-year population estimates for England geographies
#to be called in main `pipeline.R` script
#functions loaded in main pipeline

#1. England national population for 2019 to 2024, total
eng_nat_pop <- get_eng_nat_pop()

#2. England national population for 2019 to 2024, child vs adult split and ageband
eng_pop_age <- get_eng_nat_pop_age()

#3. Local Authority (LA) population for 2019 to 2024, child vs adult split and ageband
la_pop_age <- get_la_pop_age()

#4. Local Authority (LA) population for 2019 to 2024, total
la_pop <- la_pop_age |>
  dplyr::group_by(FINANCIAL_YEAR,
                  CALENDAR_YEAR,
                  LA_CODE,
                  LA_NAME) |>
  dplyr::summarise(
  POPULATION = sum(POPULATION, na.rm = T),
  .groups = "drop")

#5. Ward population for 2019 to 2022, child vs adult split and ageband
ward_pop_age <- get_ward_pop_age(file_path = "Y:/Official Stats/Dental/2024_25/Data")

#TO DO: update LSOA, SICBL, ICB, NHS Region populations 2019 to 2022 
#(latest available at time of production)