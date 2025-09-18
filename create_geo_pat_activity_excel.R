#script to format data to build geographical breakdown excel files
#for patient location activity tables
#added DCP COTs tables (1ai, 1bi and 1ci) by Region, ICB, LA and Ward for 2024/25 publication
#added IMD COTs and UDAs tables (4a and 5a)

#TO DO: decide if adding table 6a for patients seen by IMD

#this script to be called in main `pipeline.R` script
#functions loaded in main pipeline

# Create sheets ready for export to Excel ---------------------------------
sheetNames <- c(
  "Table_1a",
  "Table_1b",
  "Table_1c",
  "Table_1d",
  "Table_1e",
  "Table_1f",
  "Table_1g",
  "Table_1h",
  "Table_2a",
  "Table_2b",
  "Table_2c",
  "Table_2d",
  "Table_2e",
  "Table_2f",
  "Table_2g",
  "Table_2h",
  "Table_3a",
  "Table_3b",
  "Table_3c",
  "Table_3d",
  "Table_3e",
  "Table_3f",
  "Table_3g",
  "Table_3h",
  "Table_4a",
  "Table_5a"  
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
  "Local authority name",
  "Ward name",
  "IMD quintile",
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
    "Patient eligibility is the eligibility group of the patient. Adults undergoing NHS dental activity normally pay a set amount of money towards treatment, unless they have a valid exemption. Children aged under 18, or under 19 and in full-time education, do not pay for treatment. More information on patient charges and exemptions can be found in the background and methodology document.",
    "A count of patients aged 18 or over seen by an NHS dentist in the 24 months up to the end of the specified period.",
    "A count of patients aged 17 or under seen by an NHS dentist in the 12 months up to the end of the specified period.",
    "The age group which the data has been aggregated up to, where age is the age of a patient at the date of acceptance for treatment. For example, age group 18-64 includes all patients aged 18 to 64.",
    "The date of the specified period.",
    "The population estimate for the corresponding mid-year population year, from the latest ONS population estimates at time of publication. Population estimates for 2023 or 2024 were not available for NHS region or ICB levels, so these currently use the 2022 mid-year estimate for 2023/24 and 2024/25. Regional and ICB level numbers that are calculated using population data are provisional and will be updated once 2023 and 2024 population estimates are available. Local authority numbers for 2024/25 use mid-year population estimates for 2024 and are in their final form. All estimates are taken from the ONS website at https://www.ons.gov.uk/peoplepopulationandcommunity/populationandmigration.",
    "The year in which the Office for National Statistics (ONS) mid-year population estimates were taken, required due to the presentation of this data in financial year format.",
    "The Organisation Data Service (ODS) code the data has been aggregated up to. For example, Devon ICB has an ODS code of QJK. Local Authorities and Wards do not have ODS codes",
    "The Office for National Statistics (ONS) geography code which the data has been aggregated up to. For example, Hartlepool local authority has an ONS code of E06000001. H&J commissioners do not have ONS codes.",
    "The name of the NHS region the data has been aggregated up to, based on the patient's postcode. For example, East of England.",
    "The name of the Integrated Care Board (ICB) the data has been aggregated up to, based on the patient's postcode. For example, Devon ICB. ICBs were introduced in 2022. More information on ICBs and how data is mapped to boundaries can be found in the background and methodology document for this release. ICB level tables also include Health and Justice (H&J) commissioners.",
    "The name of the Local Authority (LA) the data has been aggregated to, based on the patient's postcode. For example, Darlington.",
    "The name of the Ward the data has been aggregated to, based on the patient's postcode. For example, Ainsdale.",
    "The Index of Multiple Deprivation (IMD) quintile of the patient's postcode record on the FP17 form. Quintile 1 is the 20% of areas with the highest deprivation score in the Index of Multiple Deprivation (IMD) from the English Indices of Deprivation 2019, and quintile 5 is the 20% of areas with the lowest IMD deprivation score. IMD quintile has been recorded as 'Unknown' where we have been unable to match the patient postcode using the National Statistics Postcode Lookup (NSPL).",
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
  dataset = table_1a_geo_pat,
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

#Sheet for : Table_1b ----------------------------------------------------------
accessibleTables::write_sheet(
  workbook = wb,
  sheetname = "Table_1b",
  title = paste0("Table_1b: Count of courses of treatment by Integrated Care Board (ICB) and treatment band, ", config$table_sheet_title_ltst_year),
  notes = c("1. Field definitions can be found on the 'Metadata' tab."),
  dataset = table_1b_geo_pat,
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

#Sheet for : Table_1c ----------------------------------------------------------
accessibleTables::write_sheet(
  workbook = wb,
  sheetname = "Table_1c",
  title = paste0("Table_1c: Count of courses of treatment by Local Authority and treatment band, ", config$table_sheet_title_ltst_year),
  notes = c("1. Field definitions can be found on the 'Metadata' tab."),
  dataset = table_1c_geo_pat,
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

#Sheet for : Table_1d ----------------------------------------------------------
accessibleTables::write_sheet(
  workbook = wb,
  sheetname = "Table_1d",
  title = paste0("Table_1d: Count of courses of treatment by Ward and treatment band, ", config$table_sheet_title_ltst_year),
  notes = c("1. Field definitions can be found on the 'Metadata' tab."),
  dataset = table_1d_geo_pat,
  column_a_width = 20
)

accessibleTables::format_data(wb,
                              "Table_1d",
                              c("A", "B", "C"),
                              "left",
                              "")

accessibleTables::format_data(wb,
                              "Table_1d",
                              c("D", "E", "F", "G", "H", "I", "J", "K", "L", "M"),
                              "right",
                              "#,###0")

openxlsx::setColWidths(
  wb,
  "Table_1d",
  c("A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M"),
  widths = c(20, 17, 14, 22, 14, 14, 14, 14, 14, 14, 14, 37, 14)
)

#Sheet for : Table_1e ----------------------------------------------------------
accessibleTables::write_sheet(
  workbook = wb,
  sheetname = "Table_1e",
  title = paste0("Table_1e: Percentage of courses of treatment by NHS region and treatment band, ", config$table_sheet_title_ltst_year),
  notes = c("1. Field definitions can be found on the 'Metadata' tab."),
  dataset = table_1e_geo_pat,
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
  title = paste0("Table_1f: Percentage of courses of treatment by Integrated Care Board (ICB) and treatment band, ", config$table_sheet_title_ltst_year),
  notes = c("1. Field definitions can be found on the 'Metadata' tab."),
  dataset = table_1f_geo_pat,
  column_a_width = 20
)

accessibleTables::format_data(wb,
                              "Table_1f",
                              c("A", "B", "C", "D"),
                              "left",
                              "")

accessibleTables::format_data(wb,
                              "Table_1f",
                              c("E", "F", "G", "H", "I", "J", "K", "L", "M", "N"),
                              "right",
                              "#,###0.00")

openxlsx::setColWidths(
  wb,
  "Table_1f",
  c("A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N"),
  widths = c(18, 17, 14, 50, 14, 14, 14, 14, 14, 14, 14, 14, 37, 14)
)

#Sheet for : Table_1g ----------------------------------------------------------
accessibleTables::write_sheet(
  workbook = wb,
  sheetname = "Table_1g",
  title = paste0("Table_1g: Percentage of courses of treatment by Local Authority and treatment band, ", config$table_sheet_title_ltst_year),
  notes = c("1. Field definitions can be found on the 'Metadata' tab."),
  dataset = table_1g_geo_pat,
  column_a_width = 20
)

accessibleTables::format_data(wb,
                              "Table_1g",
                              c("A", "B", "C"),
                              "left",
                              "")

accessibleTables::format_data(wb,
                              "Table_1g",
                              c("D", "E", "F", "G", "H", "I", "J", "K", "L", "M"),
                              "right",
                              "#,###0.00")

openxlsx::setColWidths(
  wb,
  "Table_1g",
  c("A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M"),
  widths = c(18, 17, 32, 14, 14, 14, 14, 14, 14, 14, 14, 37, 14)
)

#Sheet for : Table_1h ----------------------------------------------------------
accessibleTables::write_sheet(
  workbook = wb,
  sheetname = "Table_1h",
  title = paste0("Table_1h: Percentage of courses of treatment by Ward and treatment band, ", config$table_sheet_title_ltst_year),
  notes = c("1. Field definitions can be found on the 'Metadata' tab."),
  dataset = table_1h_geo_pat,
  column_a_width = 20
)

accessibleTables::format_data(wb,
                              "Table_1h",
                              c("A", "B", "C"),
                              "left",
                              "")

accessibleTables::format_data(wb,
                              "Table_1h",
                              c("D", "E", "F", "G", "H", "I", "J", "K", "L", "M"),
                              "right",
                              "#,###0.00")

openxlsx::setColWidths(
  wb,
  "Table_1h",
  c("A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M"),
  widths = c(18, 17, 32, 14, 14, 14, 14, 14, 14, 14, 14, 37, 14)
)


#Sheet for : Table_2a ----------------------------------------------------------
accessibleTables::write_sheet(
  workbook = wb,
  sheetname = "Table_2a",
  title = paste0("Table_2a: Count of units of dental activity by NHS region and treatment band, ", config$table_sheet_title_ltst_year),
  notes = c("1. Field definitions can be found on the 'Metadata' tab."),
  dataset = table_2a_geo_pat,
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

#Sheet for : Table_2b ----------------------------------------------------------
accessibleTables::write_sheet(
  workbook = wb,
  sheetname = "Table_2b",
  title = paste0("Table_2b: Count of units of dental activity by Integrated Care Board (ICB) and treatment band, ", config$table_sheet_title_ltst_year),
  notes = c("1. Field definitions can be found on the 'Metadata' tab."),
  dataset = table_2b_geo_pat,
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

#Sheet for : Table_2c ----------------------------------------------------------
accessibleTables::write_sheet(
  workbook = wb,
  sheetname = "Table_2c",
  title = paste0("Table_2c: Count of units of dental activity by Local Authority and treatment band, ", config$table_sheet_title_ltst_year),
  notes = c("1. Field definitions can be found on the 'Metadata' tab."),
  dataset = table_2c_geo_pat,
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

#Sheet for : Table_2d ----------------------------------------------------------
accessibleTables::write_sheet(
  workbook = wb,
  sheetname = "Table_2d",
  title = paste0("Table_2d: Count of units of dental activity by Ward and treatment band, ", config$table_sheet_title_ltst_year),
  notes = c("1. Field definitions can be found on the 'Metadata' tab."),
  dataset = table_2d_geo_pat,
  column_a_width = 20
)

accessibleTables::format_data(wb,
                              "Table_2d",
                              c("A", "B", "C"),
                              "left",
                              "")

accessibleTables::format_data(wb,
                              "Table_2d",
                              c("D", "E", "F", "G", "H", "I", "J", "K", "L", "M"),
                              "right",
                              "#,###0")

openxlsx::setColWidths(
  wb,
  "Table_2d",
  c("A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M"),
  widths = c(18, 17, 32, 14, 14, 14, 14, 14, 14, 14, 14, 37, 14)
)

#Sheet for : Table_2e ----------------------------------------------------------
accessibleTables::write_sheet(
  workbook = wb,
  sheetname = "Table_2e",
  title = paste0("Table_2e: Percentage of units of dental activity by NHS region and treatment band, ", config$table_sheet_title_ltst_year),
  notes = c("1. Field definitions can be found on the 'Metadata' tab."),
  dataset = table_2e_geo_pat,
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
  widths = c(18, 17, 14, 22, 14, 14, 14, 14, 14, 14, 14, 14, 37, 14)
)

#Sheet for : Table_2f ----------------------------------------------------------
accessibleTables::write_sheet(
  workbook = wb,
  sheetname = "Table_2f",
  title = paste0("Table_2f: Percentage of units of dental activity by Integrated Care Board (ICB) and treatment band, ", config$table_sheet_title_ltst_year),
  notes = c("1. Field definitions can be found on the 'Metadata' tab."),
  dataset = table_2f_geo_pat,
  column_a_width = 20
)

accessibleTables::format_data(wb,
                              "Table_2f",
                              c("A", "B", "C", "D"),
                              "left",
                              "")

accessibleTables::format_data(wb,
                              "Table_2f",
                              c("E", "F", "G", "H", "I", "J", "K", "L", "M", "N"),
                              "right",
                              "#,###0.00")

openxlsx::setColWidths(
  wb,
  "Table_2f",
  c("A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N"),
  widths = c(18, 17, 14, 50, 14, 14, 14, 14, 14, 14, 14, 14, 37, 14)
)

#Sheet for : Table_2g ----------------------------------------------------------
accessibleTables::write_sheet(
  workbook = wb,
  sheetname = "Table_2g",
  title = paste0("Table_2g: Percentage of units of dental activity by Local Authority and treatment band, ", config$table_sheet_title_ltst_year),
  notes = c("1. Field definitions can be found on the 'Metadata' tab."),
  dataset = table_2g_geo_pat,
  column_a_width = 20
)

accessibleTables::format_data(wb,
                              "Table_2g",
                              c("A", "B", "C"),
                              "left",
                              "")

accessibleTables::format_data(wb,
                              "Table_2g",
                              c("D", "E", "F", "G", "H", "I", "J", "K", "L", "M"),
                              "right",
                              "#,###0.00")

openxlsx::setColWidths(
  wb,
  "Table_2g",
  c("A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M"),
  widths = c(18, 17, 32, 14, 14, 14, 14, 14, 14, 14, 14, 37, 14)
)

#Sheet for : Table_2h ----------------------------------------------------------
accessibleTables::write_sheet(
  workbook = wb,
  sheetname = "Table_2h",
  title = paste0("Table_2h: Percentage of units of dental activity by Ward and treatment band, ", config$table_sheet_title_ltst_year),
  notes = c("1. Field definitions can be found on the 'Metadata' tab."),
  dataset = table_2h_geo_pat,
  column_a_width = 20
)

accessibleTables::format_data(wb,
                              "Table_2h",
                              c("A", "B", "C"),
                              "left",
                              "")

accessibleTables::format_data(wb,
                              "Table_2h",
                              c("D", "E", "F", "G", "H", "I", "J", "K", "L", "M"),
                              "right",
                              "#,###0.00")

openxlsx::setColWidths(
  wb,
  "Table_2h",
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
  dataset = table_3a_geo_pat,
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
  dataset = table_3b_geo_pat,
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
  dataset = table_3c_geo_pat,
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
  title = paste0("Table_3d: Adult patients seen in the previous 24 months and child patients seen in the previous 12 months by Ward, ", config$table_sheet_title_ltst_year),
  notes = c("1. Field definitions can be found on the 'Metadata' tab.",
            "2. Patients seen includes orthodontists visits. It is not possible to determine which patients were seen for orthodontic visits.",
            "3. A patient's age is calculated as at the given date."),
  dataset = table_3d_geo_pat,
  column_a_width = 20
)

accessibleTables::format_data(wb,
                              "Table_3d",
                              c("A", "B", "C"),
                              "left",
                              "")

accessibleTables::format_data(wb,
                              "Table_3d",
                              c("D", "E"),
                              "right",
                              "#,###0")

openxlsx::setColWidths(
  wb,
  "Table_3d",
  c("A", "B", "C", "D", "E", "F"),
  widths = c(18, 17, 32, 14, 14)
)

#Sheet for : Table_3e ----------------------------------------------------------
accessibleTables::write_sheet(
  workbook = wb,
  sheetname = "Table_3e",
  title = paste0("Table_3e: Adult patients seen in the previous 24 months and child patients seen in the previous 12 months, as a percentage of the population by NHS region, ", config$table_sheet_title_ltst_year),
  notes = c("1. Field definitions can be found on the 'Metadata' tab.",
            "2. Patients seen includes orthodontists visits. It is not possible to determine which patients were seen for orthodontic visits.",
            "3. A patient's age is calculated as at the given date.",
            "4. Population estimates for 2023 and 2024 were not available for NHS regions, ICBs, or Wards at time of publication, so the 2022 mid-year estimate has been used for 2023/24 and 2024/25. Regional, ICB, and Ward level numbers that are calculated using population data are provisional and will be updated once 2023 and 2024 population estimates are available.",
            "5. Mid-year population estimates from the Office for National Statistics (ONS) have been used. You can find more information about population estimates and a link to their source on the metadata sheet."),
  dataset = table_3e_geo_pat,
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
  widths = c(18, 17, 14, 22, 23, 17, 17, 24, 24)
)

#Sheet for : Table_3f ----------------------------------------------------------
accessibleTables::write_sheet(
  workbook = wb,
  sheetname = "Table_3f",
  title = paste0("Table_3f: Adult patients seen in the previous 24 months and child patients seen in the previous 12 months, as a percentage of the population by Integrated Care Board (ICB), ", config$table_sheet_title_ltst_year),
  notes = c("1. Field definitions can be found on the 'Metadata' tab.",
            "2. Patients seen includes orthodontists visits. It is not possible to determine which patients were seen for orthodontic visits.",
            "3. A patient's age is calculated as at the given date.",
            "4. Population estimates for 2023 and 2024 were not available for NHS regions, ICBs, or Wards at time of publication, so the 2022 mid-year estimate has been used for 2023/24 and 2024/25. Regional, ICB, and Ward level numbers that are calculated using population data are provisional and will be updated once 2023 and 2024 population estimates are available.",
            "5. Mid-year population estimates from the Office for National Statistics (ONS) have been used. You can find more information about population estimates and a link to their source on the metadata sheet."),
  dataset = table_3f_geo_pat,
  column_a_width = 20
)

accessibleTables::format_data(wb,
                              "Table_3f",
                              c("A", "B", "C", "D", "E"),
                              "left",
                              "")

accessibleTables::format_data(wb,
                              "Table_3f",
                              c("F", "G"),
                              "right",
                              "#,###0")

accessibleTables::format_data(wb,
                              "Table_3f",
                              c("H", "I"),
                              "right",
                              "#,###0.00")

openxlsx::setColWidths(
  wb,
  "Table_3f",
  c("A", "B", "C", "D", "E", "F", "G", "H", "I"),
  widths = c(18, 17, 14, 50, 17, 17, 17, 24, 24)
)

#Sheet for : Table_3g ----------------------------------------------------------
accessibleTables::write_sheet(
  workbook = wb,
  sheetname = "Table_3g",
  title = paste0("Table_3g: Adult patients seen in the previous 24 months and child patients seen in the previous 12 months, as a percentage of the population by Local Authority, ", config$table_sheet_title_ltst_year),
  notes = c("1. Field definitions can be found on the 'Metadata' tab.",
            "2. Patients seen includes orthodontists visits. It is not possible to determine which patients were seen for orthodontic visits.",
            "3. A patient's age is calculated as at the given date.",
            "4. Mid-year population estimates from the Office for National Statistics (ONS) have been used. You can find more information about population estimates and a link to their source on the metadata sheet."),
  dataset = table_3g_geo_pat,
  column_a_width = 20
)

accessibleTables::format_data(wb,
                              "Table_3g",
                              c("A", "B", "C", "D"),
                              "left",
                              "")

accessibleTables::format_data(wb,
                              "Table_3g",
                              c("E","F"),
                              "right",
                              "#,###0")

accessibleTables::format_data(wb,
                              "Table_3g",
                              c("G", "H"),
                              "right",
                              "#,###0.00")

openxlsx::setColWidths(
  wb,
  "Table_3g",
  c("A", "B", "C", "D", "E", "F", "G", "H"),
  widths = c(18, 17, 30, 22, 17, 17, 24, 24)
)

#Sheet for : Table_3h ----------------------------------------------------------
accessibleTables::write_sheet(
  workbook = wb,
  sheetname = "Table_3h",
  title = paste0("Table_3h: Adult patients seen in the previous 24 months and child patients seen in the previous 12 months, as a percentage of the population by Ward, ", config$table_sheet_title_ltst_year),
  notes = c("1. Field definitions can be found on the 'Metadata' tab.",
            "2. Patients seen includes orthodontists visits. It is not possible to determine which patients were seen for orthodontic visits.",
            "3. A patient's age is calculated as at the given date.",
            "4. Population estimates for 2023 and 2024 were not available for NHS regions, ICBs, or Wards at time of publication, so the 2022 mid-year estimate has been used for 2023/24 and 2024/25. Regional, ICB, and Ward level numbers that are calculated using population data are provisional and will be updated once 2023 and 2024 population estimates are available.",
            "5. Mid-year population estimates from the Office for National Statistics (ONS) have been used. You can find more information about population estimates and a link to their source on the metadata sheet."),
  dataset = table_3h_geo_pat,
  column_a_width = 20
)

accessibleTables::format_data(wb,
                              "Table_3h",
                              c("A", "B", "C", "D"),
                              "left",
                              "")

accessibleTables::format_data(wb,
                              "Table_3h",
                              c("E","F"),
                              "right",
                              "#,###0")

accessibleTables::format_data(wb,
                              "Table_3h",
                              c("G", "H"),
                              "right",
                              "#,###0.00")

openxlsx::setColWidths(
  wb,
  "Table_3h",
  c("A", "B", "C", "D", "E", "F", "G", "H"),
  widths = c(18, 17, 30, 22, 17, 17, 24, 24)
)

#Sheet for: Table_4a IMD COTs --------------------------------------------------

accessibleTables::write_sheet(
  workbook = wb,
  sheetname = "Table_4a",
  title = paste0("Table_4a: Courses of treatment by Index of Multiple Deprivation (IMD) quintile, treatment band, and financial year, ", config$table_sheet_title_fy),
  notes = c("1. Field definitions can be found on the 'Metadata' tab."),
  dataset = table_4a_geo_pat,
  column_a_width = 20
)

accessibleTables::format_data(wb,
                              "Table_4a",
                              c("A", "B"),
                              "left",
                              "")

accessibleTables::format_data(wb,
                              "Table_4a",
                              c("C", "D", "E", "F", "G", "H", "I", "J", "K", "L"),
                              "right",
                              "#,###0")

openxlsx::setColWidths(
  wb,
  "Table_4a",
  c("A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L"),
  widths = c(20, 35, 14, 14, 14, 14, 14, 14, 14, 14, 37, 14)
)

#Sheet for: Table_5a IMD COTs --------------------------------------------------

accessibleTables::write_sheet(
  workbook = wb,
  sheetname = "Table_5a",
  title = paste0("Table_5a: Units of dental activity by Index of Multiple Deprivation (IMD) quintile, treatment band, and financial year, ", config$table_sheet_title_fy),
  notes = c("1. Field definitions can be found on the 'Metadata' tab."),
  dataset = table_5a_geo_pat,
  column_a_width = 20
)

accessibleTables::format_data(wb,
                              "Table_5a",
                              c("A", "B"),
                              "left",
                              "")

accessibleTables::format_data(wb,
                              "Table_5a",
                              c("C", "D", "E", "F", "G", "H", "I", "J", "K", "L"),
                              "right",
                              "#,###0")

openxlsx::setColWidths(
  wb,
  "Table_5a",
  c("A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L"),
  widths = c(20, 35, 14, 14, 14, 14, 14, 14, 14, 14, 37, 14)
)


accessibleTables::makeCoverSheet(
  config$publication_name,
  config$cover_sheet_sub_title_geo_activity_patient,
  paste0("Publication date: ", config$publication_date),
  wb,
  sheetNames,
  c(
    "Metadata",
    "Table_1a: Count of courses of treatment by NHS region and treatment band in 2024/25",
    "Table_1b: Count of courses of treatment by Integrated Care Board (ICB) and treatment band in 2024/25",
    "Table_1c: Count of courses of treatment by Local Authority and treatment band in 2024/25",
    "Table_1d: Count of courses of treatment by Ward and treatment band in 2024/25",
    "Table_1e: Percentage of courses of treatment by NHS region and treatment band in 2024/25",
    "Table_1f: Percentage of courses of treatment by Integrated Care Board (ICB) and treatment band in 2024/25",
    "Table_1g: Percentage of courses of treatment by Local Authority and treatment band in 2024/25",
    "Table_1h: Percentage of courses of treatment by Ward and treatment band in 2024/25",
    "Table_2a: Count of units of dental activity by NHS region and treatment band in 2024/25",
    "Table_2b: Count of units of dental activity by Integrated Care Board (ICB) and treatment band in 2024/25",
    "Table_2c: Count of units of dental activity by Local Authority and treatment band in 2024/25",
    "Table_2d: Count of units of dental activity by Ward and treatment band in 2024/25",
    "Table_2e: Percentage of units of dental activity by NHS region and treatment band in 2024/25",
    "Table_2f: Percentage of units of dental activity by Integrated Care Board (ICB) and treatment band in 2024/25",
    "Table_2g: Percentage of units of dental activity by Local Authority and treatment band in 2024/25",
    "Table_2h: Percentage of units of dental activity by Ward and treatment band in 2024/25",
    "Table_3a: Adult patients seen in the previous 24 months and child patients seen in the previous 12 months by NHS region in 2024/25",
    "Table_3b: Adult patients seen in the previous 24 months and child patients seen in the previous 12 months by Integrated Care Board (ICB) in 2024/25",
    "Table_3c: Adult patients seen in the previous 24 months and child patients seen in the previous 12 months by Local Authority in 2024/25",
    "Table_3d: Adult patients seen in the previous 24 months and child patients seen in the previous 12 months by Ward in 2024/25",
    "Table_3e: Adult patients seen in the previous 24 months and child patients seen in the previous 12 months, as a percentage of the population by NHS region in 2024/25",
    "Table_3f: Adult patients seen in the previous 24 months and child patients seen in the previous 12 months, as a percentage of the population by Integrated Care Board (ICB) in 2024/25",
    "Table_3g: Adult patients seen in the previous 24 months and child patients seen in the previous 12 months, as a percentage of the population by Local Authority in 2024/25",
    "Table_3h: Adult patients seen in the previous 24 months and child patients seen in the previous 12 months, as a percentage of the population by Ward in 2024/25",
    "Table_4a: Count of courses of treatment by Index of Multiple deprivation (IMD) quintile, 2019/20 to 2024/25",
    "Table_5a: Count of units of dental activity by Index of Multiple deprivation (IMD) quintile, 2019/20 to 2024/25"
  ),
  c("Metadata", sheetNames)
)

#Export to Excel ---------------------------------
openxlsx::saveWorkbook(
  wb,
  "outputs/dental_patient_geo_breakdown_24_25_v001.xlsx",
  overwrite = TRUE
)