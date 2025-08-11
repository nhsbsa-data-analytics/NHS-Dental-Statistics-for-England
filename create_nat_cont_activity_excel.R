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

#Sheet for : Table_1a_i ---------------------------------
accessibleTables::write_sheet(
  workbook = wb,
  sheetname = "Table_1a_i",
  title = paste0("Table_1a_i: Count of courses of treatment by treatment band and financial year, ", config$table_sheet_title_fy),
  notes = c("notes go here"),
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
  notes = c("notes go here"),
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
  notes = c("notes go here"),
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
  notes = c("notes go here"),
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
  notes = c("notes go here"),
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
  notes = c("notes go here"),
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
  notes = c("notes go here"),
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
  notes = c("notes go here"),
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
  notes = c("notes go here"),
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
  notes = c("notes go here"),
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
  notes = c("notes go here"),
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
  notes = c("notes go here"),
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
  notes = c("notes go here"),
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
  notes = c("notes go here"),
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
  notes = c("notes go here"),
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
  notes = c("notes go here"),
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
  notes = c("notes go here"),
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
  notes = c("notes go here"),
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
  notes = c("notes go here"),
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
  notes = c("notes go here"),
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
  notes = c("notes go here"),
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
  notes = c("notes go here"),
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
  notes = c("notes go here"),
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
  notes = c("notes go here"),
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
  notes = c("notes go here"),
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
  notes = c("notes go here"),
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
  notes = c("notes go here"),
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
  notes = c("notes go here"),
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
  notes = c("notes go here"),
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