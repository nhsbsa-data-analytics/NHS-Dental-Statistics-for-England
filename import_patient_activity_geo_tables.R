#script to import contract location activity tables to build national excel files
#to be called in main `pipeline.R` script
#additional functions loaded in main pipeline

#use SQL scripts from \sql folder in repository
#use custom functions defined in `import_contract_activity_national_tables.R`

# Import tables created in SQL --------------------------------------------------

table1a_geo_pat_import <- import_table("DENTAL_GEO_PAT_TABLE1A_2425")
table1b_geo_pat_import <- import_table("DENTAL_GEO_PAT_TABLE1B_2425")
table1c_geo_pat_import <- import_table("DENTAL_GEO_PAT_TABLE1C_2425")
table1d_geo_pat_import <- import_table("DENTAL_GEO_PAT_TABLE1D_2425") # Ward

table2a_geo_pat_import <- import_table("DENTAL_GEO_PAT_TABLE2A_2425")
table2b_geo_pat_import <- import_table("DENTAL_GEO_PAT_TABLE2B_2425")
table2c_geo_pat_import <- import_table("DENTAL_GEO_PAT_TABLE2C_2425")
table2d_geo_pat_import <- import_table("DENTAL_GEO_PAT_TABLE2D_2425") # Ward

table3a_geo_pat_import <- import_table("DENTAL_GEO_PAT_TABLE3A_2425")
table3b_geo_pat_import <- import_table("DENTAL_GEO_PAT_TABLE3B_2425")
table3c_geo_pat_import <- import_table("DENTAL_GEO_PAT_TABLE3C_2425")
table3d_geo_pat_import <- import_table("DENTAL_GEO_PAT_TABLE3D_2425") # Ward

table4a_geo_pat_import <- import_table("DENTAL_GEO_PAT_TABLE4A_2425")
table5a_geo_pat_import <- import_table("DENTAL_GEO_PAT_TABLE5A_2425")

#Table 1a region COTs

#join to get missing region names
#"Other" group for non-England pseudo regions
#"Unknown" for activity unable to be mapped to NSPL
#TO DO: select region 2022 or 2024 code columns for final table

table_1a_geo_pat <- table1a_geo_pat_import |>
  #join to lookup for region name and ODS code
  dplyr::left_join(region_lookup, by = join_by(`ONS code`== "NHSER21CD")) |>
  #add non England data into 'other' group
  #add non-mapped postcode activity to 'unknown' group 
  dplyr::mutate(`ONS code` = case_when(`ONS code` %in% c('L99999999',
                                                         'M99999999',
                                                         'N99999999',
                                                         'S99999999',
                                                         'W99999999') ~ "Other",
                                       `ONS code` == 'E40000008' ~ 'E40000011',
                                       `ONS code` == 'E40000009' ~ 'E40000012',
                                       is.na(`ONS code`) ~ "Unknown",
                                       TRUE ~ `ONS code`)) |>
  dplyr::mutate(`Region name` = case_when(`ONS code` == "Other"  ~ "Other",
                                          `ONS code` == "Unknown" ~ "Unknown",
                                          TRUE ~ `NHSER21NM`)) |>
  dplyr::group_by(`Financial year`,
                  `ONS code`,
                  `ODS code` = NHSER24CDH,
                  `Region name`,
                  NHSER24CD) |>
  summarise(across(`Band 1`:`Total`, ~ sum(.x, na.rm = TRUE))) |>
  ungroup() |>
  dplyr::select(-c(NHSER24CD))

#Table 1b ICB COTs

table_1b_geo_pat <- table1b_geo_pat_import |>
  #join to lookup for ICB name and ODS code
#  dplyr::left_join(icb_lookup, by = join_by(`ONS code`== "NHSER21CD")) |>
  #add non England data into 'other' group
  #add non-mapped postcode activity to 'unknown' group 
  dplyr::mutate(`ONS code` = case_when(`ONS code` %in% c('L99999999',
                                                         'M99999999',
                                                         'N99999999',
                                                         'S99999999',
                                                         'W99999999') ~ "Other",
                                       is.na(`ONS code`) ~ "Unknown",
                                       TRUE ~ `ONS code`)) |>
  dplyr::mutate(`ICB name` = case_when(`ONS code` == "Other"  ~ "Other",
                                          `ONS code` == "Unknown" ~ "Unknown",
                                          TRUE ~ `ICB name`)) |>
  dplyr::group_by(`Financial year`,
                  `ONS code`,
                  `ODS code`,
                  `ICB name`) |>
  summarise(across(`Band 1`:`Total`, ~ sum(.x, na.rm = TRUE))) |>
  ungroup()

#Table 1c LA COTs

#Check if using correct version of LA lookup
#should be 296 distinct code rows and 1 NA row
# View(la_23_dist <- la_lookup |>
#   group_by(LAD23CD) %>%
#   summarise(count = n()))

table_1c_geo_pat <- table1c_geo_pat_import |>
  #add non England data into 'other' group
  #add non-mapped postcode activity to 'unknown' group
  #TO DO put grepl call into single case when grouping
  dplyr::mutate(`ONS code` = case_when(grepl("L", `ONS code`) ~ "Other",
                                       grepl("M", `ONS code`) ~ "Other",
                                       grepl("N", `ONS code`) ~ "Other",
                                       grepl("S", `ONS code`) ~ "Other",
                                       grepl("W", `ONS code`) ~ "Other",
                                       is.na(`ONS code`) ~ "Unknown",
                                       TRUE ~ `ONS code`)) |>
  dplyr::left_join(la_lookup, by = join_by(`ONS code`== "LAD23CD")) |>
  dplyr::mutate(`LA name` = case_when(`ONS code` == "Other"  ~ "Other",
                                          `ONS code` == "Unknown" ~ "Unknown",
                                          TRUE ~ `LAD23NM`)) |>
  dplyr::group_by(`Financial year`,
                  `ONS code`,
                  `LA name`) |>
  summarise(across(`Band 1`:`Total`, ~ sum(.x, na.rm = TRUE))) |>
  ungroup()

#Table 1d Ward COTs
table_1d_geo_pat <- table1d_geo_pat_import |>
  #add non England data into 'other' group
  #add non-mapped postcode activity to 'unknown' group
  #TO DO put grepl call into single case when grouping
  dplyr::mutate(`ONS code` = case_when(grepl("L", `ONS code`) ~ "Other",
                                       grepl("M", `ONS code`) ~ "Other",
                                       grepl("N", `ONS code`) ~ "Other",
                                       grepl("S", `ONS code`) ~ "Other",
                                       grepl("W", `ONS code`) ~ "Other",
                                       is.na(`ONS code`) ~ "Unknown",
                                       TRUE ~ `ONS code`)) |>
  dplyr::left_join(ward_lookup, by = join_by(`ONS code`== "WD23CD")) |>
  dplyr::mutate(`Ward name` = case_when(`ONS code` == "Other"  ~ "Other",
                                      `ONS code` == "Unknown" ~ "Unknown",
                                      TRUE ~ `WD23NM`)) |>
  dplyr::group_by(`Financial year`,
                  `ONS code`,
                  `Ward name`) |>
  summarise(across(`Band 1`:`Total`, ~ sum(.x, na.rm = TRUE))) |>
  ungroup()

#Table 1e Region COT percent

table_1e_geo_pat <- percentage_table_1234(table_1a_geo_pat)

#Table 1f ICB COT percent

table_1f_geo_pat <- percentage_table_1234(table_1b_geo_pat)

#Table 1g LA COT percent

table_1g_geo_pat <- percentage_table_123(table_1c_geo_pat)

#Table 1h Ward COT percent

table_1h_geo_pat <- percentage_table_123(table_1d_geo_pat)

#Table 2a region UDAs

#join to get missing region names
#"Other" group for non-England pseudo regions
#"Unknown" for activity unable to be mapped to NSPL
#TO DO: select region 2022 or 2024 code columns for final table

table_2a_geo_pat <- table2a_geo_pat_import |>
  #join to lookup for region name and ODS code
  dplyr::left_join(region_lookup, by = join_by(`ONS code`== "NHSER21CD")) |>
  #add non England data into 'other' group
  #add non-mapped postcode activity to 'unknown' group 
  dplyr::mutate(`ONS code` = case_when(`ONS code` %in% c('L99999999',
                                                         'M99999999',
                                                         'N99999999',
                                                         'S99999999',
                                                         'W99999999') ~ "Other",
                                       `ONS code` == 'E40000008' ~ 'E40000011',
                                       `ONS code` == 'E40000009' ~ 'E40000012',
                                       is.na(`ONS code`) ~ "Unknown",
                                       TRUE ~ `ONS code`)) |>
  dplyr::mutate(`Region name` = case_when(`ONS code` == "Other"  ~ "Other",
                                          `ONS code` == "Unknown" ~ "Unknown",
                                          TRUE ~ `NHSER21NM`)) |>
  dplyr::group_by(`Financial year`,
                  `ONS code`,
                  `ODS code` = NHSER24CDH,
                  `Region name`,
                  NHSER24CD) |>
  summarise(across(`Band 1`:`Total`, ~ sum(.x, na.rm = TRUE))) |>
  ungroup() |>
  dplyr::select(-c(NHSER24CD))

#Table 2b ICB UDAs

table_2b_geo_pat <- table2b_geo_pat_import |>
  #join to lookup for ICB name and ODS code
# dplyr::left_join(icb_lookup, by = join_by(`ONS code`== "NHSER21CD")) |>
  #add non England data into 'other' group
  #add non-mapped postcode activity to 'unknown' group 
  dplyr::mutate(`ONS code` = case_when(`ONS code` %in% c('L99999999',
                                                         'M99999999',
                                                         'N99999999',
                                                         'S99999999',
                                                         'W99999999') ~ "Other",
                                       is.na(`ONS code`) ~ "Unknown",
                                       TRUE ~ `ONS code`)) |>
  dplyr::mutate(`ICB name` = case_when(`ONS code` == "Other"  ~ "Other",
                                       `ONS code` == "Unknown" ~ "Unknown",
                                       TRUE ~ `ICB name`)) |>
  dplyr::group_by(`Financial year`,
                  `ONS code`,
                  `ODS code`,
                  `ICB name`) |>
  summarise(across(`Band 1`:`Total`, ~ sum(.x, na.rm = TRUE))) |>
  ungroup()

#Table 2c LA UDAs

table_2c_geo_pat <- table2c_geo_pat_import |>
  #add non England data into 'other' group
  #add non-mapped postcode activity to 'unknown' group
  #TO DO put grepl call into single case when grouping
  dplyr::mutate(`ONS code` = case_when(grepl("L", `ONS code`) ~ "Other",
                                       grepl("M", `ONS code`) ~ "Other",
                                       grepl("N", `ONS code`) ~ "Other",
                                       grepl("S", `ONS code`) ~ "Other",
                                       grepl("W", `ONS code`) ~ "Other",
                                       is.na(`ONS code`) ~ "Unknown",
                                       TRUE ~ `ONS code`)) |>
  dplyr::left_join(la_lookup, by = join_by(`ONS code`== "LAD23CD")) |>
  dplyr::mutate(`LA name` = case_when(`ONS code` == "Other"  ~ "Other",
                                      `ONS code` == "Unknown" ~ "Unknown",
                                      TRUE ~ `LAD23NM`)) |>
  dplyr::group_by(`Financial year`,
                  `ONS code`,
                  `LA name`) |>
  summarise(across(`Band 1`:`Total`, ~ sum(.x, na.rm = TRUE))) |>
  ungroup()

#Table 2d Ward COTs
table_2d_geo_pat <- table2d_geo_pat_import |>
  #add non England data into 'other' group
  #add non-mapped postcode activity to 'unknown' group
  #TO DO put grepl call into single case when grouping
  dplyr::mutate(`ONS code` = case_when(grepl("L", `ONS code`) ~ "Other",
                                       grepl("M", `ONS code`) ~ "Other",
                                       grepl("N", `ONS code`) ~ "Other",
                                       grepl("S", `ONS code`) ~ "Other",
                                       grepl("W", `ONS code`) ~ "Other",
                                       is.na(`ONS code`) ~ "Unknown",
                                       TRUE ~ `ONS code`)) |>
  dplyr::left_join(ward_lookup, by = join_by(`ONS code`== "WD23CD")) |>
  dplyr::mutate(`Ward name` = case_when(`ONS code` == "Other"  ~ "Other",
                                        `ONS code` == "Unknown" ~ "Unknown",
                                        TRUE ~ `WD23NM`)) |>
  dplyr::group_by(`Financial year`,
                  `ONS code`,
                  `Ward name`) |>
  summarise(across(`Band 1`:`Total`, ~ sum(.x, na.rm = TRUE))) |>
  ungroup()

#Table 2e Region UDA percent

table_2e_geo_pat <- percentage_table_1234(table_2a_geo_pat)

#Table 2f ICB UDA percent

table_2f_geo_pat <- percentage_table_1234(table_2b_geo_pat)

#Table 2g LA UDA percent

table_2g_geo_pat <- percentage_table_123(table_2c_geo_pat)

#Table 2h Ward UDA percent

table_2h_geo_pat <- percentage_table_123(table_2d_geo_pat)

#Table 3a Region patients seen

table_3a_geo_pat <- table3a_geo_pat_import |>
  #join to lookup for region name and ODS code
  dplyr::left_join(region_lookup, by = join_by(`ONS code`== "NHSER21CD")) |>
  #add non England data into 'other' group
  #add non-mapped postcode activity to 'unknown' group 
  dplyr::mutate(`ONS code` = case_when(`ONS code` %in% c('L99999999',
                                                         'M99999999',
                                                         'N99999999',
                                                         'S99999999',
                                                         'W99999999') ~ "Other",
                                       `ONS code` == 'E40000008' ~ 'E40000011',
                                       `ONS code` == 'E40000009' ~ 'E40000012',
                                       is.na(`ONS code`) ~ "Unknown",
                                       TRUE ~ `ONS code`)) |>
  dplyr::mutate(`Region name` = case_when(`ONS code` == "Other"  ~ "Other",
                                          `ONS code` == "Unknown" ~ "Unknown",
                                          TRUE ~ `NHSER21NM`)) |>
  dplyr::mutate(`Financial year` = case_when(`ONS code` == "Unknown" ~ '2024/2025',
                                             TRUE ~ `Financial year`)) |>
  dplyr::group_by(`Financial year`,
                  `ONS code`,
                  `ODS code` = NHSER24CDH,
                  `Region name`,
                  NHSER24CD) |>
  summarise(across(`Adults seen`:`Children seen`, ~ sum(.x, na.rm = TRUE))) |>
  ungroup() |>
  dplyr::select(-c(NHSER24CD))

#Table 3b ICB patients seen

table_3b_geo_pat <- table3b_geo_pat_import |>
  #join to lookup for ICB name and ODS code
  # dplyr::left_join(icb_lookup, by = join_by(`ONS code`== "NHSER21CD")) |>
  #add non England data into 'other' group
  #add non-mapped postcode activity to 'unknown' group 
  dplyr::mutate(`ONS code` = case_when(`ONS code` %in% c('L99999999',
                                                         'M99999999',
                                                         'N99999999',
                                                         'S99999999',
                                                         'W99999999') ~ "Other",
                                       is.na(`ONS code`) ~ "Unknown",
                                       TRUE ~ `ONS code`)) |>
  dplyr::mutate(`ICB name` = case_when(`ONS code` == "Other"  ~ "Other",
                                       `ONS code` == "Unknown" ~ "Unknown",
                                       TRUE ~ `ICB name`)) |>
  dplyr::mutate(`Financial year` = case_when(`ONS code` == "Unknown" ~ '2024/2025',
                                             TRUE ~ `Financial year`)) |>
  dplyr::group_by(`Financial year`,
                  `ONS code`,
                  `ODS code`,
                  `ICB name`) |>
  summarise(across(`Adults seen`:`Children seen`, ~ sum(.x, na.rm = TRUE))) |>
  ungroup()

# View(table3b_geo_pat_import |>
#        dplyr::filter(is.na(`ONS code`)))

#Table 3c LA patients seen

table_3c_geo_pat <- table3c_geo_pat_import |>
  #add non England data into 'other' group
  #add non-mapped postcode activity to 'unknown' group
  #TO DO put grepl call into single case when grouping
  dplyr::mutate(`ONS code` = case_when(grepl("L", `ONS code`) ~ "Other",
                                       grepl("M", `ONS code`) ~ "Other",
                                       grepl("N", `ONS code`) ~ "Other",
                                       grepl("S", `ONS code`) ~ "Other",
                                       grepl("W", `ONS code`) ~ "Other",
                                       is.na(`ONS code`) ~ "Unknown",
                                       TRUE ~ `ONS code`)) |>
  dplyr::left_join(la_lookup, by = join_by(`ONS code`== "LAD23CD")) |>
  dplyr::mutate(`LA name` = case_when(`ONS code` == "Other"  ~ "Other",
                                      `ONS code` == "Unknown" ~ "Unknown",
                                      TRUE ~ `LAD23NM`)) |>
  dplyr::mutate(`Financial year` = case_when(`ONS code` == "Unknown" ~ '2024/2025',
                                             TRUE ~ `Financial year`)) |>
  dplyr::group_by(`Financial year`,
                  `ONS code`,
                  `LA name`) |>
  summarise(across(`Adults seen`:`Children seen`, ~ sum(.x, na.rm = TRUE))) |>
  ungroup()

#Table 3d Ward patients seen

table_3d_geo_pat <- table3d_geo_pat_import |>
  #add non England data into 'other' group
  #add non-mapped postcode activity to 'unknown' group
  #TO DO put grepl call into single case when grouping
  dplyr::mutate(`ONS code` = case_when(grepl("L", `ONS code`) ~ "Other",
                                       grepl("M", `ONS code`) ~ "Other",
                                       grepl("N", `ONS code`) ~ "Other",
                                       grepl("S", `ONS code`) ~ "Other",
                                       grepl("W", `ONS code`) ~ "Other",
                                       is.na(`ONS code`) ~ "Unknown",
                                       TRUE ~ `ONS code`)) |>
  dplyr::left_join(ward_lookup, by = join_by(`ONS code`== "WD23CD")) |>
  dplyr::mutate(`Ward name` = case_when(`ONS code` == "Other"  ~ "Other",
                                        `ONS code` == "Unknown" ~ "Unknown",
                                        TRUE ~ `WD23NM`)) |>
  dplyr::mutate(`Financial year` = case_when(`ONS code` == "Unknown" ~ '2024/2025',
                                             TRUE ~ `Financial year`)) |>
  dplyr::group_by(`Financial year`,
                  `ONS code`,
                  `Ward name`) |>
  summarise(across(`Adults seen`:`Children seen`, ~ sum(.x, na.rm = TRUE))) |>
  ungroup()

#Table 3e Region patients seen percent population

table_3e_geo_pat <- table_3a_geo_pat |>
  dplyr::left_join(nhser_pop_child_adult_ltst, by = c("Region name" = "NHSER_NAME")) |>
  tidyr::pivot_wider(names_from = "CHILD_ADULT",
                     values_from = "POPULATION") |>
  dplyr::mutate(`Provisional adult percent` = (`Adults seen`/ADULT * 100),
                `Provisional child percent` = (`Children seen`/CHILD * 100)) |>
  dplyr::rename(`Adult population` = `ADULT`,
                `Child population` = `CHILD`) |>
  dplyr::select (-c(FINANCIAL_YEAR,
                    NHSER_CODE,
                    `NA`,
                    `Adults seen`,
                    `Children seen`)) |>
  dplyr::select(`Financial year`,
                `ONS code`,
                `ODS code`,
                `Region name`,
                `Mid-year population year` = CALENDAR_YEAR,
                `Adult population`,
                `Child population`,
                `Provisional adult percent`,
                `Provisional child percent`)


#Table 3f ICB patients seen percent population

table_3f_geo_pat <- table_3b_geo_pat |>
  dplyr::left_join(icb_pop_child_adult_ltst, by = c("ONS code" = "ICB_CODE")) |>
  #remove H and J commissioners as no population available
  dplyr::filter(! `ODS code` %in% c("HJ1",
                                    "HJ2",
                                    "HJ3",
                                    "HJ4",
                                    "HJ5",
                                    "HJ6",
                                    "HJ7")) |>
  tidyr::pivot_wider(names_from = "CHILD_ADULT",
                     values_from = "POPULATION") |>
  dplyr::mutate(`Provisional adult percent` = (`Adults seen`/ADULT * 100),
                `Provisional child percent` = (`Children seen`/CHILD * 100)) |>
  dplyr::rename(`Adult population` = `ADULT`,
                `Child population` = `CHILD`) |>
  dplyr::select (-c(FINANCIAL_YEAR,
                    ICB_NAME,
                    `Adults seen`,
                    `Children seen`)) |>
  dplyr::select(`Financial year`,
                `ONS code`,
                `ODS code`,
                `ICB name`,
                `Mid-year population year` = CALENDAR_YEAR,
                `Adult population`,
                `Child population`,
                `Provisional adult percent`,
                `Provisional child percent`)

#Table 3g LA patients seen percent population

table_3g_geo_pat <- table_3c_geo_pat |>
  dplyr::left_join(la_pop_child_adult_ltst, by = c("Financial year" = "FINANCIAL_YEAR",
                                                   "ONS code" = "LA_CODE")) |>
  tidyr::pivot_wider(names_from = "CHILD_ADULT",
                     values_from = "POPULATION") |>
  dplyr::mutate(`Adult percent` = (`Adults seen`/ADULT * 100),
                `Child percent` = (`Children seen`/CHILD * 100)) |>
  dplyr::rename(`Adult population` = `ADULT`,
                `Child population` = `CHILD`) |>
  dplyr::select (-c(LA_NAME,
                    `Adults seen`,
                    `Children seen`)) |>
  dplyr::select(`Financial year`,
                `ONS code`,
                `Local Authority name` = `LA name`,
                `Mid-year population year` = CALENDAR_YEAR,
                `Adult population`,
                `Child population`,
                `Adult percent`,
                `Child percent`)

#Table 3h Ward patients seen percent population

table_3h_geo_pat <- table_3d_geo_pat |>
  dplyr::left_join(ward_pop_child_adult_ltst, by = c("ONS code" = "WARD_CODE")) |>
  tidyr::pivot_wider(names_from = "CHILD_ADULT",
                     values_from = "POPULATION") |>
  dplyr::mutate(`Provisional adult percent` = (`Adults seen`/ADULT * 100),
                `Provisional child percent` = (`Children seen`/CHILD * 100)) |>
  dplyr::rename(`Adult population` = `ADULT`,
                `Child population` = `CHILD`) |>
  dplyr::select (-c(WARD_NAME,
                    `Adults seen`,
                    `Children seen`)) |>
  dplyr::select(`Financial year`,
                `ONS code`,
                `Ward name`,
                `Mid-year population year` = CALENDAR_YEAR,
                `Adult population`,
                `Child population`,
                `Provisional adult percent`,
                `Provisional child percent`)

#IMD tables - check how to structure/where to add population breakdown
#add population caveats (2019 and 2020 only IMD population years available)

#Table 4a IMD COTs (Quintile)

table_4a_geo_pat <- table4a_geo_pat_import |>
  dplyr::mutate(`IMD quintile` = case_when(`IMD decile` %in% c(1, 2)  ~ "1",
                                           `IMD decile` %in% c(3, 4) ~ "2",
                                           `IMD decile` %in% c(5, 6) ~ "3",
                                           `IMD decile` %in% c(7, 8) ~ "4",
                                           `IMD decile` %in% c(9, 10) ~ "5",
                                           TRUE ~ 'Unknown'
                             )) |>
  dplyr::select(-`IMD decile`) |>
  group_by(`Financial year`,
           `IMD quintile`) |>
  summarise(across(where(is.numeric), \(x) sum(x, na.rm = TRUE)), .groups = "drop") |>
  ungroup() |>
  dplyr::arrange(desc(`Financial year`))

#Table 5a IMD UDAs (Quintile)

table_5a_geo_pat <- table5a_geo_pat_import |>
  dplyr::mutate(`IMD quintile` = case_when(`IMD decile` %in% c(1, 2)  ~ "1",
                                           `IMD decile` %in% c(3, 4) ~ "2",
                                           `IMD decile` %in% c(5, 6) ~ "3",
                                           `IMD decile` %in% c(7, 8) ~ "4",
                                           `IMD decile` %in% c(9, 10) ~ "5",
                                           TRUE ~ 'Unknown'
  )) |>
  dplyr::select(-`IMD decile`) |>
  group_by(`Financial year`,
           `IMD quintile`) |>
  summarise(across(where(is.numeric), \(x) sum(x, na.rm = TRUE)), .groups = "drop") |>
  ungroup() |>
  dplyr::arrange(desc(`Financial year`))
