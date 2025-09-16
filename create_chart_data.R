#TO DO: add custom rounding function to functions folder

round_any <-
  function(x, accuracy, f = round) {
    f(x / accuracy) * accuracy
  }

#Figure 1: national total COT by year, England

fig_1_data <- table1ai |>
  dplyr::select(`Financial year`,
                `Total COT` = Total) |>
  dplyr::arrange(`Financial year`) 

figure_1 <- fig_1_data |>
  nhsbsaVis::basic_chart_hc(
    x = `Financial year`,
    y = `Total COT`,
    type = "line",
    xLab = "Financial year",
    yLab = "Number of courses of treatment (COT)",
    title = "") |>
  hc_subtitle(text = "M = Millions",
              align = "left") |>
  highcharter::hc_yAxis(min = 0)

table_1_data <- fig_1_data |>
  dplyr::mutate(`Total COT` = format(`Total COT`, big.mark = ","))

#figure 2: national COT by treatment band 2024/25
fig_2_data <- table1ai |>
  tidyr::pivot_longer(
    cols = c(`Band 1`:`Regulation 11 Replacement Appliance`),
    names_to = "Treatment band",
    values_to = "Total COT",
  ) |>
  dplyr::select(`Financial year`,
                `Treatment band`,
                `Total COT`) |>
  dplyr::filter(`Financial year` == config$last_year,
                `Treatment band` %in% c("Band 1",
                                        "Band 2",
                                        "Band 2a",
                                        "Band 2b", 
                                        "Band 2c",
                                        "Band 3", 
                                        "Urgent"))

figure_2 <- basic_chart_hc(
  fig_2_data,
  x = `Treatment band`,
  y = `Total COT`,
  type = "column",
  xLab = "Treatment band",
  yLab = "Number of courses of treatment (COT)",
  title = "",
  color = "#005eb8"
) |>
  hc_subtitle(text = "M = Millions",
              align = "left")

table_2_data <- table1ai |>
  tidyr::pivot_longer(
    cols = c(`Band 1`:`Regulation 11 Replacement Appliance`),
    names_to = "Treatment band",
    values_to = "Total COT",
  ) |>
  dplyr::select(`Financial year`,
                `Treatment band`,
                `Total COT`) |>
  dplyr::filter(`Financial year` == "2024/2025") |>
  mutate(`Total COT` = format(`Total COT`, big.mark = ","))

#figure 3: total national COT by adult and child split, England

fig_3_data <- table1c |>
  dplyr::select(`Financial year`,
                `Patient_Type`,
                `Total`) |>
  dplyr::filter(`Patient_Type` != "All") |>
  dplyr::mutate(Age_band = case_when(
    `Patient_Type` == "Child" ~ "Child",
    TRUE ~ "Adult")) |>
  dplyr::group_by(`Financial year`, 
                  Age_band) |>
  dplyr::summarise(`Total` = sum(`Total`)) |>
  ungroup() |>
  dplyr::select(`Financial year`,
                `Patient type` = `Age_band`,
                `Total COT` = `Total`)|>
  dplyr::arrange(`Financial year`) 

figure_3 <- fig_3_data |>
  nhsbsaVis::group_chart_hc(
    x = `Financial year`,
    y = `Total COT`,
    group = `Patient type`,
    type = "line",
    xLab = "Financial year",
    yLab = "Number of courses of treatment (COT)",
    dlOn = T,
    title = ""
  ) |> 
  hc_subtitle(text = "M = Millions",
              align = "left") |>
  hc_tooltip(enabled = T,
             shared = T,
             sort = T) 

figure_3$x$hc_opts$series[[1]]$dataLabels$allowOverlap <- TRUE
figure_3$x$hc_opts$series[[2]]$dataLabels$allowOverlap <- TRUE

table_3_data <- fig_3_data |>
  dplyr::mutate(`Total COT` = format(`Total COT`, big.mark = ","))


#figure 4 annual UDA 

fig_4_data <- table2ai |>
  dplyr::select(`Financial year`,
                `Total UDA` = `Total`) |>
  dplyr::arrange(`Financial year`)

figure_4 <- fig_4_data |>
  nhsbsaVis::basic_chart_hc(
    x = `Financial year`,
    y = `Total UDA`,
    type = "line",
    xLab = "Financial year",
    yLab = "Number of units of dental activity (UDA)",
    title = "") |>
  hc_subtitle(text = "M = Millions",
              align = "left") |>
  highcharter::hc_yAxis(min = 0)

table_4_data_formatted <-
  tibble(
    `Financial year` = c(
      "2019/2020",
      "2020/2021",
      "2021/2022",
      "2022/2023",
      "2023/2024",
      "2024/2025"
    ),
    `Total UDA` = c(79725106, 24351462, 57723637, 70130676, 72502208, 73088476)
  ) |>
  dplyr::mutate(`Total UDA` = format(`Total UDA`, big.mark = ","))

table_4_data_format <- fig_4_data |>
  dplyr::mutate(`Total UDA` = substr(`Total UDA`, 1, nchar(`Total UDA`))) |>
  dplyr::mutate(`Total UDA` = format(`Total UDA`, big.mark = ","))

#code below shows data to 1 decimal place but doesn't apply thousand number separators
# table_4_data <- fig_4_data |>
#   dplyr::mutate(`Total UDA` = sprintf(`Total UDA`, fmt = '%#.1f')) |>
#   dplyr::mutate(`Total UDA` = format(`Total UDA`, big.mark = ","))

#patient revenue

fig_5_data <- table6a |>
  dplyr::select(`Financial year`,
                `Total patient revenue (GBP)` = `Total`) |>
  dplyr::arrange(`Financial year`) 

#if decimal places aren't displaying, check if need to increase digits shown
options(digits = 12)

fin_year <- c("2019/2020",
              "2020/2021",
              "2021/2022",
              "2022/2023",
              "2023/2024",
              "2024/2025"
              )
pat_rev <- as.numeric(c(854523275.59,
                        267914038.63,
                        646429196.49,
                        754173200.89, 
                        774307482.94,
                        806504707.59
                        ))

fig_5_data <- data.frame(fin_year,
                         pat_rev) |>
  dplyr::select(`Financial year` = fin_year,
                `Total patient revenue (GBP)` = pat_rev) |>
  dplyr::arrange(`Financial year`)

figure_5 <- fig_5_data |>
  nhsbsaVis::basic_chart_hc(
    x = `Financial year`,
    y = `Total patient revenue (GBP)`,
    type = "line",
    xLab = "Financial year",
    yLab = "Total patient revenue (GBP)",
    title = "") |>
  hc_subtitle(text = "M = Millions",
              align = "left") |>
  highcharter::hc_yAxis(min = 0)

table_5_data <- as.data.frame(fig_5_data) |>
  dplyr::mutate(`Total patient revenue (GBP)` = format(`Total patient revenue (GBP)`, big.mark = ","))

#Fig 6 ### change figure numbers once all charts and tables run

figure_6_data <- table1gi |> 
  dplyr::filter(`Financial year` == "2024/2025",
                !(`DCP status` %in% c("All",
                                      "Non-DCP led and not DCP assisted")),
                !(`DCP type` == "All")) |>
  dplyr::select(-`DCP type`,
                -`Regulation 11 Replacement Appliance`,
                -`Free`
  ) |>
  dplyr::group_by(`Financial year`,
                  `DCP status`) |>
  tidyr::pivot_longer(- c(`Financial year`, `DCP status`),
                      names_to = "Treatment_band",
                      values_to = "COT") |>
  dplyr::filter(!(Treatment_band == "Total")) |>
  dplyr::group_by(`Financial year`,
                  `DCP status`,
                  Treatment_band) |>
  dplyr::summarise(COT = sum(COT, na.rm=TRUE)) |>
  dplyr::rename(`Treatment band` = Treatment_band) |>
  dplyr::arrange(factor(`DCP status`, levels = c('DCP-led',
                                                 'DCP-assisted'))) 


figure_6_table_data <- figure_6_data |>
  dplyr::mutate(COT = format(COT, big.mark = ","))

figure_6 <- figure_6_data |>
  dplyr::filter(`Treatment band` != 'Band 2') |>
  nhsbsaVis::group_chart_hc(
    x = `Treatment band`,
    y = `COT`,
    group = `DCP status`,
    type = "column",
    xLab = "Treatment band",
    yLab = "Number of COTs",
    dlOn = T,
    title = ""
  ) |> 
  hc_subtitle(text = "",
              align = "left") |>
  hc_tooltip(enabled = T,
             shared = T,
             sort = T)

figure_6$x$hc_opts$series[[1]]$dataLabels$allowOverlap <- TRUE
figure_6$x$hc_opts$series[[2]]$dataLabels$allowOverlap <- TRUE


#Geographic activity breakdowns ------------------------------------------------

### Geographical breakdown of contract location activity data

#percentage of adult patients seen out of population by ICB
fig_7_data_contract <- geo_table3e |>
  dplyr::select( `Financial year`,
                 `ODS code`,
                 `ICB name`,
                 `Provisional adult population` = `Adult population`, 
                 `Provisional adult percent`) |>
  dplyr::mutate(across(where(is.numeric), round, 1),
                ADULT_PERCENT = `Provisional adult percent`,
                ICB_NAME = `ICB name`) |>
  arrange(desc(`Provisional adult percent`))

#comment out if focusing on maps this year
figure_7_contract <- fig_7_data_contract |>
  nhsbsaVis::basic_chart_hc(
    x = `ODS code`,
    y = `Provisional adult percent`,
    type = "column",
    xLab = "ICB ODS code",
    yLab = "Adult patients as percentage of population",
    dlOn = F,
    title = "") |>
  hc_tooltip(
    enabled = T,
    useHTML = TRUE,
    formatter = JS(
      "function(){
                            var result = this.point.ICB_NAME + '<br><b>Percent of adult population seen by dentist:</b> ' + this.point.ADULT_PERCENT.toFixed(0)
                            return result
             }"
    )
  ) |>
  hc_yAxis(labels = list(enabled = T))

#TO DO: amend ICB names via population lookup earlier in pipeline/table import
fig_7_data_contract_names_fix <- geo_table3e |>
  dplyr::select( `Financial year`,
                 `ODS code`,
                 `ICB name`,
                 `Provisional adult population` = `Adult population`, 
                 `Provisional adult percent`) |>
  dplyr::mutate(across(where(is.numeric), round, 1),
                ADULT_PERCENT = `Provisional adult percent`,
                ICB_NAME = `ICB name`) |>
  arrange(desc(`Provisional adult percent`)) |>
  dplyr::left_join(icb_lookup_distinct, by = c("ODS code" = "ICB23CDH")) |>
  select(`Financial year`,
         `ODS code`,
         `ICB name` = ICB23NM,
         `Provisional adult population`,
         `Provisional adult percent`)

table_7_data_contract <- fig_7_data_contract_names_fix |>
  dplyr::left_join(geo_table3b_import, by = c("ODS code" = "ODS code")) |>
  dplyr::mutate(`Provisional adult population` = format(`Provisional adult population`, big.mark = ","),
                `Adults seen` = format(`Adults seen`, big.mark = ","),
                `Financial year` = `Financial year.x`,
                `ICB name` = `ICB name.x`) |>
  dplyr::select(11,2,12,4,9,5)


# figure 7 - contract location

fig_7_data_adult_contract <- geo_table3e |>
  dplyr::select( `Financial year`,
                 ONS_LONG_CODE = `ONS code`,
                 `ODS code`,
                 `ICB name`,
                 `Provisional adult population` = `Adult population`,
                 `Provisional adult percent`) |>
  dplyr::mutate(across(where(is.numeric), round, 1)) |>
  arrange(desc(`Provisional adult percent`))

icb_geo_data <-
  icb_geo_data(
    "https://services1.arcgis.com/ESMARspQHYMw9BZ9/arcgis/rest/services/Integrated_Care_Boards_April_2023_EN_BSC/FeatureServer/0/query?outFields=*&where=1%3D1&f=geojson",
    SUB_GEOGRAPHY_CODE = "ICB23CD",
    SUB_GEOGRAPHY_NAME = "ICB23NM"
  )

nat_avg_adult_seen <- "39.8%"
minColor = "#fff"
maxColor = "#005EB8"
scale_rounding <- 10

map_adult_contract <- highcharter::highchart() %>%
  highcharter::hc_title(text = "") %>%
  highcharter::hc_subtitle(text = paste0("National mean: ", nat_avg_adult_seen)) %>%
  highcharter::hc_add_series_map(
    map = icb_geo_data,
    df = fig_7_data_adult_contract,
    name = "",
    value = "Provisional adult percent",
    joinBy = c("SUB_GEOGRAPHY_CODE", "ONS_LONG_CODE"),
    tooltip = list(
      headerFormat = "",
      pointFormat = paste0(
        "<b>{point.properties.SUB_GEOGRAPHY_NAME}:<br><b>{point.value}"
      )
    )
  ) %>%
  highcharter:: hc_colorAxis(
    minColor = minColor,
    maxColor = maxColor,
    min = round_any(min(geo_table3e$`Provisional adult percent`), scale_rounding, floor),
    max = round_any(max(geo_table3e$`Provisional adult percent`), scale_rounding, ceiling)
  ) %>%
  highcharter::hc_legend(verticalAlign = "bottom",
                         title = list(text = "Provisional adult population seen by a dentist (%)")) %>%
  highcharter::hc_tooltip(valueDecimals = 0) %>%
  highcharter::hc_mapNavigation(
    enabled = TRUE,
    enableMouseWheelZoom = TRUE,
    enableDoubleClickZoom = TRUE
  )|>
  highcharter::hc_credits(enabled = TRUE)

#figure 7 - patient location

fig_7_data_patient <- table_3f_geo_pat |>
  #filter out non-England located patients
  dplyr::filter(! `ICB name` %in% c("Unknown", "Other")) |>
  dplyr::select( `Financial year`,
                 `ODS code`,
                 `ICB name`,
                 `Provisional adult population` = `Adult population`,
                 `Provisional adult percent`) |>
  dplyr::mutate(across(where(is.numeric), round, 1),
                ADULT_PERCENT = `Provisional adult percent`,
                ICB_NAME = `ICB name`) |>
  arrange(desc(`Provisional adult percent`))

table_7_data_patient <- fig_7_data_patient |>
  dplyr::select(-c(ADULT_PERCENT,
                   ICB_NAME)) |>
  dplyr::left_join(table_3b_geo_pat, by = c("ICB name" = "ICB name")) |>
  dplyr::mutate(`Provisional adult population` = format(`Provisional adult population`, big.mark = ","),
                `Adults seen` = format(`Adults seen`, big.mark = ","),
                `Financial year` = `Financial year.x`,
                `ODS code` = `ODS code.x`) |>
  dplyr::select(11,12,3,4,9,5)

#comment out if focusing on maps this year
figure_7_patient <- fig_7_data_patient |>
  nhsbsaVis::basic_chart_hc(
    x = `ODS code`,
    y = `Provisional adult percent`,
    type = "column",
    xLab = "ICB ODS code",
    yLab = "Adult patients as percentage of population",
    dlOn = F,
    title = "") |>
  hc_tooltip(
    enabled = T,
    useHTML = TRUE,
    formatter = JS(
      "function(){
                            var result = this.point.ICB_NAME + '<br><b>Percent of adult population seen by dentist:</b> ' + this.point.ADULT_PERCENT.toFixed(0)
                            return result
             }"
    )
  ) |>
  hc_yAxis(labels = list(enabled = T))

fig_7_data_adult_patient <- table_3f_geo_pat |>
  dplyr::select( `Financial year`,
                 ONS_LONG_CODE = `ONS code`,
                 `ODS code`,
                 `ICB name`,
                 `Provisional adult population` = `Adult population`,
                 `Provisional adult percent`) |>
  dplyr::mutate(across(where(is.numeric), round, 1)) |>
  arrange(desc(`Provisional adult percent`))

map_adult_patient <- highcharter::highchart() %>%
  highcharter::hc_title(text = "") %>%
  highcharter::hc_subtitle(text = paste0("National mean: ", nat_avg_adult_seen)) %>%
  highcharter::hc_add_series_map(
    map = icb_geo_data,
    df = fig_7_data_adult_patient,
    name = "",
    value = "Provisional adult percent",
    joinBy = c("SUB_GEOGRAPHY_CODE", "ONS_LONG_CODE"),
    tooltip = list(
      headerFormat = "",
      pointFormat = paste0(
        "<b>{point.properties.SUB_GEOGRAPHY_NAME}:<br><b>{point.value}"
      )
    )
  ) %>%
  highcharter:: hc_colorAxis(
    minColor = minColor,
    maxColor = maxColor,
    min = round_any(min(geo_table3e$`Provisional adult percent`), scale_rounding, floor),
    max = round_any(max(geo_table3e$`Provisional adult percent`), scale_rounding, ceiling)
  ) %>%
  highcharter::hc_legend(verticalAlign = "bottom",
                         title = list(text = "Provisional adult population seen by a dentist (%)")) %>%
  highcharter::hc_tooltip(valueDecimals = 0) %>%
  highcharter::hc_mapNavigation(
    enabled = TRUE,
    enableMouseWheelZoom = TRUE,
    enableDoubleClickZoom = TRUE
  )|>
  highcharter::hc_credits(enabled = TRUE)

#Figure 8

#percentage of child patients seen out of population by ICB
fig_8_data_contract <- geo_table3e |>
  dplyr::select( `Financial year`,
                 `ODS code`,
                 `ICB name`,
                 `Provisional child population` = `Child population`, 
                 `Provisional child percent`) |>
  dplyr::mutate(across(where(is.numeric), round, 1),
                CHILD_PERCENT = `Provisional child percent`,
                ICB_NAME = `ICB name`) |>
  arrange(desc(`Provisional child percent`))

#comment out if focusing on maps this year
figure_8_contract <- fig_8_data_contract |>
  nhsbsaVis::basic_chart_hc(
    x = `ODS code`,
    y = `Provisional child percent`,
    type = "column",
    xLab = "ICB ODS code",
    yLab = "Child patients as percentage of population",
    dlOn = F,
    title = "") |>
  hc_tooltip(
    enabled = T,
    useHTML = TRUE,
    formatter = JS(
      "function(){
                            var result = this.point.ICB_NAME + '<br><b>Percent of child population seen by dentist:</b> ' + this.point.ADULT_PERCENT.toFixed(0)
                            return result
             }"
    )
  ) |>
  hc_yAxis(labels = list(enabled = T))

fig_8_data_contract_names_fix <- fig_8_data_contract |>
  dplyr::left_join(icb_lookup_distinct, by = c("ODS code" = "ICB23CDH")) |>
  select(`Financial year`,
         `ODS code`,
         `ICB name` = ICB23NM,
         `Provisional child population`,
         `Provisional child percent`)


table_8_data_contract <- fig_8_data_contract_names_fix |>
  dplyr::left_join(geo_table3b_import, by = c("ODS code" = "ODS code")) |>
  dplyr::mutate(`Provisional child population` = format(`Provisional child population`, big.mark = ","),
                `Children seen` = format(`Children seen`, big.mark = ","),
                `Financial year` = `Financial year.x`,
                `ICB name` = `ICB name.x`) |>
  dplyr::select(11,2,12,4,10,5)


# figure 8 - contract location

fig_8_data_child_contract <- geo_table3e |>
  dplyr::select( `Financial year`,
                 ONS_LONG_CODE = `ONS code`,
                 `ODS code`,
                 `ICB name`,
                 `Provisional child population` = `Child population`,
                 `Provisional child percent`) |>
  dplyr::mutate(across(where(is.numeric), round, 1)) |>
  arrange(desc(`Provisional child percent`))

nat_avg_child_seen <- "56.9%"
minColor = "#fff"
maxColor = "#005EB8"
scale_rounding <- 10

map_child_contract <- highcharter::highchart() %>%
  highcharter::hc_title(text = "") %>%
  highcharter::hc_subtitle(text = paste0("National mean: ", nat_avg_child_seen)) %>%
  highcharter::hc_add_series_map(
    map = icb_geo_data,
    df = fig_8_data_child_contract,
    name = "",
    value = "Provisional child percent",
    joinBy = c("SUB_GEOGRAPHY_CODE", "ONS_LONG_CODE"),
    tooltip = list(
      headerFormat = "",
      pointFormat = paste0(
        "<b>{point.properties.SUB_GEOGRAPHY_NAME}:<br><b>{point.value}"
      )
    )
  ) %>%
  highcharter:: hc_colorAxis(
    minColor = minColor,
    maxColor = maxColor,
    min = round_any(min(geo_table3e$`Provisional child percent`), scale_rounding, floor),
    max = round_any(max(geo_table3e$`Provisional child percent`), scale_rounding, ceiling)
  ) %>%
  highcharter::hc_legend(verticalAlign = "bottom",
                         title = list(text = "Provisional child population seen by a dentist (%)")) %>%
  highcharter::hc_tooltip(valueDecimals = 0) %>%
  highcharter::hc_mapNavigation(
    enabled = TRUE,
    enableMouseWheelZoom = TRUE,
    enableDoubleClickZoom = TRUE
  )|>
  highcharter::hc_credits(enabled = TRUE)

#figure 8 - patient location

fig_8_data_patient <- table_3f_geo_pat |>
  #filter out non-England located patients
  dplyr::filter(! `ICB name` %in% c("Unknown", "Other")) |>
  dplyr::select( `Financial year`,
                 `ODS code`,
                 `ICB name`,
                 `Provisional child population` = `Child population`,
                 `Provisional child percent`) |>
  dplyr::mutate(across(where(is.numeric), round, 1),
                CHILD_PERCENT = `Provisional child percent`,
                ICB_NAME = `ICB name`) |>
  arrange(desc(`Provisional child percent`))

table_8_data_patient <- fig_8_data_patient |>
  dplyr::select(-c(CHILD_PERCENT,
                   ICB_NAME)) |>
  dplyr::left_join(table_3b_geo_pat, by = c("ICB name" = "ICB name")) |>
  dplyr::mutate(`Provisional child population` = format(`Provisional child population`, big.mark = ","),
                `Children seen` = format(`Children seen`, big.mark = ","),
                `Financial year` = `Financial year.x`,
                `ODS code` = `ODS code.x`) |>
  dplyr::select(11,12,3,4,10,5)

#comment out if focusing on maps this year
figure_8_patient <- fig_8_data_patient |>
  nhsbsaVis::basic_chart_hc(
    x = `ODS code`,
    y = `Provisional child percent`,
    type = "column",
    xLab = "ICB ODS code",
    yLab = "child patients as percentage of population",
    dlOn = F,
    title = "") |>
  hc_tooltip(
    enabled = T,
    useHTML = TRUE,
    formatter = JS(
      "function(){
                            var result = this.point.ICB_NAME + '<br><b>Percent of child population seen by dentist:</b> ' + this.point.ADULT_PERCENT.toFixed(0)
                            return result
             }"
    )
  ) |>
  hc_yAxis(labels = list(enabled = T))

fig_8_data_child_patient <- table_3f_geo_pat |>
  dplyr::select( `Financial year`,
                 ONS_LONG_CODE = `ONS code`,
                 `ODS code`,
                 `ICB name`,
                 `Provisional child population` = `Child population`,
                 `Provisional child percent`) |>
  dplyr::mutate(across(where(is.numeric), round, 1)) |>
  arrange(desc(`Provisional child percent`))

map_child_patient <- highcharter::highchart() %>%
  highcharter::hc_title(text = "") %>%
  highcharter::hc_subtitle(text = paste0("National mean: ", nat_avg_child_seen)) %>%
  highcharter::hc_add_series_map(
    map = icb_geo_data,
    df = fig_8_data_child_patient,
    name = "",
    value = "Provisional child percent",
    joinBy = c("SUB_GEOGRAPHY_CODE", "ONS_LONG_CODE"),
    tooltip = list(
      headerFormat = "",
      pointFormat = paste0(
        "<b>{point.properties.SUB_GEOGRAPHY_NAME}:<br><b>{point.value}"
      )
    )
  ) %>%
  highcharter:: hc_colorAxis(
    minColor = minColor,
    maxColor = maxColor,
    min = round_any(min(geo_table3e$`Provisional child percent`), scale_rounding, floor),
    max = round_any(max(geo_table3e$`Provisional child percent`), scale_rounding, ceiling)
  ) %>%
  highcharter::hc_legend(verticalAlign = "bottom",
                         title = list(text = "Provisional child population seen by a dentist (%)")) %>%
  highcharter::hc_tooltip(valueDecimals = 0) %>%
  highcharter::hc_mapNavigation(
    enabled = TRUE,
    enableMouseWheelZoom = TRUE,
    enableDoubleClickZoom = TRUE
  )|>
  highcharter::hc_credits(enabled = TRUE)





#Workforce ---------------------------------------------------------------------

#TO DO: check numbers again once workforce excel table is finalised

#Figure 9 national workforce total by financial year

#pull in workforce xlsx table 1a numbers for dentists by year

figure_9 <- table_1a_wf |>
  nhsbsaVis::basic_chart_hc(
    x = `Financial year`,
    y = `Dentists`,
    type = "line",
    xLab = "Financial year",
    yLab = "Number of NHS dentists",
    title = "") |>
  hc_subtitle(text = "K = Thousands",
              align = "left") |>
  highcharter::hc_yAxis(min = 0)

table_9_data <- table_1a_wf |>
  dplyr::select(`Financial year`,
                Dentists) |>
  dplyr::mutate(`Number of NHS dentists` = format(Dentists, big.mark = ",")) |>
  dplyr::select(-(Dentists))

#Table 10 dental map by ICB dentists per 100,000 population

#national average uses 2024 population estimate for England

nat_avg_dentists <- "42"

#ICB averages use 2022 population estimates by ICB

fig_10_data_dentist <- table_2b_wf |>
  #filter out non-England located patients, H&Js, and regions
  dplyr::filter(! `Area name` %in% c("Unknown"),
                ! `ODS code` %in% c("HJ1",
                                    "HJ2",
                                    "HJ3",
                                    "HJ4",
                                    "HJ5",
                                    "HJ6",
                                    "HJ7",
                                    "Y56",
                                    "Y58",
                                    "Y59",
                                    "Y60",
                                    "Y61",
                                    "Y62",
                                    "Y63"),
                `Financial year` == "2024/2025") |>
  dplyr::select( `Financial year`,
                 `ODS code`,
                 `ONS code`,
                 `ICB name` = `Area name`,
                 `Dentists`,
                 `Population`,
                 `Dentists per 100,000 population`) |>
  dplyr::mutate(across(where(is.numeric), round, 1),
                DENTISTS_PER_POP = `Dentists per 100,000 population`,
                ICB_NAME = `ICB name`) |>
  arrange(desc(`Dentists per 100,000 population`))

table_10_data_dentist <- fig_10_data_dentist |>
  dplyr::select(-c(DENTISTS_PER_POP,
                   ICB_NAME)) |>
  dplyr::mutate(`Dentists per 100,000 population` = format(`Dentists per 100,000 population`, big.mark = ","),
                `Dentists` = format(`Dentists`, big.mark = ","),
                `Population` = format(`Population`, big.mark = ","),
                `Mid-year population year` = "2022") |>
  dplyr::select(1,2,3,4,5,8,6,7)

#TO DO: change fig_10_data_dentist above to include thousand separator
table_10_data_dentist_formatted <- fig_10_data_dentist |>
  dplyr::select(-c(DENTISTS_PER_POP,
                   ICB_NAME)) |>
  dplyr::mutate(`Mid-year population year` = "2022") |>
  dplyr::select(1,2,3,4,5,8,6,7)

#comment out if focusing on maps this year
figure_10_patient <- fig_10_data_dentist |>
  nhsbsaVis::basic_chart_hc(
    x = `ODS code`,
    y = `Dentists per 100,000 population`,
    type = "column",
    xLab = "ICB ODS code",
    yLab = "Dentists per 100,000 population",
    dlOn = F,
    title = "") |>
  hc_tooltip(
    enabled = T,
    useHTML = TRUE,
    formatter = JS(
      "function(){
                            var result = this.point.ICB_NAME + '<br><b>NHS dentists per 100,000 population:</b> ' + this.point.DENTISTS_PER_POP.toFixed(0)
                            return result
             }"
    )
  ) |>
  hc_yAxis(labels = list(enabled = T))

map_dentist_pop <- highcharter::highchart() %>%
  highcharter::hc_title(text = "") %>%
  highcharter::hc_subtitle(text = paste0("National mean: ", nat_avg_dentists)) %>%
  highcharter::hc_add_series_map(
    map = icb_geo_data,
    df = fig_10_data_dentist,
    name = "",
    value = "Dentists per 100,000 population",
    joinBy = c("SUB_GEOGRAPHY_CODE", "ONS code"),
    tooltip = list(
      headerFormat = "",
      pointFormat = paste0(
        "<b>{point.properties.SUB_GEOGRAPHY_NAME}:<br><b>{point.value}"
      )
    )
  ) %>%
  highcharter:: hc_colorAxis(
    minColor = minColor,
    maxColor = maxColor,
    min = round_any(min(fig_10_data_dentist$`Dentists per 100,000 population`), scale_rounding, floor),
    max = round_any(max(fig_10_data_dentist$`Dentists per 100,000 population`), scale_rounding, ceiling)
  ) %>%
  highcharter::hc_legend(verticalAlign = "bottom",
                         title = list(text = "NHS dentists per 100,000 population")) %>%
  highcharter::hc_tooltip(valueDecimals = 0) %>%
  highcharter::hc_mapNavigation(
    enabled = TRUE,
    enableMouseWheelZoom = TRUE,
    enableDoubleClickZoom = TRUE
  )|>
  highcharter::hc_credits(enabled = TRUE)

