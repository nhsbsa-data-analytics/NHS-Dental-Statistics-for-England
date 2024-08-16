#example script using functions from NHS dental statistics repo
#to get population by sub-ICB in England from 2019 to 2022 (latest available)
#excludes Isles of Scilly

# source functions
# this is only a temporary step until all functions are built into packages

# select all .R files in functions sub-folder
function_files <- list.files(path = "functions", pattern = "\\.R$")

# loop over function_files to source all files in functions sub-folder
for (file in function_files) {
  source(file.path("functions", file))
}

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

#get population data for sub-icb by year
sub_icb_pop <- get_eng_sicb_pop(
  lsoa11_lookup = lsoa11_lookup,
  lsoa21_lookup = lsoa21_lookup,
  lsoa_df_2019 = lsoa_df_2019,
  lsoa_df_2020 = lsoa_df_2020,
  lsoa_df_2021 = lsoa_df_2021,
  lsoa_df_2022 = lsoa_df_2022
)

#checking unique values
#using 'CD' columns gives 2 extra
length(unique(sub_icb_pop[["SICBLCD"]]))
length(unique(sub_icb_pop[["ICBCD"]]))

#using CDH columns gives correct numbers (42 unique ICB codes, 106 unique SICBL codes)
length(unique(sub_icb_pop[["ICBCDH"]]))
length(unique(sub_icb_pop[["SICBLCDH"]]))