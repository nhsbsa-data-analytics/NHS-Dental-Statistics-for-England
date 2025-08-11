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
  "Table_2b",
  "Table_2c",
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

#Sheet for : Table_1a ----------------------------------------------------------
accessibleTables::write_sheet(
  workbook = wb,
  sheetname = "Table_1a",
  title = paste0("Table_1a: Count of courses of treatment by NHS region and treatment band, ", config$table_sheet_title_ltst_year),
  notes = c("notes go here"),
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
  notes = c("notes go here"),
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
  notes = c("notes go here"),
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
  notes = c("notes go here"),
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
  notes = c("notes go here"),
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
  notes = c("notes go here"),
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
  notes = c("notes go here"),
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
  notes = c("notes go here"),
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
  notes = c("notes go here"),
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
  notes = c("notes go here"),
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

#Sheet for : Table_2b ----------------------------------------------------------
accessibleTables::write_sheet(
  workbook = wb,
  sheetname = "Table_2b",
  title = paste0("Table_2b: Count of units of dental activity by Integrated Care Board (ICB) and treatment band, ", config$table_sheet_title_ltst_year),
  notes = c("notes go here"),
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

#Sheet for : Table_2c ----------------------------------------------------------
accessibleTables::write_sheet(
  workbook = wb,
  sheetname = "Table_2c",
  title = paste0("Table_2c: Count of units of dental activity by Local Authority and treatment band, ", config$table_sheet_title_ltst_year),
  notes = c("notes go here"),
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

#Sheet for : Table_2d ----------------------------------------------------------
accessibleTables::write_sheet(
  workbook = wb,
  sheetname = "Table_2d",
  title = paste0("Table_2d: Percentage of units of dental activity by NHS region and treatment band, ", config$table_sheet_title_ltst_year),
  notes = c("notes go here"),
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
  notes = c("notes go here"),
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
  notes = c("notes go here"),
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
  notes = c("notes go here"),
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
  notes = c("notes go here"),
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
  notes = c("notes go here"),
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
  notes = c("notes go here"),
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
  notes = c("notes go here"),
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
  notes = c("notes go here"),
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
    "Table_2b: Count of units of dental activity by Integrated Care Board (ICB) and treatment band in 2024/25",
    "Table_2c: Count of units of dental activity by Local Authority and treatment band in 2024/25",
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
  "outputs/dental_geographical_breakdown_24_25.xlsx",
  overwrite = TRUE
)