#NHS Region lookups function
#download files from ONS website and get names and codes of NHS regions over time
#NHS region names and codes for 2021, 2022, and 2024.
#requires copy of 2022 codes file saved in working directory due to issue with ONS website

#example:  region_lookup <- get_region_lookups()

get_region_lookups <- function(region21_link = "https://hub.arcgis.com/api/v3/datasets/56b4b6f7685c42dbac7bd544d5fcba0e_0/downloads/data?format=csv&spatialRefId=3857&where=1%3D1",
                                region22_link = "https://www.arcgis.com/sharing/rest/content/items/46b634b42ceb45cbbfbe9c960fb77ec9/data",
                                region24_link = "https://hub.arcgis.com/api/v3/datasets/2d1f5f98890f4e4aae598b26a4ad3350_0/downloads/data?format=csv&spatialRefId=4326&where=1%3D1"){
  
  #use read_csv() directly on download url
  
  #download and read nhs region names and codes table
  region_21 <- readr::read_csv(region21_link)
  
  #download and read nhs region names and codes table
  #issue with ONS website download setup for this file, so use local copy instead
  region_22 <- readr::read_csv("nhser_names_codes_22.csv")
  
  #download and read nhs region names and codes table
  region_24 <- readr::read_csv(region24_link)
  
  #join codes for each year onto region name
  region_lookup <- region_21 |>
    dplyr::left_join(region_22, by = join_by("NHSER21NM" == "NHSER22NM")) |>
    dplyr::left_join(region_24, by = join_by("NHSER21NM" == "NHSER24NM")) |>
    dplyr::select(-c("FID",
                     "ObjectId"))
  
  return(region_lookup)
  
}