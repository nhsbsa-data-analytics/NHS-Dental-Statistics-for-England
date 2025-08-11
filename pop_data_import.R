#script to import latest ONS mid-year population estimates for England geographies
#to be called in main `pipeline.R` script
#functions loaded in main pipeline

#1. England national population for 2019 to 2024, total
eng_nat_pop <- get_eng_nat_pop()

#2. England national population for 2019 to 2024, child vs adult split and ageband
eng_pop_age <- get_eng_nat_pop_age()

#3. Local Authority (LA) population for 2019 to 2024, total
la_pop <- la_pop_age |>
  dplyr::group_by(FINANCIAL_YEAR,
                  CALENDAR_YEAR,
                  LA_CODE,
                  LA_NAME) |>
  dplyr::summarise(
    POPULATION = sum(POPULATION, na.rm = T),
    .groups = "drop")

#4. Local Authority (LA) population for 2019 to 2024, child vs adult split and ageband
la_pop_age <- get_la_pop_age()

la_pop_child_adult <- la_pop_age |>
  group_by(FINANCIAL_YEAR,
           CALENDAR_YEAR,
           LA_CODE,
           LA_NAME,
           CHILD_ADULT) |>
  summarise(across(where(is.numeric), \(x) sum(x, na.rm = TRUE)), .groups = "drop") |>
  ungroup()

#filter to latest year to join to geographical breakdown excel tables
la_pop_child_adult_ltst <- la_pop_child_adult |>
  dplyr::filter(CALENDAR_YEAR == max(CALENDAR_YEAR))

#5. Ward population for 2019 to 2022, child vs adult split and ageband
ward_pop_age <- get_ward_pop_age(file_path = "Y:/Official Stats/Dental/2024_25/Data")

#TO DO: update LSOA, SICBL, ICB, NHS Region populations 2019 to 2022 
#(latest available at time of production)

#6. ICB population for 2019 to 2022, child vs adult split and ageband
#also loads ICB total population 

icb_pop_age <- get_ICB_SICBL_NHSER_pop_age(link = "https://www.ons.gov.uk/file?uri=/peoplepopulationandcommunity/populationandmigration/populationestimates/datasets/clinicalcommissioninggroupmidyearpopulationestimates/mid2011tomid2022integratedcareboards2023geography/sapeicb202320112022.xlsx",
                                           location_measure = "ICB")

icb_pop <- icb_pop_age |>
  dplyr::filter(CHILD_ADULT == 'TOTAL') |>
  dplyr::select(FINANCIAL_YEAR,
                CALENDAR_YEAR,
                ICB_CODE,
                ICB_NAME,
                POPULATION)

icb_pop_child_adult <- icb_pop_age |>
  dplyr::filter(AGE_BAND == 'TOTAL' &
                  CHILD_ADULT %in% c('CHILD', 'ADULT')) |>
  dplyr::select(FINANCIAL_YEAR,
                CALENDAR_YEAR,
                ICB_CODE,
                ICB_NAME,
                CHILD_ADULT,
                POPULATION)

#filter to latest year to join to geographical breakdown excel tables
icb_pop_child_adult_ltst <- icb_pop_child_adult |>
  dplyr::filter(CALENDAR_YEAR == max(CALENDAR_YEAR))

#7. NHS Region population for 2019 to 2022, child vs adult split and ageband
#also loads ICB total population 

nhser_pop_age <- get_ICB_SICBL_NHSER_pop_age(link = "https://www.ons.gov.uk/file?uri=/peoplepopulationandcommunity/populationandmigration/populationestimates/datasets/clinicalcommissioninggroupmidyearpopulationestimates/mid2011tomid2022integratedcareboards2023geography/sapeicb202320112022.xlsx",
                                           location_measure = "NHSER")

nhser_pop <- nhser_pop_age |>
  dplyr::filter(CHILD_ADULT == 'TOTAL') |>
  dplyr::select(FINANCIAL_YEAR,
                CALENDAR_YEAR,
                NHSER_CODE,
                NHSER_NAME,
                POPULATION)

nhser_pop_child_adult <- nhser_pop_age |>
  dplyr::filter(AGE_BAND == 'TOTAL' &
                  CHILD_ADULT %in% c('CHILD', 'ADULT')) |>
  dplyr::select(FINANCIAL_YEAR,
                CALENDAR_YEAR,
                NHSER_CODE,
                NHSER_NAME,
                CHILD_ADULT,
                POPULATION)

#filter to latest year for joining to geographical breakdown excel tables
nhser_pop_child_adult_ltst <- nhser_pop_child_adult |>
  dplyr::filter(CALENDAR_YEAR == max(CALENDAR_YEAR))

#8. SICBL total population for 2019 to 2022
#SICBL population only used in workforce tables, so no age breakdown needed

sicbl_pop <- get_ICB_SICBL_NHSER_pop_age(link = "https://www.ons.gov.uk/file?uri=/peoplepopulationandcommunity/populationandmigration/populationestimates/datasets/clinicalcommissioninggroupmidyearpopulationestimates/mid2011tomid2022integratedcareboards2023geography/sapeicb202320112022.xlsx",
                                             location_measure = "SICBL") |>
  dplyr::filter(CHILD_ADULT == 'TOTAL') |>
  dplyr::select(FINANCIAL_YEAR,
                CALENDAR_YEAR,
                SICBL_CODE,
                SICBL_NAME,
                POPULATION)