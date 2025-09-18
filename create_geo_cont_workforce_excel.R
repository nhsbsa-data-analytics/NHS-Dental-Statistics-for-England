#script to format data to build workforce excel files
#for contract location workforce tables
#this script to be called in main `pipeline.R` script
#functions loaded in main pipeline

# Dental workforce England excel file
# create wb object
# create list of sheetnames needed (overview and metadata created automatically)
sheetNames <- c(
  "Table_1a",
  "Table_1b",
  "Table_1c",
  "Table_2a",
  "Table_2b",
  "Table_2c",
  "Table_2d",
  "Table_2e",
  "Table_3a"
)

wb <- accessibleTables::create_wb(sheetNames)

#create metadata tab (will need to open file and auto row heights once ran)
meta_fields <- c(
  "Age Band",
  "Contract type",
  "Dentists",
  "Dental Care Professionals (DCPs)",
  "Dentist type",
  "Financial Year",
  "Health and Justice (H&J) commissioner",
  "Integrated Care Board (ICB)",
  "Joiner",
  "Leaver",
  "Mid-year England population estimate",
  "Mid-year population year",
  "Region",
  "Sub-Integrated Careboard Location (SICBL)")

meta_descs <-
  c(
    "The age band of the performer as of the 30th September of the financial year in which the activity was recorded.",
    "The contract type a dentist is associated with. This can be General Dental Services (GDS), Personal Dental Services (PDS) or Trust-led Dental Services (TDS). If a dentist has had multiple different contract types in the same year, this will be recorded as 'Mixed'.",
    "Dentists are defined as performers with NHS activity recorded by FP17 forms. Dental Care Professionals (DCPs) have been excluded from tables 1a to 2e. To be included in the data a dentist must have performed at least 1 unit of dental activity (UDA) or unit of orthodontic activity (UOA) in the specified year.",
    "DCPs are only included in table 3a. DCPs are non-dentist roles, with dental hygienists and dental therapists the only DCP roles permitted to lead on dental activity within their General Dental Council (GDC) scope of practice. DCPs are only included if they were the main performer associated with NHS activity on an FP17 form, with at least 1 UDA or UOA in the financial year.",
    "Dentist type. Associates were previously called 'Performer only' dentists. Foundation dentists and performer-only dentists are included as associates.",
    "The financial year to which the data belongs. For example, 2024/2025 covers April 2024 to March 2025.",
    "H&J commissioners commission dental services for people in prisons and young offender institutions in England. There are 7 H&J commissioners. Population estimates are not available for H&Js, so population related columns will be blank for H&J dentists.",
    "The ICB which is the commissioning organisation of a performer's contract.",
    "A joiner is defined as a performer who carried out NHS dental activity in the specified year but none in the previous year, recorded via FP17 forms.",
    "A leaver is defined as a performer who carried out NHS dental activity in the previous financial year but none in the following year, recorded via FP17 forms.",
    "The population estimate for the corresponding mid-year population year. National mid-year population estimates have been taken from the latest ONS population estimates at time of publication. The estimates are available from: https://www.ons.gov.uk/peoplepopulationandcommunity/populationandmigration/populationestimates/datasets/estimatesofthepopulationforenglandandwales .",
    "The year in which the Office for National Statistics (ONS) mid-year population estimates were taken, required due to the presentation of this data in financial year format.",
    "The NHS region the dental contract is located in. The region has been mapped up from the ICB of the contract",
    "The SICBL of the primary correspondence address of the performer. This may be different to the location of the commissioning organisation used for ICB and NHS region.")

accessibleTables::create_metadata(wb,
                                  meta_fields,
                                  meta_descs)

# write data to sheet
accessibleTables::write_sheet(
  wb,
  "Table_1a",
  paste0("Table 1a: Number of dentists with NHS activity, ",config$table_sheet_title_fy),
  c(
    "1. Field definitions can be found on the 'Metadata' tab.",
    "2. Dentists are defined as performers with NHS activity recorded by FP17 forms. DCPs such as dental hygienists or dental therapists are excluded from this table.",
    "3. Data consists of performers in General Dental Services (GDS), Personal Dental Services (PDS) and Trust-led Dental Services (TDS).",
    "4. Joiners and leavers data is not available for 2019/2020 due to data retention periods of some raw data."
  ),
  table_1a_wf,
  30
)

accessibleTables::format_data(wb,
                              "Table_1a",
                              c("A"),
                              "left",
                              "")

accessibleTables::format_data(wb,
                              "Table_1a",
                              c( "B", "C", "D"),
                              "right",
                              "#,##0")

# write data to sheet
accessibleTables::write_sheet(
  wb,
  "Table_1b",
  paste0("Table 1b: Number and percentage of dentists with NHS activity by contract type and dentist type, ",config$table_sheet_title_fy),
  c(
    "1. Field definitions can be found on the 'Metadata' tab.",
    "2. Dentists are defined as performers with NHS activity recorded by FP17 forms. DCPs such as dental hygienists or dental therapists are excluded from this table.",
    "3. Data consists of performers in General Dental Services (GDS), Personal Dental Services (PDS) and Trust-led Dental Services (TDS).",
    "4. Associates were previously called 'Performer only' dentists.",
    "5. Foundation dentists have been included as associates."
  ),
  table_1b_wf,
  30
)

accessibleTables::format_data(wb,
                              "Table_1b",
                              c("A", "B", "C"),
                              "left",
                              "")

accessibleTables::format_data(wb,
                              "Table_1b",
                              c("D", "E"),
                              "right",
                              "#,##0")

accessibleTables::format_data(wb,
                              "Table_1b",
                              c("F"),
                              "right",
                              "#,##0.0")

# write data to sheet
accessibleTables::write_sheet(
  wb,
  "Table_1c",
  paste0("Table 1c: Number and percentage of dentists with NHS activity by gender and age group, ",config$table_sheet_title_fy),
  c(
    "1. Field definitions can be found on the 'Metadata' tab.",
    "2. Dentists are defined as performers with NHS activity recorded by FP17 forms. DCPs such as dental hygienists or dental therapists are excluded from this table.",
    "3. Data consists of performers in General Dental Services (GDS), Personal Dental Services (PDS) and Trust-led Dental Services (TDS)."
  ),
  table_1c_wf,
  30
)

accessibleTables::format_data(wb,
                              "Table_1c",
                              c("A", "B", "C"),
                              "left",
                              "")

accessibleTables::format_data(wb,
                              "Table_1c",
                              c("D", "E"),
                              "right",
                              "#,##0")

accessibleTables::format_data(wb,
                              "Table_1c",
                              c("F"),
                              "right",
                              "#,##0.0")

# write data to sheet
accessibleTables::write_sheet(
  wb,
  "Table_2a",
  paste0("Table 2a: Number of dentists with NHS activity by population, ",config$table_sheet_title_fy),
  c(
    "1. Field definitions can be found on the 'Metadata' tab.",
    "2. Table 2a uses the latest ONS national level mid-year population estimates for England, which were available to mid-year 2024 at time of publication. A link to these can be found on the metadata sheet.",
    "3. Mid-year population estimates for 2023 and 2024 were unavailable at time of publication for NHS Region, ICB or SICBL level. Therefore Region, ICB, or SICBL level population data in table 2b and table 2d will not add up to national level data for England in table 2a.",
    "4. Dentists are defined as performers with NHS activity recorded by FP17 forms. DCPs such as dental hygienists or dental therapists are excluded from this table.",
    "5. Data consists of performers in General Dental Services (GDS), Personal Dental Services (PDS) and Trust-led Dental Services (TDS)."
  ),
  table_2a_wf,
  30
)

accessibleTables::format_data(wb,
                              "Table_2a",
                              c("A", "B", "C", "E"),
                              "left",
                              "")

accessibleTables::format_data(wb,
                              "Table_2a",
                              c("D", "F", "G", "H"),
                              "right",
                              "#,##0")

# write data to sheet
accessibleTables::write_sheet(
  wb,
  "Table_2b",
  paste0("Table 2b: Number of dentists with NHS activity by NHS region and Integrated Care Board (ICB), ",config$table_sheet_title_fy),
  c(
    "1. Field definitions can be found on the 'Metadata' tab.",
    "2. Mid-year population estimates for 2023 and 2024 were unavailable at time of publication for NHS Region, ICB or SICBL level. Therefore Region, ICB, or SICBL level population data in table 2b and table 2d will not add up to national level data for England in table 2a.",
    "3. Dentists are defined as performers with NHS activity recorded by FP17 forms. DCPs such as dental hygienists or dental therapists are excluded from this table.",
    "4. Data consists of performers in General Dental Services (GDS), Personal Dental Services (PDS) and Trust-led Dental Services (TDS).",
    "5. Adding together sub-national totals will result in double counting of dentists with contracts in more than 1 region or ICB in the same year.",
    "6. Some data for 2019/2020 was recorded against an Area Team. For this data, the location of the latest commissioning organisation associated with the contract has been used instead of the Area Team.",
    "7. Mid-year population estimates have been taken from the latest ONS population estimates at time of publication. A link to these can be found in the metadata sheet."
  ),
  table_2b_wf,
  30
)

accessibleTables::format_data(wb,
                              "Table_2b",
                              c("A", "B", "C", "D", "F"),
                              "left",
                              "")

accessibleTables::format_data(wb,
                              "Table_2b",
                              c("E", "G", "H", "I"),
                              "right",
                              "#,##0")

# write data to sheet
accessibleTables::write_sheet(
  wb,
  "Table_2c",
  paste0("Table 2c: Number of dentists who left and those who joined the NHS by NHS region and Integrated Care Board (ICB) by financial year, ",config$table_sheet_title_fy),
  c(
    "1. Field definitions can be found on the 'Metadata' tab.",
    "2. Dentists are defined as performers with NHS activity recorded by FP17 forms. DCPs such as dental hygienists or dental therapists are excluded from this table.",
    "3. Data consists of performers in General Dental Services (GDS), Personal Dental Services (PDS) and Trust-led Dental Services (TDS).",
    "4. Adding together sub-national totals will result in double counting of dentists with contracts in more than 1 region or ICB in the same year.",
    "5. Joiners and leavers data is not available for 2019/2020 due to data retention periods of some raw data."
  ),
  table_2c_wf,
  30
)

accessibleTables::format_data(wb,
                              "Table_2c",
                              c("A", "B", "C", "D", "F"),
                              "left",
                              "")

accessibleTables::format_data(wb,
                              "Table_2c",
                              c("E", "G"),
                              "right",
                              "#,##0")

accessibleTables::format_data(wb,
                              "Table_2c",
                              c("H"),
                              "right",
                              "#,##0.0")

# write data to sheet
accessibleTables::write_sheet(
  wb,
  "Table_2d",
  paste0("Table 2d: Number of dentists with NHS activity by Sub Integrated Care Board Location (SICBL), ",config$table_sheet_title_fy),
  c(
    "1. Field definitions can be found on the 'Metadata' tab.",
    "2. Mid-year population estimates for 2023 and 2024 were unavailable at time of publication for NHS Region, ICB or SICBL level. Therefore Region, ICB, or SICBL level population data in table 2b and table 2d will not add up to national level data for England in table 2a.",
    "3. Dentists are defined as performers with NHS activity recorded by FP17 forms. DCPs such as dental hygienists or dental therapists are excluded from this table.",
    "4. Data consists of performers in General Dental Services (GDS), Personal Dental Services (PDS) and Trust-led Dental Services (TDS).",
    "5. Adding together sub-national totals will result in double counting of dentists with contracts in more than 1 SICBL in the same year.",
    "6. The SICBL of a dentist is based on the primary correspondence address. This may be different from the location of the commissioner of the dental contract. Some dentists with an address in Wales are excluded from this table, but included in national totals if they have performed activity under English contracts.",
    "7. Mid-year population estimates have been taken from the latest ONS population estimates at time of publication. A link to these can be found in the metadata sheet."
  ),
  table_2d_wf,
  30
)

accessibleTables::format_data(wb,
                              "Table_2d",
                              c("A", "B", "C", "D", "F"),
                              "left",
                              "")

accessibleTables::format_data(wb,
                              "Table_2d",
                              c("E", "G", "H", "I"),
                              "right",
                              "#,##0")

# write data to sheet
accessibleTables::write_sheet(
  wb,
  "Table_2e",
  paste0("Table 2e: Number of dentists who left and those who joined the NHS by Sub-Integrated Care Board Location (SICBL), ",config$table_sheet_title_fy),
  c(
    "1. Field definitions can be found on the 'Metadata' tab.",
    "2. Dentists are defined as performers with NHS activity recorded by FP17 forms. DCPs such as dental hygienists or dental therapists are excluded from this table.",
    "3. Data consists of performers in General Dental Services (GDS), Personal Dental Services (PDS) and Trust-led Dental Services (TDS).",
    "4. Adding together sub-national totals will result in double counting of dentists with contracts in more than 1 SICBL in the same year.",
    "5. Joiners and leavers data is not available for 2019/2020 due to data retention periods of some raw data."
  ),
  table_2e_wf,
  30
)

accessibleTables::format_data(wb,
                              "Table_2e",
                              c("A", "B", "C", "D", "F"),
                              "left",
                              "")

accessibleTables::format_data(wb,
                              "Table_2e",
                              c("E", "G"),
                              "right",
                              "#,##0")

accessibleTables::format_data(wb,
                              "Table_2e",
                              c("H"),
                              "right",
                              "#,##0.0")

# write data to sheet
accessibleTables::write_sheet(
  wb,
  "Table_3a",
  paste0("Table 3a: Number of Dental Care Professionals (DCPs) by contract type, England 2024/25"),
  c(
    "1. Field definitions can be found on the 'Metadata' tab.",
    "2. DCPs are only included in this table if they were the main performer associated with NHS activity on an FP17 form, with at least 1 UDA or UOA within 2024/25.",
    "3. Data consists of DCPs in General Dental Services (GDS), Personal Dental Services (PDS) and Trust-led Dental Services (TDS).",
    "4. Dental hygienists and dental therapists are the only DCP roles permitted to lead on dental activity within their General Dental Council (GDC) scope of practice.",
    "5. Joiners and leavers data is not available for DCPs. 2024/25 is the first year DCPs have been permitted to lead on dental activity."
  ),
  table_3a_wf,
  30
)

accessibleTables::format_data(wb,
                              "Table_3a",
                              c("A", "B", "C"),
                              "left",
                              "")

accessibleTables::format_data(wb,
                              "Table_3a",
                              c("D"),
                              "right",
                              "#,##0")

#create cover sheet
accessibleTables::makeCoverSheet(
  config$publication_name,
  config$cover_sheet_sub_title_workforce,
  config$publication_date,
  wb,
  sheetNames,
  c(
    "Metadata",
    "Table 1a: Number of dentists with NHS activity by financial year",
    "Table 1b: Number and percentage of dentists with NHS activity by contract type and dentist type by financial year",
    "Table 1c: Number and percentage of dentists with NHS activity by gender and age group by financial year",
    "Table 2a: Number of dentists with NHS activity by financial year and population",
    "Table 2b: Number of dentists with NHS activity by NHS region and Integrated Care Board (ICB) by financial year",
    "Table 2c: Number of dentists who left and those who joined the NHS by NHS region and Integrated Care Board (ICB) by financial year",
    "Table 2d: Number of dentists with NHS activity by Sub-Integrated Care Board Location (SICBL) by financial year",
    "Table 2e: Number of dentists who left and those who joined the NHS by Sub-Integrated Care Board Location (SICBL) by financial year",
    "Table 3a: Number of Dental Care Professionals by contract type"
  ),
  c("Metadata", sheetNames)
) 

#save file into outputs folder
openxlsx::saveWorkbook(wb,
                       "outputs/dental_workforce_202425_v001.xlsx",
                       overwrite = TRUE)
