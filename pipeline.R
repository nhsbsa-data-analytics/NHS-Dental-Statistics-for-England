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
makeSheet <- menu(c("Yes", "No"),
                  title = "Do you wish to generate the Excel outputs?")

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
    "nhsbsa-data-analytics/nhsbsaExternalData",
    "nhsbsa-data-analytics/accessibleTables",
    "nhsbsa-data-analytics/nhsbsaDataExtract",
    "nhsbsa-data-analytics/nhsbsaVis"
  )

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

# 3. Aggregations and analysis - activity data ---------------------------------






# 4. Aggregations and analysis - workforce data --------------------------------




# Disconnect from data warehouse once all data extracted and aggregated
DBI::dbDisconnect(con)

# 5. Data tables ---------------------------------------------------------------





# 6. Charts and figures --------------------------------------------------------





# 7. Render outputs ------------------------------------------------------------

# save narrative summary as html file into outputs folder
# change file path to save somewhere else if needed
rmarkdown::render("dental_narrative_v001.Rmd",
                  output_format = "html_document",
                  output_file = "outputs/dental_narrative_2024_25_v001.html")

# save copy as word document for use in quality review
rmarkdown::render("dental_narrative_v001.Rmd",
                  output_format = "word_document",
                  output_file = "outputs/dental_narrative_2024_25_v001.docx")

# save background document as html file into outputs folder
# change file path to save somewhere else if needed
rmarkdown::render("dental_background_v001.Rmd",
                  output_format = "html_document",
                  output_file = "outputs/dental_background_info_methodology_v001.html")

rmarkdown::render("dental_background_v001.Rmd",
                  output_format = "word_document",
                  output_file = "outputs/dental_background_info_methodology_v001.docx")






# 8. Accessibility testing (in progress) ---------------------------------------





# 9. Automated Quality Review testing (in progress) ----------------------------