#function to download lookup tables and output a lookup table with 2022 and 2023 LA codes and their 2023 names.
#Missingness is imputed manually for any missing values in the 2023 codes by matching 2022 LAs with their new
#2023 local authority and the corresponding code replacing the NA.

#example code
#la_lookup<- get_la_lookup()

get_la_lookup<- function(LA_22_link= "https://hub.arcgis.com/api/v3/datasets/42af123c4663466496dafb4c8fcb0c82_0/downloads/data?format=csv&spatialRefId=4326&where=1%3D1",
                         LA_23_link= "https://hub.arcgis.com/api/v3/datasets/e8b361ba9e98418ba8ff2f892d00c352_0/downloads/data?format=csv&spatialRefId=4326&where=1%3D1"){
  
  #download data and read tables
  LA_22<- tryCatch(
    {
      readr::read_csv(LA_22_link)
    },
    error=function(e){
      message(paste0("Error reading:", LA_22_link, ": ", conditionMessage(e)))
      return(NULL)
    }
  )
  
  LA_23<- tryCatch(
    {
      readr::read_csv(LA_23_link)
    },
    error=function(e){
      message(paste0("Error reading", LA_23_link, ": ", conditionMessage(e)))
      return(NULL)
    }
  )
  
  if (is.null(LA_22) || is.null(LA_23)) {
    stop("One or both datasets failed to load.")
  }
  
  # Check if the necessary columns exist
  if (!all(c("LAD22CD", "LAD22NM") %in% colnames(LA_22))) {
    stop("The specified columns do not exist in the data.")
  }
  
  # Check if the necessary columns exist
  if (!all(c("LAD23CD", "LAD23NM") %in% colnames(LA_23))) {
    stop("The specified columns do not exist in the data.")
  }
  
  #filter for England LAs and select and rename required columns
  
  LA_22_filtered<- LA_22 |>
    dplyr::filter(grepl("^E", LAD22CD))|>
    dplyr::select(2,1)
  
  LA_23_filtered<- LA_23 |>
    dplyr::filter(grepl("^E", LAD23CD))|>
    dplyr::select(2,1)
  
  lookup<- dplyr::full_join(LA_23_filtered,
                            LA_22_filtered,
                            by= c("LAD23NM"="LAD22NM")) |>
    dplyr::select(1,3,2) |>
    dplyr::arrange(LAD22CD,LAD23CD)
  
  #code commented out for use in geo tables, which need a 1-1 match
  
  # complete_codes<- lookup |>
  #   dplyr::filter(complete.cases(lookup))
  # 
  # #filter out rows with missing codes
  # missing_codes<- lookup |>
  #   dplyr::filter(if_any(everything(), is.na))
  # 
  # #fill missing 2023 codes with corresponding code for local authority with NA in 2022
  # 
  # matched_codes <- missing_codes |>
  #   dplyr::mutate(LAD23CD = case_when(
  #     is.na(LAD23CD) & stringr::str_detect(LAD22CD, "2[689]$") ~ "E06000063",  #Code for Cumberland
  #     is.na(LAD23CD) & stringr::str_detect(LAD22CD, "(27|3[01])$") ~ "E06000064", #Code for Westmorland and Furness
  #     is.na(LAD23CD) & stringr::str_detect(LAD22CD, "16\\d$") ~ "E06000065",   #Code for North Yorkshire
  #     is.na(LAD23CD) & stringr::str_detect(LAD22CD, "(18\\d|2\\d{2})$") ~ "E06000066",  #Code for Somerset
  #     TRUE ~ LAD23CD
  #   ))
  # 
  # #Join complete data with the matched data 
  # full_code_lookup<- rbind(complete_codes,matched_codes) |>
  #   dplyr::arrange(LAD22CD,LAD23CD)
  
  #return(full_code_lookup)
  
  return(lookup)
}