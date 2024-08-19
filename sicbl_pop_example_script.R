# example script using functions from NHS dental statistics repo
# to get population by sub-ICB in England from 2019 to 2022 (latest available)

#1. load packages
#2. get ONS lookups and raw LSOA population data
#3. get sub-Integrated Care Board Location (SICBL) population
#4. get NHS region population 
#5. get ICB population by age
#6. get NHS region population by age

# 1. Load packages and source functions ----------------------------------------

#library(dplyr)
#library(openxlsx)
#library(readr)
#library(tidyr)

# source functions
# this is only a temporary step until all functions are built into packages

# select all .R files in functions sub-folder
function_files <- list.files(path = "functions", pattern = "\\.R$")

# loop over function_files to source all files in functions sub-folder
for (file in function_files) {
  source(file.path("functions", file))
}

#2. Get ONS lookups and raw LSOA population data -------------------------------

# get list of ONS lookup files
lookups_list <- get_lsoa_icb_lookups()

# get lsoa level population data for 2019, 20202, 2021, and 2022
lsoa_list <- get_lsoa_pop_raw_data()

# get lookups from list for lsoa 2011 and lsoa 2021 level data to map
# lsoa11 locations to 2022 ICB boundaries and lsoa21 locations to 2023 ICB boundaries
lsoa11_lookup <- lookups_list$lsoa11_icb22
lsoa21_lookup <- lookups_list$lsoa21_icb23

# get lsoa level population data from list
lsoa_df_2019 <- lsoa_list$lsoa_2019
lsoa_df_2020 <- lsoa_list$lsoa_2020
lsoa_df_2021 <- lsoa_list$lsoa_2021
lsoa_df_2022 <- lsoa_list$lsoa_2022

#3. Get sub-Integrated Care Board Location (SICBL) population ------------------

# get population data for sub-icb by year
sub_icb_pop <- get_eng_sicb_pop(
  lsoa11_lookup = lsoa11_lookup,
  lsoa21_lookup = lsoa21_lookup,
  lsoa_df_2019 = lsoa_df_2019,
  lsoa_df_2020 = lsoa_df_2020,
  lsoa_df_2021 = lsoa_df_2021,
  lsoa_df_2022 = lsoa_df_2022
)

# checking if join and summarise steps give expected number of unique values

# using 'CD' columns gives 2 extra

#length(unique(sub_icb_pop[["SICBLCD"]]))
#length(unique(sub_icb_pop[["ICBCD"]]))

# using CDH columns gives correct numbers 
# (42 unique ICB codes, 106 unique SICBL codes)

#length(unique(sub_icb_pop[["ICBCDH"]]))
#length(unique(sub_icb_pop[["SICBLCDH"]]))

#4. Get NHS region population --------------------------------------------------

# population by region
# to be put into a function in future
region_22_lookup <- lookups_list$region_22
region_23_lookup <- lookups_list$region_23

# create table mapped and aggregated up to population in NHS England Regions
nhs_eng_region_pop <- sub_icb_pop |>
  #fix code for Surrey Heartlands SICBL and Sussex SICBL to newest ONS SICBL code
  dplyr::mutate(SICBLCD = dplyr::case_when(
    SICBLCD == "E38000248" ~ "E38000265",
    SICBLCD == "E38000246" ~ "E38000264",
    TRUE ~ SICBLCD
  )) |>
  #join lookup to NHS region
  dplyr::left_join(region_23_lookup, by = c("SICBLCD" = "SICBL23CD")) |>
  dplyr::group_by(year, NHSER23CD, NHSER23CDH, NHSER23NM) |>
  dplyr::summarise(region_population = sum(sicbl_population)) |>
  ungroup()

# check if 7 NHS regions present in final data  
#length(unique(sicb_region_pop[["NHSER23CD"]]))

#5. TO DO: Get ICB population by age -------------------------------------------


#6. TO DO:  get NHS region population by age -----------------------------------