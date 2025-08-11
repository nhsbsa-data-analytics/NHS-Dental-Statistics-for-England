#script to format data to build national excel files
#for contract location activity tables
#this script to be called in main `pipeline.R` script
#functions loaded in main pipeline

# Create sheets ready for export to Excel ---------------------------------
sheetNames <- c(
  "Table_1a_i",
  "Table_1a_ii",
  "Table_1b_i",
  "Table_1b_ii",
  "Table_1c",
  "Table_1d",
  "Table_1e_i",
  "Table_1e_ii",
  "Table_1f",
  "Table_1g_i",
  "Table_1g_ii",
  "Table_2a_i",
  "Table_2a_ii",
  "Table_2b_i",
  "Table_2b_ii",
  "Table_2c",
  "Table_2d",
  "Table_2e_i",
  "Table_2e_ii",
  "Table_3a",
  "Table_4a",
  "Table_4b",
  "Table_4c",
  "Table_4d",
  "Table_5a",
  "Table_5b",
  "Table_5c",
  "Table_5d",
  "Table_6a",
  "Table_6b",
  "Table_6c"
)

wb <- accessibleTables::create_wb(sheetNames)

# create metadata tab (will need to open file and auto row heights once ran)
meta_fields <- c(
  "Financial year",
  "Financial quarter",
  "Treatment band",
  "Course of treatment (COT)",
  "Unit of dental activity (UDA)",
  "Unit of orthodontic activity (UOA)",
  "Patient type",
  "Exemption type",
  "Adult patients seen",
  "Child patients seen",
  "Age group",
  "Date",
  "Mid-year England population estimate",
  "Mid-year population year",
  "Clinical treatment",
  "Patient charge revenue (GBP)",
  "Cost of treatment delivered to exempt patient groups"
)

meta_descs <-
  c("The financial year to which the data belongs. For example, 2024/2025. Data from previous financial years may have been 
    affected by the COVID-19 pandemic. You can find more information on this in the background and methodology document.",
    "The financial quarter to which the data belongs. For example, 2024/2025 Q1.",
    "NHS dental activity is broken down into treatment bands based on how complex the treatment is. For example, a dental crown
    is a band 3 treatment. For activity with a date of acceptance from November 2022 onwards, band 2 treatments are further broken
    down into sub-bands 2a, 2b, and 2c.",
    "A COT is a course of treatment, usually begun after a dentist examines a patient and agrees treatment is required. COTs have
    been calculated by counting the number of valid FP17 claim forms. COT counts in this publication exclude orthodontic activity 
    unless specified.",
    "A UDA is a unit of dental activity, which a dental contract can be awarded after submitting a valid FP17 form. A
    general dental COT can receive a set number of UDAs based on treatment band. For example, a COT of band 2a will generally be
    awarded 3 UDA. Late submissions may have the UDA they receive reduced to 0.",
    "A UOA is a unit of orthodontic activity, which a dental contract can receive after submitting a valid FP17 form. How 
    many UOAs are awarded depends on a patient's age on the date of assessment. For example, an orthodontic COT for 
    \"assessment and appliance fitted\" for a patient aged under 10 will generally be awarded 4 UOA.",
    "The patient type column groups patients according to whether they are a child, an exempt adult, or a non-exempt adult.",
    "Exemption type is the exemption group of the patient. Adults undergoing NHS dental activity normally pay a set amount
    of money towards treatment, unless they have a valid exemption. Children aged under 18 at the start of treatment, or
    under 19 and in full-time education, do not pay for treatment. More information on patient charges and exemptions
    can by found in the background and methodology document.",
    "A count of patients aged 18 or over seen by an NHS dentist in the 24 months up to the end of the specified period.",
    "A count of patients aged 17 or under seen by an NHS dentist in the 12 months up to the end of the specified period.",
    "The age group which the data has been aggregated up to, where age is the age of a patient at the date of acceptance
    for treatment. For example, age group 18-64 includes all patients aged 18 to 64.",
    "The date of the specified period.",
    "The population estimate for the corresponding mid-year population year. National mid-year population estimates
    have been taken from the latest ONS population estimates at time of publication.
    The estimates are available from: https://www.ons.gov.uk/peoplepopulationandcommunity/populationandmigration/populationestimates/datasets/estimatesofthepopulationforenglandandwales",
    "The year in which the Office for National Statistics (ONS) mid-year population estimates were taken,
    required due to the presentation of this data in financial year format.",
    "The clinical treatment listed on the FP17 form. For example, scale and polish.",
    "Adults undergoing NHS dental activity normally pay a set amount of money towards treatment, unless they have a valid exemption.
    The cost depends on what treatment is needed. Patient charge revenue is measured in GBP and is the total of the patient
    charges received for treatment over the specified period.",
    "The cost of treatment in this table is an estimated total of how much patients with an exemption would have paid if they were not exempt. This cost has not actually been collected from patients.")

accessibleTables::create_metadata(wb,
                                  meta_fields,
                                  meta_descs)

#Sheet for : Table_1a_i ---------------------------------
accessibleTables::write_sheet(
  workbook = wb,
  sheetname = "Table_1a_i",
  title = paste0("Table_1a_i: Count of courses of treatment by treatment band and financial year, ", config$table_sheet_title_fy),
  notes = c("1. Some cells in this table are empty because band 2 sub-bands were not used until 2022/2023.",
            "2. Band 2 sub-bands were introduced in November 2022. Due to the length of time some treatments may take, it is possible for data prior to the introduction of sub-bands to still occur past this point."),
  dataset = table1ai,
  column_a_width = 20
)

accessibleTables::format_data(wb,
                              "Table_1a_i",
                              c("A"),
                              "left",
                              "")

accessibleTables::format_data(wb,
                              "Table_1a_i",
                              c("B", "C", "D", "E", "F", "G", "H", "I", "J", "K"),
                              "right",
                              "#,###0")

openxlsx::setColWidths(
  wb,
  "Table_1a_i",
  c("A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K"),
  widths = c(20, 17, 14, 14, 14, 14, 14, 14, 14, 37, 14)
)

#Sheet for : Table_1a_ii ---------------------------------
accessibleTables::write_sheet(
  workbook = wb,
  sheetname = "Table_1a_ii",
  title = paste0("Table_1a_ii: Count of courses of treatment by treatment band and financial quarter, ", config$table_sheet_title_fy),
  notes = c("1. Some cells in this table are empty because band 2 sub-bands were not used until 2022/2023."),
  dataset = table1aii,
  column_a_width = 20
)

accessibleTables::format_data(wb,
                              "Table_1a_ii",
                              c("A", "B"),
                              "left",
                              "")

accessibleTables::format_data(wb,
                              "Table_1a_ii",
                              c("C", "D", "E", "F", "G", "H", "I", "J", "K", "L"),
                              "right",
                              "#,###0")

openxlsx::setColWidths(
  wb,
  "Table_1a_ii",
  c("B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L"),
  widths = c(20, 14, 14, 14, 14, 14, 14, 14, 14, 37, 14)
)

#Sheet for : Table_1b_i ---------------------------------
accessibleTables::write_sheet(
  workbook = wb,
  sheetname = "Table_1b_i",
  title = paste0("Table_1b_i: Percentage of courses of treatment by treatment band and financial year, ", config$table_sheet_title_fy),
  notes = c("1. Some cells in this table are empty because band 2 sub-bands were not used until 2022/2023."),
  dataset = table1bi,
  column_a_width = 20
)

accessibleTables::format_data(wb,
                              "Table_1b_i",
                              c("A"),
                              "left",
                              "")

accessibleTables::format_data(wb,
                              "Table_1b_i",
                              c("B", "C", "D", "E", "F", "G", "H", "I", "J", "K"),
                              "right",
                              "#,###0.0")

openxlsx::setColWidths(
  wb,
  "Table_1b_i",
  c("A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K"),
  widths = c(20, 14, 14, 14, 14, 14, 14, 14, 14, 37, 14)
)

#Sheet for : Table_1b_ii ---------------------------------
accessibleTables::write_sheet(
  workbook = wb,
  sheetname = "Table_1b_ii",
  title = paste0("Table_1b_ii: Percentage of courses of treatment by treatment band and financial quarter, ", config$table_sheet_title_fy),
  notes = c("1. Some cells in this table are empty because band 2 sub-bands were not used until 2022/2023."),
  dataset = table1bii,
  column_a_width = 20
)

accessibleTables::format_data(wb,
                              "Table_1b_ii",
                              c("A", "B"),
                              "left",
                              "")

accessibleTables::format_data(wb,
                              "Table_1b_ii",
                              c("C", "D", "E", "F", "G", "H", "I", "J", "K", "L"),
                              "right",
                              "#,###0.0")

openxlsx::setColWidths(
  wb,
  "Table_1b_ii",
  c("A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L"),
  widths = c(20, 17, 14, 14, 14, 14, 14, 14, 14, 14, 37, 14)
)

#Sheet for : Table_1c ---------------------------------
accessibleTables::write_sheet(
  workbook = wb,
  sheetname = "Table_1c",
  title = paste0("Table_1c: Courses of treatment by treatment band, patient type and financial year, ", config$table_sheet_title_fy),
  notes = c("1. Some cells in this table are empty because data was not available for the time period. Band 2 sub-bands were introduced for treatment with a date of acceptance on or after 25 November 2022.",
            "2. Patient type can be exempt, non-exempt, or child. A child is classed as being aged 17 or under at the time that treatment starts. Exempt patients do not pay patient charges towards their treatment, but do not have an age exemption."),
  dataset = table1c_excel,
  column_a_width = 20
)

accessibleTables::format_data(wb,
                              "Table_1c",
                              c("A", "B"),
                              "left",
                              "")

accessibleTables::format_data(wb,
                              "Table_1c",
                              c("C", "D", "E", "F", "G", "H", "I", "J", "K", "L"),
                              "right",
                              "#,###0")

openxlsx::setColWidths(
  wb,
  "Table_1c",
  c("A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L"),
  widths = c(20, 16, 14, 14, 14, 14, 14, 14, 14, 14, 37, 14)
)

#Sheet for : Table_1d ---------------------------------
accessibleTables::write_sheet(
  workbook = wb,
  sheetname = "Table_1d",
  title = paste0("Table_1d: Percentage of courses of treatment by treatment band, patient type and financial year, ", config$table_sheet_title_fy),
  notes = c("1. Some cells in this table are empty because data was not available for the time period. Band 2 sub-bands were introduced for treatment with a date of acceptance on or after 25 November 2022.",
            "2. Patient type can be exempt, non-exempt, or child. A child is classed as being aged 17 or under at the time that treatment starts. Exempt patients do not pay patient charges towards their treatment, but do not have an age exemption."),
  dataset = table1d,
  column_a_width = 20
)

accessibleTables::format_data(wb,
                              "Table_1d",
                              c("A", "B"),
                              "left",
                              "")

accessibleTables::format_data(wb,
                              "Table_1d",
                              c("C", "D", "E", "F", "G", "H", "I", "J", "K", "L"),
                              "right",
                              "#,###0.0")

openxlsx::setColWidths(
  wb,
  "Table_1d",
  c("A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L"),
  widths = c(20, 16, 14, 14, 14, 14, 14, 14, 14, 14, 37, 14)
)

#Sheet for : Table 1e_i ---------------------------------
accessibleTables::write_sheet(
  workbook = wb,
  sheetname = "Table_1e_i",
  title = paste0("Table 1e_i: Percentage of courses of treatment by patient type, treatment band and financial year, ", config$table_sheet_title_fy),
  notes = c("1. Some cells in this table are empty because data was not available for the time period. Band 2 sub-bands were introduced for treatment with a date of acceptance on or after 25 November 2022.",
            "2. Patient type can be exempt, non-exempt, or child. A child is classed as being aged 17 or under at the time that treatment starts. Exempt patients do not pay patient charges towards their treatment, but do not have an age exemption."),
  dataset = table1ei,
  column_a_width = 20
)

accessibleTables::format_data(wb,
                              "Table_1e_i",
                              c("A", "B"),
                              "left",
                              "")

accessibleTables::format_data(wb,
                              "Table_1e_i",
                              c("C", "D", "E", "F"),
                              "right",
                              "#,###0.0")

openxlsx::setColWidths(wb,
                       "Table_1e_i",
                       c("A", "B", "C", "D", "E", "F"),
                       widths = c(20, 32, 17, 17, 17, 17))



#Sheet for : Table_1e_ii ---------------------------------
accessibleTables::write_sheet(
  workbook = wb,
  sheetname = "Table_1e_ii",
  title = paste0("Table 1e_ii: Percentage of courses of treatment by patient type and financial year, ", config$table_sheet_title_fy),
  notes = c("1. Patient type can be exempt, non-exempt, or child. A child is classed as being aged 17 or under at the time that treatment starts. Exempt patients do not pay patient charges towards their treatment, but do not have an age exemption."),
  dataset = table1eii,
  column_a_width = 20
)

accessibleTables::format_data(wb,
                              "Table_1e_ii",
                              c("A"),
                              "left",
                              "")

accessibleTables::format_data(wb,
                              "Table_1e_ii",
                              c("B", "C", "D", "E"),
                              "right",
                              "#,###0.0")

openxlsx::setColWidths(wb,
                       "Table_1e_ii",
                       c("A", "B", "C", "D", "E"),
                       widths = c(20, 14, 18, 14, 14))

#Sheet for : Table_1f ---------------------------------
accessibleTables::write_sheet(
  workbook = wb,
  sheetname = "Table_1f",
  title = paste0("Table_1f: Courses of treatment by patient exemption type, treatment band, and financial year, ", config$table_sheet_title_fy),
  notes = c("1. In exemption type, a child is classed as being aged 17 or under at the time that treatment starts. The paying adult category is included in this table for reference and contains adult patients who do not have a full or partial exemption from patient charges towards their treatment.",
            "2. Some cells in this table are empty because data was not available for the time period. Band 2 sub-bands were introduced for treatment with a date of acceptance on or after 25 November 2022."),
  dataset = table1f,
  column_a_width = 20
)

accessibleTables::format_data(wb,
                              "Table_1f",
                              c("A", "B"),
                              "left",
                              "")

accessibleTables::format_data(wb,
                              "Table_1f",
                              c("C", "D", "E", "F", "G", "H", "I", "J", "K", "L"),
                              "right",
                              "#,###0")

openxlsx::setColWidths(
  wb,
  "Table_1f",
  c("A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L"),
  widths = c(20, 55, 14, 14, 14, 14, 14, 14, 14, 14, 37, 14)
)

#Sheet for : Table_1g_i ---------------------------------
accessibleTables::write_sheet(
  workbook = wb,
  sheetname = "Table_1g_i",
  title = paste0("Table_1g_i: Courses of treatment by Dental Care Professional type, treatment band, and financial year, ", config$table_sheet_title_dcp_years),
  notes = c("notes go here"),
  dataset = table1gi,
  column_a_width = 20
)

accessibleTables::format_data(wb,
                              "Table_1g_i",
                              c("A", "B", "C"),
                              "left",
                              "")

accessibleTables::format_data(wb,
                              "Table_1g_i",
                              c("D", "E", "F", "G", "H", "I", "J", "K", "L", "M"),
                              "right",
                              "#,###0")

openxlsx::setColWidths(
  wb,
  "Table_1g_i",
  c("A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M"),
  widths = c(20, 37, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14, 14)
)

#Sheet for : Table_1g_ii ---------------------------------
accessibleTables::write_sheet(
  workbook = wb,
  sheetname = "Table_1g_ii",
  title = paste0("Table_1g_ii: Courses of treatment by Dental Care Professional type, treatment band, and financial quarter, ", config$table_sheet_title_dcp_years),
  notes = c("notes go here"),
  dataset = table1aii,
  column_a_width = 20
)

accessibleTables::format_data(wb,
                              "Table_1g_ii",
                              c("A", "B", "C", "D"),
                              "left",
                              "")

accessibleTables::format_data(wb,
                              "Table_1g_ii",
                              c("E", "F", "G", "H", "I", "J", "K", "L", "M", "N"),
                              "right",
                              "#,###0")

openxlsx::setColWidths(
  wb,
  "Table_1g_ii",
  c("B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N"),
  widths = c(17, 14, 14, 14, 14, 14, 14, 14, 14, 37, 14, 14, 14)
)


#Sheet for : Table_2a_i ---------------------------------
accessibleTables::write_sheet(
  workbook = wb,
  sheetname = "Table_2a_i",
  title = paste0("Table_2a_i: Count of units of dental activity by treatment band and financial year, ", config$table_sheet_title_fy),
  notes = c("1. Some cells in this table are empty because data was not available for the time period. Band 2 sub-bands were introduced for treatment with a date of acceptance on or after 25 November 2022."),
  dataset = table2ai,
  column_a_width = 20
)

accessibleTables::format_data(wb,
                              "Table_2a_i",
                              c("A"),
                              "left",
                              "")

accessibleTables::format_data(wb,
                              "Table_2a_i",
                              c("B", "C", "D", "E", "F", "G", "H", "I", "J", "K"),
                              "right",
                              "#,###0")

openxlsx::setColWidths(
  wb,
  "Table_2a_i",
  c("A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K"),
  widths = c(20, 17, 14, 14, 14, 14, 14, 14, 14, 37, 14)
)

#Sheet for : Table_2a_ii ---------------------------------
accessibleTables::write_sheet(
  workbook = wb,
  sheetname = "Table_2a_ii",
  title = paste0("Table_2a_ii: Count of units of dental activity by treatment band and financial quarter, ", config$table_sheet_title_fy),
  notes = c("1. Some cells in this table are empty because data was not available for the time period. Band 2 sub-bands were introduced for treatment with a date of acceptance on or after 25 November 2022."),
  dataset = table2aii,
  column_a_width = 20
)

accessibleTables::format_data(wb,
                              "Table_2a_ii",
                              c("A", "B"),
                              "left",
                              "")

accessibleTables::format_data(wb,
                              "Table_2a_ii",
                              c("C", "D", "E", "F", "G", "H", "I", "J", "K", "L"),
                              "right",
                              "#,###0")

openxlsx::setColWidths(
  wb,
  "Table_2a_ii",
  c("A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L"),
  widths = c(20, 17, 14, 14, 14, 14, 14, 14, 14, 14, 37, 14)
)

#Sheet for : Table_2b_i ---------------------------------
accessibleTables::write_sheet(
  workbook = wb,
  sheetname = "Table_2b_i",
  title = paste0("Table_2b_i: Percentage of units of dental activity by treatment band and financial year, ", config$table_sheet_title_fy),
  notes = c("1. Some cells in this table are empty because data was not available for the time period. Band 2 sub-bands were introduced for treatment with a date of acceptance on or after 25 November 2022."),
  dataset = table2bi,
  column_a_width = 20
)

accessibleTables::format_data(wb,
                              "Table_2b_i",
                              c("A"),
                              "left",
                              "")

accessibleTables::format_data(wb,
                              "Table_2b_i",
                              c("B", "C", "D", "E", "F", "G", "H", "I", "J", "K"),
                              "right",
                              "#,###0.0")

openxlsx::setColWidths(
  wb,
  "Table_2b_i",
  c("A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K"),
  widths = c(20, 14, 14, 14, 14, 14, 14, 14, 14, 37, 14)
)

#Sheet for : Table_2b_ii ---------------------------------
accessibleTables::write_sheet(
  workbook = wb,
  sheetname = "Table_2b_ii",
  title = paste0("Table_2b_ii: Percentage of units of dental activity by treatment band and financial quarter, ", config$table_sheet_title_fy),
  notes = c("1. Some cells in this table are empty because data was not available for the time period. Band 2 sub-bands were introduced for treatment with a date of acceptance on or after 25 November 2022."),
  dataset = table2bii,
  column_a_width = 20
)

accessibleTables::format_data(wb,
                              "Table_2b_ii",
                              c("A", "B"),
                              "left",
                              "")

accessibleTables::format_data(wb,
                              "Table_2b_ii",
                              c("C", "D", "E", "F", "G", "H", "I", "J", "K", "L"),
                              "right",
                              "#,###0.0")

openxlsx::setColWidths(
  wb,
  "Table_2b_ii",
  c("A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L"),
  widths = c(20, 17, 14, 14, 14, 14, 14, 14, 14, 14, 37, 14)
)

#Sheet for : Table_2c ---------------------------------
accessibleTables::write_sheet(
  workbook = wb,
  sheetname = "Table_2c",
  title = paste0("Table_2c: Units of dental activity by treatment band, patient type and financial year, ", config$table_sheet_title_fy),
  notes = c("1. Some cells in this table are empty because data was not available for the time period. Band 2 sub-bands were introduced for treatment with a date of acceptance on or after 25 November 2022.",
            "2. Patient type can be exempt, non-exempt, or child. A child is classed as being aged 17 or under at the time that treatment starts. Exempt patients do not pay patient charges towards their treatment, but do not have an age exemption."),
  dataset = table2c_excel,
  column_a_width = 20
)

accessibleTables::format_data(wb,
                              "Table_2c",
                              c("A", "B"),
                              "left",
                              "")

accessibleTables::format_data(wb,
                              "Table_2c",
                              c("C", "D", "E", "F", "G", "H", "I", "J", "K", "L"),
                              "right",
                              "#,###0")

openxlsx::setColWidths(
  wb,
  "Table_2c",
  c("A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L"),
  widths = c(20, 16, 14, 14, 14, 14, 14, 14, 14, 14, 37, 14)
)

#Sheet for : Table_2d ---------------------------------
accessibleTables::write_sheet(
  workbook = wb,
  sheetname = "Table_2d",
  title = paste0("Table 2d: Percentage of units of dental activity by treatment band, patient type and financial year, ", config$table_sheet_title_fy),
  notes = c("1. Some cells in this table are empty because data was not available for the time period. Band 2 sub-bands were introduced for treatment with a date of acceptance on or after 25 November 2022.",
            "2. Patient type can be exempt, non-exempt, or child. A child is classed as being aged 17 or under at the time that treatment starts. Exempt patients do not pay patient charges towards their treatment, but do not have an age exemption."),
  dataset = table2d,
  column_a_width = 20
)

accessibleTables::format_data(wb,
                              "Table_2d",
                              c("A", "B"),
                              "left",
                              "")

accessibleTables::format_data(wb,
                              "Table_2d",
                              c("C", "D", "E", "F", "G", "H", "I", "J", "K", "L"),
                              "right",
                              "#,###0.0")

openxlsx::setColWidths(
  wb,
  "Table_2d",
  c("A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L"),
  widths = c(20, 16, 14, 14, 14, 14, 14, 14, 14, 14, 37, 14)
)



#Sheet for : Table 2e_i ---------------------------------
accessibleTables::write_sheet(
  workbook = wb,
  sheetname = "Table_2e_i",
  title = paste0("Table 2e_i: Percentage of units of dental activity by patient type, treatment band and financial year, ", config$table_sheet_title_fy),
  notes = c("1. Some cells in this table are empty because data was not available for the time period. Band 2 sub-bands were introduced for treatment with a date of acceptance on or after 25 November 2022.",
            "2. Patient type can be exempt, non-exempt, or child. A child is classed as being aged 17 or under at the time that treatment starts. Exempt patients do not pay patient charges towards their treatment, but do not have an age exemption."),
  dataset = table2ei,
  column_a_width = 20
)

accessibleTables::format_data(wb,
                              "Table_2e_i",
                              c("A", "B"),
                              "left",
                              "")

accessibleTables::format_data(wb,
                              "Table_2e_i",
                              c("C", "D", "E", "F"),
                              "right",
                              "#,###0.0")

openxlsx::setColWidths(wb,
                       "Table_2e_i",
                       c("A", "B", "C", "D", "E", "F"),
                       widths = c(20, 32, 17, 17, 17, 17))



#Sheet for : Table_2e_ii ---------------------------------
accessibleTables::write_sheet(
  workbook = wb,
  sheetname = "Table_2e_ii",
  title = paste0("Table 2e_ii: Percentage of units of dental activity by patient type and financial year, ", config$table_sheet_title_fy),
  notes = c("1. Patient type can be exempt, non-exempt, or child. A child is classed as being aged 17 or under at the time that treatment starts. Exempt patients do not pay patient charges towards their treatment, but do not have an age exemption."),
  dataset = table2eii,
  column_a_width = 20
)

accessibleTables::format_data(wb,
                              "Table_2e_ii",
                              c("A"),
                              "left",
                              "")

accessibleTables::format_data(wb,
                              "Table_2e_ii",
                              c("B", "C", "D", "E"),
                              "right",
                              "#,###0.0")

openxlsx::setColWidths(wb,
                       "Table_2e_ii",
                       c("A", "B", "C", "D", "E"),
                       widths = c(20, 14, 18, 14, 14))

#Sheet for : Table 3a ---------------------------------
accessibleTables::write_sheet(
  workbook = wb,
  sheetname = "Table_3a",
  title = paste0("Table 3a: Units of orthodontic activity by financial year, ", config$table_sheet_title_fy),
  notes = c(""),
  dataset = table3a,
  column_a_width = 20
)

accessibleTables::format_data(wb,
                              "Table_3a",
                              c("A"),
                              "left",
                              "")

accessibleTables::format_data(wb,
                              "Table_3a",
                              c("B"),
                              "right",
                              "#,###0")

openxlsx::setColWidths(wb,
                       "Table_3a",
                       c("A", "B"),
                       widths = c(20, 26))



#Sheet for : Table 4a ---------------------------------
accessibleTables::write_sheet(
  workbook = wb,
  sheetname = "Table_4a",
  title = paste0("Table 4a: Number of adult patients seen in the 24 months prior to a specified date, ", config$table_sheet_title_fy),
  notes = c("
1. Patients seen includes orthodontists visits. It is not possible to determine which patients were seen for orthodontic visits.",
            "2. A patient's age is calculated as at the given date."),
  dataset = table4a,
  column_a_width = 20
)

accessibleTables::format_data(wb,
                              "Table_4a",
                              c("A"),
                              "left",
                              "")

accessibleTables::format_data(wb,
                              "Table_4a",
                              c("B", "C", "D", "E", "F"),
                              "right",
                              "#,###0")

openxlsx::setColWidths(wb,
                       "Table_4a",
                       c("A", "B", "C", "D", "E", "F"),
                       widths = c(20, 14, 14, 14, 14, 14))


#Sheet for : Table 4b ---------------------------------
accessibleTables::write_sheet(
  workbook = wb,
  sheetname = "Table_4b",
  title = paste0("Table 4b: Percentage of adult patients seen in the 24 months prior to a specified date ,", config$table_sheet_title_fy),
  notes = c("1. Patients seen includes orthodontists visits. It is not possible to determine which patients were seen for orthodontic visits.",
            "2. A patient's age is calculated as at the given date.",
            "3. Mid-year population estimates have been taken from the latest ONS population estimates at time of publication. A link to these can be found in the metadata sheet."),
  dataset = table4b,
  column_a_width = 20
)

accessibleTables::format_data(wb,
                              "Table_4b",
                              c("A"),
                              "left",
                              "")

accessibleTables::format_data(wb,
                              "Table_4b",
                              c("B", "C", "D", "E", "F"),
                              "right",
                              "#,###0")

accessibleTables::format_data(wb,
                              "Table_4b",
                              c("G", "H", "I", "J", "K"),
                              "right",
                              "#,##0.0")



#Sheet for : Table 4c ---------------------------------
accessibleTables::write_sheet(
  workbook = wb,
  sheetname = "Table_4c",
  title = paste0("Table 4c: Number of child patients seen in the 12 months prior to a specified date, ", config$table_sheet_title_fy),
  notes = c("1. Patients seen includes orthodontists visits. It is not possible to determine which patients were seen for orthodontic visits.",
            "2. A patient's age is calculated as at the given date."),
  dataset = table4c,
  column_a_width = 20
)

accessibleTables::format_data(wb,
                              "Table_4c",
                              c("A"),
                              "left",
                              "")

accessibleTables::format_data(wb,
                              "Table_4c",
                              c("B", "C", "D", "E", "F"),
                              "right",
                              "#,###0")

openxlsx::setColWidths(wb,
                       "Table_4c",
                       c("A", "B", "C", "D", "E", "F"),
                       widths = c(20, 14, 14, 14, 14, 14))


#Sheet for : Table 4d ---------------------------------
accessibleTables::write_sheet(
  workbook = wb,
  sheetname = "Table_4d",
  title = paste0("Table 4d: Percentage of child patients seen in the 12 months prior to a specified date, ", config$table_sheet_title_fy),
  notes = c("1. Patients seen includes orthodontists visits. It is not possible to determine which patients were seen for orthodontic visits.",
            "2. A patient's age is calculated as at the given date.",
            "3. Mid-year population estimates have been taken from the latest ONS population estimates at time of publication. A link to these can be found in the metadata sheet."),
  dataset = table4d,
  column_a_width = 20
)

accessibleTables::format_data(wb,
                              "Table_4d",
                              c("A"),
                              "left",
                              "")

accessibleTables::format_data(wb,
                              "Table_4d",
                              c("B", "C", "D", "E", "F"),
                              "right",
                              "#,###0")

accessibleTables::format_data(wb,
                              "Table_4d",
                              c("G", "H", "I", "J", "K"),
                              "right",
                              "#,##0.0")


#Sheet for : Table 5a ---------------------------------
accessibleTables::write_sheet(
  workbook = wb,
  sheetname = "Table_5a",
  title = paste0("Table 5a: Estimated number of adult courses of treatment that contain each clinical treatment by treatment band and financial year, ", config$table_sheet_title_fy),
  notes = c("1. Some cells in this table are empty because data was not available for the time period. Band 2 sub-bands were introduced for treatment with a date of acceptance on or after 25 November 2022."),
  dataset = table5a,
  column_a_width = 20
)

accessibleTables::format_data(wb,
                              "Table_5a",
                              c("A", "B"),
                              "left",
                              "")

accessibleTables::format_data(wb,
                              "Table_5a",
                              c("C", "D", "E", "F", "G", "H", "I", "J"),
                              "right",
                              "#,###0")

openxlsx::setColWidths(
  wb,
  "Table_5a",
  c("A", "B", "C", "D", "E", "F", "G", "H", "I", "J"),
  widths = c(20, 44, 14, 14, 14, 14, 14, 14, 14)
)

#Sheet for : Table 5b ---------------------------------
accessibleTables::write_sheet(
  workbook = wb,
  sheetname = "Table_5b",
  title = paste0("Table 5b: Estimated number of clinical treatment items provided to adults by treatment band and financial year, ", config$table_sheet_title_fy),
  notes = c("1. Some cells in this table are empty because data was not available for the time period. Band 2 sub-bands were introduced for treatment with a date of acceptance on or after 25 November 2022."),
  dataset = table5b,
  column_a_width = 20
)
accessibleTables::format_data(wb,
                              "Table_5b",
                              c("A", "B"),
                              "left",
                              "")

accessibleTables::format_data(wb,
                              "Table_5b",
                              c("C", "D", "E", "F", "G", "H", "I", "J"),
                              "right",
                              "#,###0")

openxlsx::setColWidths(
  wb,
  "Table_5b",
  c("A", "B", "C", "D", "E", "F", "G", "H", "I", "J"),
  widths = c(20, 44, 14, 14, 14, 14, 14, 14, 14)
)

#Sheet for : Table 5c ---------------------------------
accessibleTables::write_sheet(
  workbook = wb,
  sheetname = "Table_5c",
  title = paste0("Table 5c: Estimated number of child courses of treatment that contain each clinical treatment by treatment band and financial year, ", config$table_sheet_title_fy),
  notes = c("1. Some cells in this table are empty because data was not available for the time period. Band 2 sub-bands were introduced for treatment with a date of acceptance on or after 25 November 2022."),
  dataset = table5c,
  column_a_width = 20
)

accessibleTables::format_data(wb,
                              "Table_5c",
                              c("A", "B"),
                              "left",
                              "")

accessibleTables::format_data(wb,
                              "Table_5c",
                              c("C", "D", "E", "F", "G", "H", "I", "J"),
                              "right",
                              "#,###0")

openxlsx::setColWidths(
  wb,
  "Table_5c",
  c("A", "B", "C", "D", "E", "F", "G", "H", "I", "J"),
  widths = c(20, 44, 14, 14, 14, 14, 14, 14, 14, 14)
)

#Sheet for : Table 5d ---------------------------------
accessibleTables::write_sheet(
  workbook = wb,
  sheetname = "Table_5d",
  title = paste0("Table 5d: Estimated number of clinical treatment items provided to children by treatment band and financial year, ", config$table_sheet_title_fy),
  notes = c("1. Some cells in this table are empty because data was not available for the time period. Band 2 sub-bands were introduced for treatment with a date of acceptance on or after 25 November 2022."),
  dataset = table5d,
  column_a_width = 20
)

accessibleTables::format_data(wb,
                              "Table_5d",
                              c("A", "B"),
                              "left",
                              "")

accessibleTables::format_data(wb,
                              "Table_5d",
                              c("C", "D", "E", "F", "G", "H", "I", "J"),
                              "right",
                              "#,###0")

openxlsx::setColWidths(
  wb,
  "Table_5d",
  c("A", "B", "C", "D", "E", "F", "G", "H", "I", "J"),
  widths = c(20, 44, 14, 14, 14, 14, 14, 14, 14, 14)
)


#Sheet for : Table 6a ---------------------------------
accessibleTables::write_sheet(
  workbook = wb,
  sheetname = "Table_6a",
  title = paste0("Table 6a: Patient charge revenue (£) by treatment band and financial year, ", config$table_sheet_title_fy),
  notes = c("1. Some cells in this table are empty because data was not available for the time period. Band 2 sub-bands were introduced for treatment with a date of acceptance on or after 25 November 2022.",
            "2. Patient revenue is the amount charged to patients who do not have a full or partial exemption. You can find more information in the metadata sheet and in the background and methdology document."),
  dataset = table6a,
  column_a_width = 20
)

accessibleTables::format_data(wb,
                              "Table_6a",
                              c("A"),
                              "left",
                              "")

accessibleTables::format_data(wb,
                              "Table_6a",
                              c("B", "C", "D", "E", "F", "G", "H", "I", "J"),
                              "right",
                              "#,###0.00")

openxlsx::setColWidths(
  wb,
  "Table_6a",
  c("A", "B", "C", "D", "E", "F", "G", "H", "I", "J"),
  widths = c(20, 14, 14, 14, 14, 14, 14, 14, 37, 14)
)

#Sheet for : Table 6b ---------------------------------
accessibleTables::write_sheet(
  workbook = wb,
  sheetname = "Table_6b",
  title = paste0("Table 6b: Percentage patient charge revenue by treatment band and financial year, ", config$table_sheet_title_fy),
  notes = c("1. Some cells in this table are empty because data was not available for the time period. Band 2 sub-bands were introduced for treatment with a date of acceptance on or after 25 November 2022.",
            "2. Patient revenue is the amount charged to patients who do not have a full or partial exemption. You can find more information in the metadata sheet and in the background and methdology document."),
  dataset = table6b,
  column_a_width = 20
)

accessibleTables::format_data(wb,
                              "Table_6b",
                              c("A"),
                              "left",
                              "")

accessibleTables::format_data(wb,
                              "Table_6b",
                              c("B", "C", "D", "E", "F", "G", "H", "I", "J"),
                              "right",
                              "#,###0.0")

openxlsx::setColWidths(
  wb,
  "Table_6b",
  c("A", "B", "C", "D", "E", "F", "G", "H", "I", "J"),
  widths = c(20, 14, 14, 14, 14, 14, 14, 14, 37, 14)
)

#Sheet for : Table 6c ---------------------------------

accessibleTables::write_sheet(
  workbook = wb,
  sheetname = "Table_6c",
  title = paste0("Table 6c: Cost of treatment (£) delivered to exempt groups by treatment band and financial year, ", config$table_sheet_title_fy),
  notes = c("1. Some cells in this table are empty because data was not available for the time period. Band 2 sub-bands were introduced for treatment with a date of acceptance on or after 25 November 2022.",
            "2. The cost of treatment in this table is an estimated total of how much patients with an exemption would have paid if they were not exempt. This cost has not actually been collected from patients."),
  dataset = table6c,
  column_a_width = 20
)

accessibleTables::format_data(wb,
                              "Table_6c",
                              c("A", "B"),
                              "left",
                              "")

accessibleTables::format_data(wb,
                              "Table_6c",
                              c("C", "D", "E", "F", "G", "H", "I", "J"),
                              "right",
                              "#,###0.00")

openxlsx::setColWidths(  wb,
                         "Table_6c",
                         c("A","B","C","D","E","F","G","H","I","J"),
                         widths = c(20,60,14,14,14,14,14,14,14,14)
)

accessibleTables::makeCoverSheet(
  config$publication_name,
  config$cover_sheet_sub_title_nat_activity,
  paste0("Publication date: ", config$publication_date),
  wb,
  sheetNames,
  c(
    "Metadata",
    "Table_1a_i: Count of courses of treatment by treatment band and financial year",
    "Table_1a_ii: Count of courses of treatment by treatment band and financial quarter",
    "Table_1b_i: Percentage of courses of treatment by treatment band and financial year",
    "Table_1b_ii: Percentage of courses of treatment by treatment band and financial quarter",
    "Table_1c: Courses of treatment by treatment band, patient type and financial year",
    "Table_1d: Percentage of courses of treatment by treatment band, patient type and financial year",
    "Table 1e_i: Percentage of courses of treatment by patient type, treatment band and financial year",
    "Table 1e_ii: Percentage of courses of treatment by patient type and financial year",
    "Table_1f: Courses of treatment by patient exemption type, treatment band, and financial year",
    "Table_1g_i: Courses of treatment by Dental Care Professional type, treatment band, and financial year",
    "Table_1g_ii: Courses of treatment by Dental Care Professional type, treatment band, and financial quarter",
    "Table_2a_i: Count of units of dental activity by treatment band and financial year",
    "Table_2a_ii: Count of units of dental activity by treatment band and financial quarter",
    "Table_2b_i: Percentage of units of dental activity by treatment band and financial year",
    "Table_2b_ii: Percentage of units of dental activity by treatment band and financial quarter",
    "Table_2c: Units of dental activity by treatment band, patient type and financial year",
    "Table 2d: Percentage of units of dental activity by treatment band, patient type and financial year",
    "Table 2e_i: Percentage of units of dental activity by patient type, treatment band and financial year",
    "Table 2e_ii: Percentage of units of dental activity by patient type and financial year",
    "Table 3a: Units of orthodontic activity by financial year",
    "Table 4a: Number of adult patients seen in the 24 months prior to a specified date",
    "Table 4b: Percentage of adult patients seen in the 24 months prior to a specified date",
    "Table 4c: Number of child patients seen in the 12 months prior to a specified date",
    "Table 4d: Percentage of child patients seen in the 12 months prior to a specified date",
    "Table 5a: Estimated number of adult courses of treatment that contain each clinical treatment by treatment band and financial year",
    "Table 5b: Estimated number of clinical treatment items provided to adults by treatment band and financial year",
    "Table 5c: Estimated number of child courses of treatment that contain each clinical treatment by treatment band and financial year",
    "Table 5d: Estimated number of clinical treatment items provided to children by treatment band and financial year",
    "Table 6a: Patient charge revenue (£) by treatment band and financial year",
    "Table 6b: Percentage patient charge revenue by treatment band and financial year",
    "Table 6c: Cost of treatment (£) delivered to exempt groups by treatment band and financial year"
  ),
  c("Metadata", sheetNames)
)


#Export to Excel ---------------------------------
openxlsx::saveWorkbook(
  wb,
  "outputs/dental_contract_national_overview_24_25.xlsx",
  overwrite = TRUE
)