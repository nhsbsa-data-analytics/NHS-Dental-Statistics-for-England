# Main pipeline script for NHS Dental official statistics publication
# this script calls on other scripts from the NHS-Dental-Statistics-for-England repository

# contains the following sections:
# 1. Setup and package installation
# 2. Data import
# 3. Aggregations and analysis - activity data
# 4. Aggregations and analysis - workforce data
# 5. Data tables
# 6. Charts and figures
# 7. Render outputs
# 8. Accessibility testing (in progress)
# 9. Automated Quality Review testing (in progress)

# clear environment
rm(list = ls())

# source functions
# select all .R files in functions sub-folder
function_files <- list.files(path = "functions", pattern = "\\.R$")

# loop over function_files to source all files in functions sub-folder
for (file in function_files) {
  source(file.path("functions", file))
}

#1. Setup and package installation ---------------------------------------------

# load GITHUB_KEY if available in environment or enter if not
if (Sys.getenv("GITHUB_PAT") == "") {
  usethis::edit_r_environ()
  stop(
    "You need to set your GITHUB_PAT = YOUR PAT KEY in the .Renviron file which pops up. Please restart your R Studio after this and re-run the pipeline."
  )
}

# load database credentials if available in environment or enter if not
if (Sys.getenv("DB_DWCP_USERNAME") == "") {
  usethis::edit_r_environ()
  stop(
    "You need to set your DB_DWCP_USERNAME = YOUR DWCP USERNAME and  DB_DWCP_PASSWORD = YOUR DWCP PASSWORD in the .Renviron file which pops up. Please restart your R Studio after this and re-run the pipeline."
  )
}

# check if Excel outputs are required
makeSheet <- menu(c("Yes", "No"), title = "Do you wish to generate the Excel outputs?")

# install and load devtools package
install.packages("devtools")
library(devtools)

# install nhsbsaUtils package first to use function check_and_install_packages()
devtools::install_github(
  "nhsbsa-data-analytics/nhsbsaUtils",
  auth_token = Sys.getenv("GITHUB_PAT"),
  force = TRUE
)

# load nhsbsaUtils package
library(nhsbsaUtils)

# install and library all other required packages
req_pkgs <-
  c(
    "dplyr",
    "stringr",
    "data.table",
    "yaml",
    "openxlsx",
    "rmarkdown",
    "highcharter",
    "lubridate",
    "dbplyr",
    "tidyr",
    "janitor",
    "magrittr",
    "tcltk",
    "DT",
    "htmltools",
    "geojsonsf",
    "readxl",
    "kableExtra",
    "nhsbsa-data-analytics/nhsbsaR",
    #    "nhsbsa-data-analytics/nhsbsaExternalData", #not currently needed, population data loaded via custom functions
    "nhsbsa-data-analytics/accessibleTables",
    "nhsbsa-data-analytics/nhsbsaDataExtract",
    "nhsbsa-data-analytics/nhsbsaVis",
    "sf",
    "svDialogs",
    "zoo"
  )

devtools::install_github(
  "nhsbsa-data-analytics/nhsbsaVis",
  auth_token = Sys.getenv("GITHUB_PAT"),
  force = TRUE
)

#TO DO: set up logging using logr package
#library(logr)

# library/install packages as required
nhsbsaUtils::check_and_install_packages(req_pkgs)

# load config
config <- yaml::yaml.load_file("config.yml")

# load options
nhsbsaUtils::publication_options()

#2. Data import ----------------------------------------------------------------

##2.1 Population data

#call pop_data_import.R script from RAP
#imports ONS mid-year population estimates for:
#Ward, SICBL, ICB and NHS Region for 2019 to 2022 (latest available at time of production)
#Local Authority (LA) and England National for 2019 to 2024

source("pop_data_import.R")

#set up connection details
#for use when sourcing extract files in section 3

con <- nhsbsaR::con_nhsbsa(dsn = "FBS_8192k", driver = "Oracle in OraClient19Home1", "DWCP")

#alternative dsn argument for function if above causes error
# con <- nhsbsaR::con_nhsbsa(dsn = NULL,
#                            driver = "Oracle in OraClient19Home1",
#                            database = "DWCP")

#2.2 Geography lookups

#general lookup for NHS geographies, SICBL to ICB to Region
nhs_lookups <- get_lsoa_icb_lookups()

#NHS England Region codes have changed between 2023 and 2024
#As patient location data joins to the National Statistics Postcode Lookup (NSPL),
#2021, 2022, 2024 Region codes are also needed to map across datasets and time periods.
region_lookup <- get_region_lookup()

#Get names and codes lookups for other levels used in geo tables

#icb_lookup <- get_icb_lookup()

#icb_lookup <- nhs_lookups$region_23

icb_lookup <- nhs_lookups$region_23 |>
  dplyr::select(-c(SICBL23CD, SICBL23CDH, SICBL23NM, ObjectId)) |>
  dplyr::distinct()

#check if using commented out version of get_la_lookup()
#as this is required for 1-1 match of 2023 LAD name to 2023 LAD code
la_lookup <- get_la_lookup() |>
  dplyr::select(-(LAD22CD)) |>
  dplyr::filter(!(is.na(LAD23CD)))

ward_lookup <- get_ward_lookup()

# 3. Aggregations and analysis - activity data ---------------------------------

#define values for use in data extracts and formatting

#Check if code works when added to config file instead
#values for patients seen tables
first_patients_seen_date <-
  as.POSIXct(paste(substr(first_year, 1, 4), "09", "30", sep = "-")) ## Sept 30th
last_patients_seen_date  <-
  as.POSIXct(paste(substr(last_year, 6, 9), "07", "01", sep = "-")) ## July 1st

#3.1 Contract location - national activity overview tables

#extract and aggregate data from SQL tables
source("import_contract_activity_national_tables.R")

#format data and write tables xlsx file
source("create_nat_cont_activity_excel.R")

#3.2 Contract location - geographical breakdown activity tables

#extract data from SQL tables and join population estimates data
source("import_contract_activity_geo_tables.R")

#format data and write tables xlsx file
source("create_geo_cont_activity_excel.R")

#3.3 Patient location - geographical breakdown activity tables

source("import_patient_activity_geo_tables.R")

#format data and write tables xlsx file
source("create_geo_pat_activity_excel.R")

# 4. Aggregations and analysis - workforce data --------------------------------

#4.4 NHS dental workforce - England

#TO DO: tidy workforce pipeline script, rename
source("england_workforce_pipeline_2425.R")

#format data and write tables xlsx file
source("create_geo_cont_workforce_excel.R")

#4.5 NHS dental workforce - Wales
#optional code to run if producing outputs to send to Welsh team

#may need to run some lines of commented out code in script manually
#depending on whether Dental Care Professionals (DCPs) are to be removed from final totals
#(sourcing script with no changes will keep DCPs in outputs)

#xlsx files created within main Wales workforce pipeline, no separate xlsx script
source("wales_workforce_pipeline_2425.R")

# 5. Data tables ---------------------------------------------------------------

#placeholder for running CSVs code scripts for granular data extracts

# Disconnect from data warehouse once all data extracted and aggregated
DBI::dbDisconnect(con)

# 6. Charts and figures --------------------------------------------------------

#script to create highcharter charts
#and create datasets for narrative tables and data download button
#required to render chart code chunks in narrative markdown file in section 7

source("create_chart_data.R")

# 7. Render outputs ------------------------------------------------------------

# save narrative summary as html file into outputs folder
# change file path to save somewhere else if needed
rmarkdown::render(
  "dental_narrative_2425_v001.Rmd",
  output_format = "html_document",
  output_file = "outputs/dental_narrative_2024_25_v001.html"
)

# save copy as word document for use in quality review (QR) process
rmarkdown::render(
  "dental_narrative_2425_v001.Rmd",
  output_format = "word_document",
  output_file = "outputs/dental_narrative_2024_25_v001.docx"
)

# save background document as html file into outputs folder
# change file path to save somewhere else if needed
rmarkdown::render(
  "dental_background_2425_v001.Rmd",
  output_format = "html_document",
  output_file = "outputs/dental_background_2425_v001.html"
)

# save copy as word document for use in QR process
rmarkdown::render(
  "dental_background_2425_v001.Rmd",
  output_format = "word_document",
  output_file = "outputs/dental_background_2425_v001.docx"
)


# 8. Accessibility testing (in progress) ---------------------------------------

#check colours used in charts and narrative for contrast and colour blindness issues

# 9. Automated Quality Review testing (in progress) ----------------------------