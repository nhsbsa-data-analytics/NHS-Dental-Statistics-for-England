### Pipeline to run PfD annual publication
# clear environment
rm(list = ls())

# source functions
# this is only a temporary step until all functions are built into packages

# select all .R files in functions sub-folder
function_files <- list.files(path = "functions", pattern = "\\.R$")

# loop over function_files to source all files in functions sub-folder
for (file in function_files) {
  source(file.path("functions", file))
}

# 1. Setup ---------------------------------------------------------------------

# load GITHUB_KEY if available in environment or enter if not

if (Sys.getenv("GITHUB_PAT") == "") {
  usethis::edit_r_environ()
  stop(
    "You need to set your GITHUB_PAT = YOUR PAT KEY in the .Renviron file which pops up. Please restart your R Studio after this and re-run the pipeline."
  )
}

# load DB_DWCP_USERNAME if available in environment or enter if not

if (Sys.getenv("DB_DWCP_USERNAME") == "") {
  usethis::edit_r_environ()
  stop(
    "You need to set your DB_DWCP_USERNAME = YOUR DWCP USERNAME and  DB_DWCP_PASSWORD = YOUR DWCP PASSWORD in the .Renviron file which pops up. Please restart your R Studio after this and re-run the pipeline."
  )
}

install.packages("devtools")
library(devtools)

# install nhsbsaUtils package first as need check_and_install_packages()
devtools::install_github("nhsbsa-data-analytics/nhsbsaUtils",
                         auth_token = Sys.getenv("GITHUB_PAT"))

library(nhsbsaUtils)

# install and library packages
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

# 2. connect to DWH and pull max CY/FY  ----------------------------------------

# build connection to warehouse
con <- nhsbsaR::con_nhsbsa(dsn = "FBS_8192k",
                           driver = "Oracle in OraClient19Home1",
                           "DWCP")

# 3. collect raw data ------------------------------------------

# 4. Build excel tables --------------------------------------------

# 5. build charts and tables -----------------------------------------------------

# 6. create markdowns ----------------------------------------------------------

# save narrative summary as html file into outputs folder
# change file path to save somewhere else if needed
rmarkdown::render("dental_narrative_v001.Rmd",
                  output_format = "html_document",
                  output_file = "outputs/dental_narrative__2023_24_v001.html")

# save copy as word document for use in quality review
rmarkdown::render("dental_narrative_v001.Rmd",
                  output_format = "word_document",
                  output_file = "outputs/dental_narrative__2023_24_v001.docx")

# save background document as html file into outputs folder
# change file path to save somewhere else if needed
rmarkdown::render("dental_background_v001.Rmd",
                  output_format = "html_document",
                  output_file = "outputs/dental_background_info_methodology_v001.html")

rmarkdown::render("dental_background_v001.Rmd",
                  output_format = "word_document",
                  output_file = "outputs/dental_background_info_methodology_v001.docx")


# 8. disconnect from DWH  ------------------------------------------------------

DBI::dbDisconnect(con)
