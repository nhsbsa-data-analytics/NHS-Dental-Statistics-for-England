#script to import latest ONS mid-year population estimates for England geographies
#to be called in main `pipeline.R` script
#functions loaded in main pipeline

#1. England national population for 2019 to 2024, total
eng_nat_pop <- get_eng_nat_pop()

#2. England national population for 2019 to 2024, child vs adult split and ageband
eng_pop_age <- get_eng_nat_pop_age()

#3. Local Authority (LA) population for 2019 to 2024, child vs adult split and ageband
la_pop_age <- get_la_pop_age()

la_pop_child_adult <- la_pop_age |>
  group_by(FINANCIAL_YEAR,
           CALENDAR_YEAR,
           LA_CODE,
           LA_NAME,
           CHILD_ADULT) |>
  summarise(across(where(is.numeric), \(x) sum(x, na.rm = TRUE)), .groups = "drop") |>
  ungroup()

#4. Local Authority (LA) population for 2019 to 2024, total
la_pop <- la_pop_age |>
  dplyr::group_by(FINANCIAL_YEAR,
                  CALENDAR_YEAR,
                  LA_CODE,
                  LA_NAME) |>
  dplyr::summarise(
    POPULATION = sum(POPULATION, na.rm = T),
    .groups = "drop")

#filter to latest year to join to geographical breakdown excel tables
la_pop_child_adult_ltst <- la_pop_child_adult |>
  dplyr::filter(CALENDAR_YEAR == max(CALENDAR_YEAR))

#5. Ward population for 2019 to 2022, child vs adult split and ageband
ward_pop_age <- get_ward_pop_age(file_path = "Y:/Official Stats/Dental/2024_25/Data")

ward_pop_child_adult <- ward_pop_age |>
  group_by(FINANCIAL_YEAR,
           CALENDAR_YEAR,
           WARD_CODE,
           WARD_NAME,
           CHILD_ADULT) |>
  summarise(across(where(is.numeric), \(x) sum(x, na.rm = TRUE)), .groups = "drop") |>
  ungroup()

#filter to latest year to join to geographical breakdown excel tables
ward_pop_child_adult_ltst <- ward_pop_child_adult |>
  dplyr::filter(CALENDAR_YEAR == max(CALENDAR_YEAR))

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

icb_pop_2324 <- icb_pop |>
  dplyr::filter(FINANCIAL_YEAR == max(FINANCIAL_YEAR)) |>
  dplyr::mutate(FINANCIAL_YEAR = '2023/2024')
icb_pop_2425 <- icb_pop |>
  dplyr::filter(FINANCIAL_YEAR == max(FINANCIAL_YEAR)) |>
  dplyr::mutate(FINANCIAL_YEAR = '2024/2025')

icb_pop_fill <- icb_pop |>
  rbind(icb_pop_2324, icb_pop_2425)

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

#fill in 2023/24 and 2024/25 years with 2022 values
#TO DO: add into main pop function

icb_pop_age_2324 <- icb_pop_age |>
  dplyr::filter(FINANCIAL_YEAR == max(FINANCIAL_YEAR)) |>
  dplyr::mutate(FINANCIAL_YEAR = '2023/2024')
icb_pop_age_2425 <- icb_pop_age |>
  dplyr::filter(FINANCIAL_YEAR == max(FINANCIAL_YEAR)) |>
  dplyr::mutate(FINANCIAL_YEAR = '2024/2025')

icb_pop_age_fill <- icb_pop_age |>
  rbind(icb_pop_age_2324, icb_pop_age_2425)

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

nhser_pop_2324 <- nhser_pop |>
  dplyr::filter(FINANCIAL_YEAR == max(FINANCIAL_YEAR)) |>
  dplyr::mutate(FINANCIAL_YEAR = '2023/2024')
nhser_pop_2425 <- nhser_pop |>
  dplyr::filter(FINANCIAL_YEAR == max(FINANCIAL_YEAR)) |>
  dplyr::mutate(FINANCIAL_YEAR = '2024/2025')
nhser_pop_2526 <- nhser_pop |>
  dplyr::filter(FINANCIAL_YEAR == max(FINANCIAL_YEAR)) |>
  dplyr::mutate(FINANCIAL_YEAR = '2025/2026')

nhser_pop_fill <- nhser_pop |>
  rbind(nhser_pop_2324, nhser_pop_2425, nhser_pop_2526)

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

#fill in 2023/24 and 2024/25 years with 2022 values
#TO DO: add into main pop function

nhser_pop_age_2324 <- nhser_pop_age |>
  dplyr::filter(FINANCIAL_YEAR == max(FINANCIAL_YEAR)) |>
  dplyr::mutate(FINANCIAL_YEAR = '2023/2024')
nhser_pop_age_2425 <- nhser_pop_age |>
  dplyr::filter(FINANCIAL_YEAR == max(FINANCIAL_YEAR)) |>
  dplyr::mutate(FINANCIAL_YEAR = '2024/2025')
nhser_pop_age_2526 <- nhser_pop_age |>
  dplyr::filter(FINANCIAL_YEAR == max(FINANCIAL_YEAR)) |>
  dplyr::mutate(FINANCIAL_YEAR = '2025/2026')

nhser_pop_age_fill <- nhser_pop_age |>
  rbind(nhser_pop_age_2324, nhser_pop_age_2425, nhser_pop_age_2526)

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

#fill in 2023/24 and 2024/25 years with 2022 values
#TO DO: add into main pop function

sicbl_pop_2324 <- sicbl_pop |>
  dplyr::filter(FINANCIAL_YEAR == max(FINANCIAL_YEAR)) |>
  dplyr::mutate(FINANCIAL_YEAR = '2023/2024')
sicbl_pop_2425 <- sicbl_pop |>
  dplyr::filter(FINANCIAL_YEAR == max(FINANCIAL_YEAR)) |>
  dplyr::mutate(FINANCIAL_YEAR = '2024/2025')

sicbl_pop_fill <- sicbl_pop |>
  rbind(sicbl_pop_2324, sicbl_pop_2425)