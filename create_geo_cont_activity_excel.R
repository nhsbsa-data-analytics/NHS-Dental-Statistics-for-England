#script to format data to build geographical breakdown excel files
#for contract location activity tables
#added DCP COTs tables (1ai, 1bi and 1ci) by Region, ICB, AND LA for 2024/25 publication
#this script to be called in main `pipeline.R` script
#functions loaded in main pipeline

# Create sheets ready for export to Excel ---------------------------------
sheetNames <- c(
  "Table_1a",
  "Table_1ai",
  "Table_1b",
  "Table_1bi",
  "Table_1c",
  "Table_1ci",
  "Table_1d",
  "Table_1e",
  "Table_1f",
  "Table_2a",
  "Table_2ai",
  "Table_2b",
  "Table_2bi",
  "Table_2c",
  "Table_2ci",
  "Table_2d",
  "Table_2e",
  "Table_2f",
  "Table_3a",
  "Table_3b",
  "Table_3c",
  "Table_3d",
  "Table_3e",
  "Table_3f"
)

wb <- accessibleTables::create_wb(sheetNames)

# create metadata tab (will need to open file and auto row heights once ran)
meta_fields <- c(
  "Financial year",
  "Treatment band",
  "Course of treatment (COT)",
  "Unit of dental activity (UDA)",
  "Patient type",
  "Patient eligibility",
  "Adult patients seen",
  "Child patients seen",
  "Age group",
  "Date",
  "Mid-year England population estimate",
  "Mid-year population year",
  "ODS code",
  "ONS code",
  "Region name",
  "ICB name",
  "Local Authority name",
#  "Clinical treatment",
  "DCP status",
  "DCP type"
)

meta_descs <-
  c("The financial year to which the data belongs. For example, 2024/2025.",
    "NHS dental activity is broken down into treatment bands based on how complex the treatment is. For example, a dental crown is a band 3 treatment. For activity with a date of acceptance from November 2022 onwards, band 2 treatments are further broken down into sub-bands 2a, 2b, and 2c.",
    "A COT is a course of treatment, usually begun after a dentist examines a patient and agrees treatment is required. COTs have been calculated by counting the number of valid FP17 claim forms. COT counts in this publication exclude orthodontic activity unless specified.",
    "A UDA is a unit of dental activity, which a dental contract can be awarded after submitting a valid FP17 form. A general dental COT can receive a set number of UDAs based on treatment band. For example, a COT of band 2a will generally be awarded 3 UDA. Late submissions may have the UDA they receive reduced to 0.",
    "Patient type can be child, exempt, or non-exempt.",
    "Patient eligibility is the eligibility group of the patient. Adults undergoing NHS dental activity normally pay a set amount of money towards treatment, unless they have a valid exemption. Children aged under 18, or under 19 and in full-time education, do not pay for treatment. More information on patient charges and exemptions can by found in the background and methodology document.",
    "A count of patients aged 18 or over seen by an NHS dentist in the 24 months up to the end of the specified period.",
    "A count of patients aged 17 or under seen by an NHS dentist in the 12 months up to the end of the specified period.",
    "The age group which the data has been aggregated up to, where age is the age of a patient at the date of acceptance for treatment. For example, age group 18-64 includes all patients aged 18 to 64.",
    "The date of the specified period.",
    "The population estimate for the corresponding mid-year population year, from the latest ONS population estimates at time of publication. Population estimates for 2023 or 2024 were not available for NHS region or ICB levels, so these currently use the 2022 mid-year estimate for 2023/24 and 2024/25. Regional and ICB level numbers that are calculated using population data are provisional and will be updated once 2023 and 2024 population estimates are available. Local authority numbers for 2024/25 use mid-year population estimates for 2024 and are in their final form. All estimates are taken from the ONS website at https://www.ons.gov.uk/peoplepopulationandcommunity/populationandmigration.",
    "The year in which the Office for National Statistics (ONS) mid-year population estimates were taken, required due to the presentation of this data in financial year format.",
    "The Organisation Data Service (ODS) code the data has been aggregated up to. For example, Devon ICB has an ODS code of QJK.",
    "The Office for National Statistics (ONS) geography code which the data has been aggregated up to. For example, Hartlepool local authority has an ONS code of E06000001.",
    "The name of the NHS region the data has been aggregated up to, based on the contract. For example, East of England.",
    "The name of the Integrated Care Board (ICB) the data has been aggregated up to, based on the contract. For example, Devon ICB. ICBs were introduced in 2022. More information on ICBs and how data is mapped to boundaries can be found in the background and methodology document for this release. ICB level tables also include Health and Justice (H&J) commissioners.",
    "The name of the Local Authority (LA) the data has been aggregated up to, based on the contract. For example, Darlington.",
    #    "The clinical treatment listed on the FP17 form. For example, scale and polish.",
    "Dental Care Professionals (DCPs) are non-dentist roles and were previously only permitted to assist in providing treatment. Changes were made in 2025 to the General Dental Council (GDC) scope of practice. These changes mean some dental hygienists and dental therapists can now lead on selected dental activities. The DCP status in this data can be DCP-led, DCP-assisted, or Non-DCP led and not DCP assisted",
    "The DCP type is the role of a DCP, such as dental hygienist or dental therapist. Other DCP roles have not been grouped in these tables as 'Other'.")

accessibleTables::create_metadata(wb,
                                  meta_fields,
                                  meta_descs)

#Sheet for : Table_1a ----------------------------------------------------------
accessibleTables::write_sheet(
  workbook = wb,
  sheetname = "Table_1a",
  title = paste0("Table_1a: Count of courses of treatment by NHS region and treatment band, ", config$table_sheet_title_ltst_year),
  notes = c("1. Field definitions can be found on the 'Metadata' tab."),
  dataset = geo_table1a_import,
  column_a_width = 20
)

accessibleTables::format_data(wb,
                              "Table_1a",
                              c("A", "B", "C", "D"),
                              "left",
                              "")

accessibleTables::format_data(wb,
                              "Table_1a",
                              c("E", "F", "G", "H", "I", "J", "K", "L", "M", "N"),
                              "right",
                              "#,###0")

openxlsx::setColWidths(
  wb,
  "Table_1a",
  c("A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N"),
  widths = c(18, 17, 14, 22, 14, 14, 14, 14, 14, 14, 14, 14, 37, 14)
)

#Sheet for : Table_1ai ---------------------------------------------------------
accessibleTables::write_sheet(
  workbook = wb,
  sheetname = "Table_1ai",
  title = paste0("Table_1ai: Count of courses of treatment by NHS region, Dental Care Professional type, and treatment band, ", config$table_sheet_title_dcp_years),
  notes = c("1. Field definitions can be found on the 'Metadata' tab."),
  dataset = geo_table1ai,
  column_a_width = 20
)

accessibleTables::format_data(wb,
                              "Table_1ai",
                              c("A", "B", "C", "D", "E", "F"),
                              "left",
                              "")

accessibleTables::format_data(wb,
                              "Table_1ai",
                              c("G", "H", "I", "J", "K", "L", "M", "N", "O", "P"),
                              "right",
                              "#,###0")

openxlsx::setColWidths(
  wb,
  "Table_1ai",
  c("A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P"),
  widths = c(18, 17, 14, 22, 32, 14, 14, 14, 14, 14, 14, 14, 14, 14, 37, 14)
)

#Sheet for : Table_1b ----------------------------------------------------------
accessibleTables::write_sheet(
  workbook = wb,
  sheetname = "Table_1b",
  title = paste0("Table_1b: Count of courses of treatment by Integrated Care Board (ICB) and treatment band, ", config$table_sheet_title_ltst_year),
  notes = c("1. Field definitions can be found on the 'Metadata' tab."),
  dataset = geo_table1b_import,
  column_a_width = 20
)

accessibleTables::format_data(wb,
                              "Table_1b",
                              c("A", "B", "C", "D"),
                              "left",
                              "")

accessibleTables::format_data(wb,
                              "Table_1b",
                              c("E", "F", "G", "H", "I", "J", "K", "L", "M", "N"),
                              "right",
                              "#,###0")

openxlsx::setColWidths(
  wb,
  "Table_1b",
  c("A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N"),
  widths = c(18, 17, 14, 50, 14, 14, 14, 14, 14, 14, 14, 14, 37, 14)
)

#Sheet for : Table_1bi ---------------------------------------------------------
accessibleTables::write_sheet(
  workbook = wb,
  sheetname = "Table_1bi",
  title = paste0("Table_1bi: Count of courses of treatment by Integrated Care Board (ICB), Dental Care Professional type, and treatment band, ", config$table_sheet_title_dcp_years),
  notes = c("1. Field definitions can be found on the 'Metadata' tab."),
  dataset = geo_table1bi,
  column_a_width = 20
)

accessibleTables::format_data(wb,
                              "Table_1bi",
                              c("A", "B", "C", "D", "E", "F"),
                              "left",
                              "")

accessibleTables::format_data(wb,
                              "Table_1bi",
                              c("G", "H", "I", "J", "K", "L", "M", "N", "O", "P"),
                              "right",
                              "#,###0")

openxlsx::setColWidths(
  wb,
  "Table_1bi",
  c("A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P"),
  widths = c(18, 17, 14, 50, 30, 14, 14, 14, 14, 14, 14, 14, 14, 14, 37, 14)
)

#Sheet for : Table_1c ----------------------------------------------------------
accessibleTables::write_sheet(
  workbook = wb,
  sheetname = "Table_1c",
  title = paste0("Table_1b: Count of courses of treatment by Local Authority and treatment band, ", config$table_sheet_title_ltst_year),
  notes = c("1. Field definitions can be found on the 'Metadata' tab."),
  dataset = geo_table1c_import,
  column_a_width = 20
)

accessibleTables::format_data(wb,
                              "Table_1c",
                              c("A", "B", "C"),
                              "left",
                              "")

accessibleTables::format_data(wb,
                              "Table_1c",
                              c("D", "E", "F", "G", "H", "I", "J", "K", "L", "M"),
                              "right",
                              "#,###0")

openxlsx::setColWidths(
  wb,
  "Table_1c",
  c("A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M"),
  widths = c(18, 17, 32, 14, 14, 14, 14, 14, 14, 14, 14, 37, 14)
)

#Sheet for : Table_1ci ---------------------------------------------------------
accessibleTables::write_sheet(
  workbook = wb,
  sheetname = "Table_1ci",
  title = paste0("Table_1ci: Count of courses of treatment by Local Authority, Dental Care Professional type, and treatment band, ", config$table_sheet_title_dcp_years),
  notes = c("1. Field definitions can be found on the 'Metadata' tab."),
  dataset = geo_table1ci,
  column_a_width = 20
)

accessibleTables::format_data(wb,
                              "Table_1ci",
                              c("A", "B", "C", "D", "E"),
                              "left",
                              "")

accessibleTables::format_data(wb,
                              "Table_1ci",
                              c("F", "G", "H", "I", "J", "K", "L", "M", "N", "O"),
                              "right",
                              "#,###0")

openxlsx::setColWidths(
  wb,
  "Table_1ci",
  c("A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O"),
  widths = c(18, 17, 20, 31, 17, 14, 14, 14, 14, 14, 14, 14, 14, 37, 14)
)

#Sheet for : Table_1d ----------------------------------------------------------
accessibleTables::write_sheet(
  workbook = wb,
  sheetname = "Table_1d",
  title = paste0("Table_1d: Percentage of courses of treatment by NHS region and treatment band, ", config$table_sheet_title_ltst_year),
  notes = c("1. Field definitions can be found on the 'Metadata' tab."),
  dataset = geo_table1d_import,
  column_a_width = 20
)

accessibleTables::format_data(wb,
                              "Table_1d",
                              c("A", "B", "C", "D"),
                              "left",
                              "")

accessibleTables::format_data(wb,
                              "Table_1d",
                              c("E", "F", "G", "H", "I", "J", "K", "L", "M", "N"),
                              "right",
                              "#,###0.00")

openxlsx::setColWidths(
  wb,
  "Table_1d",
  c("A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N"),
  widths = c(20, 17, 14, 22, 14, 14, 14, 14, 14, 14, 14, 14, 37, 14)
)

#Sheet for : Table_1e ----------------------------------------------------------
accessibleTables::write_sheet(
  workbook = wb,
  sheetname = "Table_1e",
  title = paste0("Table_1e: Percentage of courses of treatment by Integrated Care Board (ICB) and treatment band, ", config$table_sheet_title_ltst_year),
  notes = c("1. Field definitions can be found on the 'Metadata' tab."),
  dataset = geo_table1e_import,
  column_a_width = 20
)

accessibleTables::format_data(wb,
                              "Table_1e",
                              c("A", "B", "C", "D"),
                              "left",
                              "")

accessibleTables::format_data(wb,
                              "Table_1e",
                              c("E", "F", "G", "H", "I", "J", "K", "L", "M", "N"),
                              "right",
                              "#,###0.00")

openxlsx::setColWidths(
  wb,
  "Table_1e",
  c("A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N"),
  widths = c(18, 17, 14, 50, 14, 14, 14, 14, 14, 14, 14, 14, 37, 14)
)

#Sheet for : Table_1f ----------------------------------------------------------
accessibleTables::write_sheet(
  workbook = wb,
  sheetname = "Table_1f",
  title = paste0("Table_1f: Percentage of courses of treatment by Local Authority and treatment band, ", config$table_sheet_title_ltst_year),
  notes = c("1. Field definitions can be found on the 'Metadata' tab."),
  dataset = geo_table1f_import,
  column_a_width = 20
)

accessibleTables::format_data(wb,
                              "Table_1f",
                              c("A", "B", "C"),
                              "left",
                              "")

accessibleTables::format_data(wb,
                              "Table_1f",
                              c("D", "E", "F", "G", "H", "I", "J", "K", "L", "M"),
                              "right",
                              "#,###0.00")

openxlsx::setColWidths(
  wb,
  "Table_1f",
  c("A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M"),
  widths = c(18, 17, 32, 14, 14, 14, 14, 14, 14, 14, 14, 37, 14)
)

#Sheet for : Table_2a ----------------------------------------------------------
accessibleTables::write_sheet(
  workbook = wb,
  sheetname = "Table_2a",
  title = paste0("Table_2a: Count of units of dental activity by NHS region and treatment band, ", config$table_sheet_title_ltst_year),
  notes = c("1. Field definitions can be found on the 'Metadata' tab."),
  dataset = geo_table2a_import,
  column_a_width = 20
)

accessibleTables::format_data(wb,
                              "Table_2a",
                              c("A", "B", "C", "D"),
                              "left",
                              "")

accessibleTables::format_data(wb,
                              "Table_2a",
                              c("E", "F", "G", "H", "I", "J", "K", "L", "M", "N"),
                              "right",
                              "#,###0")

openxlsx::setColWidths(
  wb,
  "Table_2a",
  c("A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N"),
  widths = c(18, 17, 14, 22, 14, 14, 14, 14, 14, 14, 14, 14, 37, 14)
)

#Sheet for : Table_2ai ---------------------------------------------------------
accessibleTables::write_sheet(
  workbook = wb,
  sheetname = "Table_2ai",
  title = paste0("Table_2ai: Count of units of dental activity by NHS region, Dental Care Professional type, and treatment band, ", config$table_sheet_title_dcp_years),
  notes = c("1. Field definitions can be found on the 'Metadata' tab."),
  dataset = geo_table2ai,
  column_a_width = 20
)

accessibleTables::format_data(wb,
                              "Table_2ai",
                              c("A", "B", "C", "D", "E", "F"),
                              "left",
                              "")

accessibleTables::format_data(wb,
                              "Table_2ai",
                              c("G", "H", "I", "J", "K", "L", "M", "N", "O", "P"),
                              "right",
                              "#,###0")

openxlsx::setColWidths(
  wb,
  "Table_2ai",
  c("A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P"),
  widths = c(18, 17, 14, 22, 32, 14, 14, 14, 14, 14, 14, 14, 14, 14, 37, 14)
)

#Sheet for : Table_2b ----------------------------------------------------------
accessibleTables::write_sheet(
  workbook = wb,
  sheetname = "Table_2b",
  title = paste0("Table_2b: Count of units of dental activity by Integrated Care Board (ICB) and treatment band, ", config$table_sheet_title_ltst_year),
  notes = c("1. Field definitions can be found on the 'Metadata' tab."),
  dataset = geo_table2b_import,
  column_a_width = 20
)

accessibleTables::format_data(wb,
                              "Table_2b",
                              c("A", "B", "C", "D"),
                              "left",
                              "")

accessibleTables::format_data(wb,
                              "Table_2b",
                              c("E", "F", "G", "H", "I", "J", "K", "L", "M", "N"),
                              "right",
                              "#,###0")

openxlsx::setColWidths(
  wb,
  "Table_2b",
  c("A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N"),
  widths = c(18, 17, 14, 50, 14, 14, 14, 14, 14, 14, 14, 14, 37, 14)
)

#Sheet for : Table_2bi ---------------------------------------------------------
accessibleTables::write_sheet(
  workbook = wb,
  sheetname = "Table_2bi",
  title = paste0("Table_2bi: Count of units of dental activity by Integrated Care Board (ICB), Dental Care Professional type, and treatment band, ", config$table_sheet_title_dcp_years),
  notes = c("1. Field definitions can be found on the 'Metadata' tab."),
  dataset = geo_table2bi,
  column_a_width = 20
)

accessibleTables::format_data(wb,
                              "Table_2bi",
                              c("A", "B", "C", "D", "E", "F"),
                              "left",
                              "")

accessibleTables::format_data(wb,
                              "Table_2bi",
                              c("G", "H", "I", "J", "K", "L", "M", "N", "O", "P"),
                              "right",
                              "#,###0")

openxlsx::setColWidths(
  wb,
  "Table_2bi",
  c("A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P"),
  widths = c(18, 17, 14, 50, 30, 14, 14, 14, 14, 14, 14, 14, 14, 14, 37, 14)
)

#Sheet for : Table_2c ----------------------------------------------------------
accessibleTables::write_sheet(
  workbook = wb,
  sheetname = "Table_2c",
  title = paste0("Table_2c: Count of units of dental activity by Local Authority and treatment band, ", config$table_sheet_title_ltst_year),
  notes = c("1. Field definitions can be found on the 'Metadata' tab."),
  dataset = geo_table2c_import,
  column_a_width = 20
)

accessibleTables::format_data(wb,
                              "Table_2c",
                              c("A", "B", "C"),
                              "left",
                              "")

accessibleTables::format_data(wb,
                              "Table_2c",
                              c("D", "E", "F", "G", "H", "I", "J", "K", "L", "M"),
                              "right",
                              "#,###0")

openxlsx::setColWidths(
  wb,
  "Table_2c",
  c("A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M"),
  widths = c(18, 17, 32, 14, 14, 14, 14, 14, 14, 14, 14, 37, 14)
)

#Sheet for : Table_2ci ---------------------------------------------------------
accessibleTables::write_sheet(
  workbook = wb,
  sheetname = "Table_2ci",
  title = paste0("Table_2ci: Count of units of dental activity by Local Authority, Dental Care Professional type, and treatment band, ", config$table_sheet_title_dcp_years),
  notes = c("1. Field definitions can be found on the 'Metadata' tab."),
  dataset = geo_table2ci,
  column_a_width = 20
)

accessibleTables::format_data(wb,
                              "Table_2ci",
                              c("A", "B", "C", "D", "E"),
                              "left",
                              "")

accessibleTables::format_data(wb,
                              "Table_2ci",
                              c("F", "G", "H", "I", "J", "K", "L", "M", "N", "O"),
                              "right",
                              "#,###0")

openxlsx::setColWidths(
  wb,
  "Table_2ci",
  c("A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O"),
  widths = c(18, 17, 20, 31, 17, 14, 14, 14, 14, 14, 14, 14, 14, 37, 14)
)

#Sheet for : Table_2d ----------------------------------------------------------
accessibleTables::write_sheet(
  workbook = wb,
  sheetname = "Table_2d",
  title = paste0("Table_2d: Percentage of units of dental activity by NHS region and treatment band, ", config$table_sheet_title_ltst_year),
  notes = c("1. Field definitions can be found on the 'Metadata' tab."),
  dataset = geo_table2d_import,
  column_a_width = 20
)

accessibleTables::format_data(wb,
                              "Table_2d",
                              c("A", "B", "C", "D"),
                              "left",
                              "")

accessibleTables::format_data(wb,
                              "Table_2d",
                              c("E", "F", "G", "H", "I", "J", "K", "L", "M", "N"),
                              "right",
                              "#,###0.00")

openxlsx::setColWidths(
  wb,
  "Table_2d",
  c("A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N"),
  widths = c(18, 17, 14, 22, 14, 14, 14, 14, 14, 14, 14, 14, 37, 14)
)

#Sheet for : Table_2e ----------------------------------------------------------
accessibleTables::write_sheet(
  workbook = wb,
  sheetname = "Table_2e",
  title = paste0("Table_2e: Percentage of units of dental activity by Integrated Care Board (ICB) and treatment band, ", config$table_sheet_title_ltst_year),
  notes = c("1. Field definitions can be found on the 'Metadata' tab."),
  dataset = geo_table2e_import,
  column_a_width = 20
)

accessibleTables::format_data(wb,
                              "Table_2e",
                              c("A", "B", "C", "D"),
                              "left",
                              "")

accessibleTables::format_data(wb,
                              "Table_2e",
                              c("E", "F", "G", "H", "I", "J", "K", "L", "M", "N"),
                              "right",
                              "#,###0.00")

openxlsx::setColWidths(
  wb,
  "Table_2e",
  c("A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N"),
  widths = c(18, 17, 14, 50, 14, 14, 14, 14, 14, 14, 14, 14, 37, 14)
)

#Sheet for : Table_2f ----------------------------------------------------------
accessibleTables::write_sheet(
  workbook = wb,
  sheetname = "Table_2f",
  title = paste0("Table_2f: Percentage of units of dental activity by Local Authority and treatment band, ", config$table_sheet_title_ltst_year),
  notes = c("1. Field definitions can be found on the 'Metadata' tab."),
  dataset = geo_table2f_import,
  column_a_width = 20
)

accessibleTables::format_data(wb,
                              "Table_2f",
                              c("A", "B", "C"),
                              "left",
                              "")

accessibleTables::format_data(wb,
                              "Table_2f",
                              c("D", "E", "F", "G", "H", "I", "J", "K", "L", "M"),
                              "right",
                              "#,###0.00")

openxlsx::setColWidths(
  wb,
  "Table_2f",
  c("A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M"),
  widths = c(18, 17, 32, 14, 14, 14, 14, 14, 14, 14, 14, 37, 14)
)

#Sheet for : Table_3a ----------------------------------------------------------
accessibleTables::write_sheet(
  workbook = wb,
  sheetname = "Table_3a",
  title = paste0("Table_3a: Adult patients seen in the previous 24 months and child patients seen in the previous 12 months by NHS region, ", config$table_sheet_title_ltst_year),
  notes = c("1. Field definitions can be found on the 'Metadata' tab.",
            "2. Patients seen includes orthodontists visits. It is not possible to determine which patients were seen for orthodontic visits.",
            "3. A patient's age is calculated as at the given date."),
  dataset = geo_table3a_import,
  column_a_width = 20
)

accessibleTables::format_data(wb,
                              "Table_3a",
                              c("A", "B", "C", "D"),
                              "left",
                              "")

accessibleTables::format_data(wb,
                              "Table_3a",
                              c("E", "F"),
                              "right",
                              "#,###0")

openxlsx::setColWidths(
  wb,
  "Table_3a",
  c("A", "B", "C", "D", "E", "F"),
  widths = c(18, 17, 14, 22, 14, 14)
)

#Sheet for : Table_3b ----------------------------------------------------------
accessibleTables::write_sheet(
  workbook = wb,
  sheetname = "Table_3b",
  title = paste0("Table_3b: Adult patients seen in the previous 24 months and child patients seen in the previous 12 months by Integrated Care Board (ICB), ", config$table_sheet_title_ltst_year),
  notes = c("1. Field definitions can be found on the 'Metadata' tab.",
            "2. Patients seen includes orthodontists visits. It is not possible to determine which patients were seen for orthodontic visits.",
            "3. A patient's age is calculated as at the given date."),
  dataset = geo_table3b_import,
  column_a_width = 20
)

accessibleTables::format_data(wb,
                              "Table_3b",
                              c("A", "B", "C", "D"),
                              "left",
                              "")

accessibleTables::format_data(wb,
                              "Table_3b",
                              c("E", "F"),
                              "right",
                              "#,###0")

openxlsx::setColWidths(
  wb,
  "Table_3b",
  c("A", "B", "C", "D", "E", "F"),
  widths = c(18, 17, 14, 50, 14, 14)
)

#Sheet for : Table_3c ----------------------------------------------------------
accessibleTables::write_sheet(
  workbook = wb,
  sheetname = "Table_3c",
  title = paste0("Table_3c: Adult patients seen in the previous 24 months and child patients seen in the previous 12 months by Local Authority, ", config$table_sheet_title_ltst_year),
  notes = c("1. Field definitions can be found on the 'Metadata' tab.",
            "2. Patients seen includes orthodontists visits. It is not possible to determine which patients were seen for orthodontic visits.",
            "3. A patient's age is calculated as at the given date."),
  dataset = geo_table3c_import,
  column_a_width = 20
)

accessibleTables::format_data(wb,
                              "Table_3c",
                              c("A", "B", "C"),
                              "left",
                              "")

accessibleTables::format_data(wb,
                              "Table_3c",
                              c("D", "E"),
                              "right",
                              "#,###0")

openxlsx::setColWidths(
  wb,
  "Table_3c",
  c("A", "B", "C", "D", "E", "F"),
  widths = c(18, 17, 32, 14, 14)
)

#Sheet for : Table_3d ----------------------------------------------------------
accessibleTables::write_sheet(
  workbook = wb,
  sheetname = "Table_3d",
  title = paste0("Table_3d: Adult patients seen in the previous 24 months and child patients seen in the previous 12 months, as a percentage of the population by NHS region, ", config$table_sheet_title_ltst_year),
  notes = c("1. Field definitions can be found on the 'Metadata' tab.",
            "2. Patients seen includes orthodontists visits. It is not possible to determine which patients were seen for orthodontic visits.",
            "3. A patient's age is calculated as at the given date.",
            "4. Population estimates for 2023 and 2024 were not available for NHS region or ICB levels at time of publication, so the 2022 mid-year estimate has been used for 2023/24 and 2024/25. Regional and ICB level numbers that are calculated using population data are provisional and will be updated once 2023 and 2024 population estimates are available.",
            "5. Mid-year population estimates from the Office for National Statistics (ONS) have been used. You can find more information about population estimates and a link to their source on the metadata sheet."),
  dataset = geo_table3d,
  column_a_width = 20
)

accessibleTables::format_data(wb,
                              "Table_3d",
                              c("A", "B", "C", "D", "E"),
                              "left",
                              "")

accessibleTables::format_data(wb,
                              "Table_3d",
                              c("F", "G"),
                              "right",
                              "#,###0")

accessibleTables::format_data(wb,
                              "Table_3d",
                              c("H", "I"),
                              "right",
                              "#,###0.00")

openxlsx::setColWidths(
  wb,
  "Table_3d",
  c("A", "B", "C", "D", "E", "F", "G", "H", "I"),
  widths = c(18, 17, 14, 22, 23, 17, 17, 24, 24)
)

#Sheet for : Table_3e ----------------------------------------------------------
accessibleTables::write_sheet(
  workbook = wb,
  sheetname = "Table_3e",
  title = paste0("Table_3e: Adult patients seen in the previous 24 months and child patients seen in the previous 12 months, as a percentage of the population by Integrated Care Board (ICB), ", config$table_sheet_title_ltst_year),
  notes = c("1. Field definitions can be found on the 'Metadata' tab.",
            "2. Patients seen includes orthodontists visits. It is not possible to determine which patients were seen for orthodontic visits.",
            "3. A patient's age is calculated as at the given date.",
            "4. Population estimates for 2023 and 2024 were not available for NHS region or ICB levels at time of publication, so the 2022 mid-year estimate has been used for 2023/24 and 2024/25. Regional and ICB level numbers that are calculated using population data are provisional and will be updated once 2023 and 2024 population estimates are available.",
            "5. Mid-year population estimates from the Office for National Statistics (ONS) have been used. You can find more information about population estimates and a link to their source on the metadata sheet."),
  dataset = geo_table3e,
  column_a_width = 20
)

accessibleTables::format_data(wb,
                              "Table_3e",
                              c("A", "B", "C", "D", "E"),
                              "left",
                              "")

accessibleTables::format_data(wb,
                              "Table_3e",
                              c("F", "G"),
                              "right",
                              "#,###0")

accessibleTables::format_data(wb,
                              "Table_3e",
                              c("H", "I"),
                              "right",
                              "#,###0.00")

openxlsx::setColWidths(
  wb,
  "Table_3e",
  c("A", "B", "C", "D", "E", "F", "G", "H", "I"),
  widths = c(18, 17, 14, 50, 17, 17, 17, 24, 24)
)

#Sheet for : Table_3f ----------------------------------------------------------
accessibleTables::write_sheet(
  workbook = wb,
  sheetname = "Table_3f",
  title = paste0("Table_3f: Adult patients seen in the previous 24 months and child patients seen in the previous 12 months, as a percentage of the population by Local Authority, ", config$table_sheet_title_ltst_year),
  notes = c("1. Field definitions can be found on the 'Metadata' tab.",
            "2. Patients seen includes orthodontists visits. It is not possible to determine which patients were seen for orthodontic visits.",
            "3. A patient's age is calculated as at the given date.",
            "4. Mid-year population estimates from the Office for National Statistics (ONS) have been used. You can find more information about population estimates and a link to their source on the metadata sheet."),
  dataset = geo_table3f,
  column_a_width = 20
)

accessibleTables::format_data(wb,
                              "Table_3f",
                              c("A", "B", "C", "D"),
                              "left",
                              "")

accessibleTables::format_data(wb,
                              "Table_3f",
                              c("E","F"),
                              "right",
                              "#,###0")

accessibleTables::format_data(wb,
                              "Table_3f",
                              c("G", "H"),
                              "right",
                              "#,###0.00")

openxlsx::setColWidths(
  wb,
  "Table_3f",
  c("A", "B", "C", "D", "E", "F", "G", "H"),
  widths = c(18, 17, 30, 22, 17, 17, 24, 24)
)

accessibleTables::makeCoverSheet(
  config$publication_name,
  config$cover_sheet_sub_title_geo_activity_contract,
  paste0("Publication date: ", config$publication_date),
  wb,
  sheetNames,
  c(
    "Metadata",
    "Table_1a: Count of courses of treatment by NHS region and treatment band in 2024/25",
    "Table_1ai: Count of courses of treatment by NHS region, Dental Care Professional type, and treatment band, 2022/2023 to 2024/2025",
    "Table_1b: Count of courses of treatment by Integrated Care Board (ICB) and treatment band in 2024/25",
    "Table_1bi: Count of courses of treatment by Integrated Care Board (ICB), Dental Care Professional type, and treatment band, 2022/2023 to 2024/2025",
    "Table_1c: Count of courses of treatment by Local Authority and treatment band in 2024/25",
    "Table_1ci: Count of courses of treatment by Local Authority, Dental Care Professional type, and treatment band, 2022/2023 to 2024/2025",
    "Table_1d: Percentage of courses of treatment by NHS region and treatment band in 2024/25",
    "Table_1e: Percentage of courses of treatment by Integrated Care Board (ICB) and treatment band in 2024/25",
    "Table_1f: Percentage of courses of treatment by Local Authority and treatment band in 2024/25",
    "Table_2a: Count of units of dental activity by NHS region and treatment band in 2024/25",
    "Table_2ai: Count of units of dental activity by NHS region, Dental Care Professional type, and treatment band, 2022/2023 to 2024/2025",
    "Table_2b: Count of units of dental activity by Integrated Care Board (ICB) and treatment band in 2024/25",
    "Table_2bi: Count of units of dental activity by Integrated Care Board (ICB), Dental Care Professional type, and treatment band, 2022/2023 to 2024/2025",
    "Table_2c: Count of units of dental activity by Local Authority and treatment band in 2024/25",
    "Table_2ci: Count of units of dental activity by Local Authority, Dental Care Professional type, and treatment band, 2022/2023 to 2024/2025",
    "Table_2d: Percentage of units of dental activity by NHS region and treatment band in 2024/25",
    "Table_2e: Percentage of units of dental activity by Integrated Care Board (ICB) and treatment band in 2024/25",
    "Table_2f: Percentage of units of dental activity by Local Authority and treatment band in 2024/25",
    "Table_3a: Adult patients seen in the previous 24 months and child patients seen in the previous 12 months by NHS region in 2024/25",
    "Table_3b: Adult patients seen in the previous 24 months and child patients seen in the previous 12 months by Integrated Care Board (ICB) in 2024/25",
    "Table_3c: Adult patients seen in the previous 24 months and child patients seen in the previous 12 months by Local Authority in 2024/25",
    "Table_3d: Adult patients seen in the previous 24 months and child patients seen in the previous 12 months, as a percentage of the population by NHS region in 2024/25",
    "Table_3e: Adult patients seen in the previous 24 months and child patients seen in the previous 12 months, as a percentage of the population by Integrated Care Board (ICB) in 2024/25",
    "Table_3f: Adult patients seen in the previous 24 months and child patients seen in the previous 12 months, as a percentage of the population by Local Authority in 2024/25"
  ),
  c("Metadata", sheetNames)
)

#Export to Excel ---------------------------------
openxlsx::saveWorkbook(
  wb,
  "outputs/dental_contract_geo_breakdown_24_25.xlsx",
  overwrite = TRUE
)