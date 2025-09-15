#function to download and read ONS lookup tables for NHS health geographies
#example  health_lookups <- get_lsoa_icb_lookups()

#added 2024 region and icb lookup

get_lsoa_icb_lookups <- function(lsoa11_link = "https://hub.arcgis.com/api/v3/datasets/423c8069710c4d488d5ff99475688101_0/downloads/data?format=csv&spatialRefId=4326&where=1%3D1",
                                 lsoa21_link = "https://hub.arcgis.com/api/v3/datasets/8905a9ad35284b78945c3f3eb30498a2_0/downloads/data?format=csv&spatialRefId=4326&where=1%3D1",
                                 region22_link = "https://hub.arcgis.com/api/v3/datasets/2bca16d4f8e4426d80137213fce90bbd_0/downloads/data?format=csv&spatialRefId=4326&where=1%3D1",
                                 region23_link = "https://hub.arcgis.com/api/v3/datasets/be0adca7cbc94b82b058ab2d5925f42c_0/downloads/data?format=csv&spatialRefId=4326&where=1%3D1",
                                 region24_link = "https://hub.arcgis.com/api/v3/datasets/cdd2e45c39e14e9eb8280789560f83a9_0/downloads/data?format=csv&spatialRefId=4326&where=1%3D1"){
  
  #use read_csv() directly on download url
  
  #download and read ons lookup table lsoa 2011 to icb 2022
  lsoa11_to_icb22 <- readr::read_csv(lsoa11_link)

  #download and read ons lookup table for lsoa 2021 to icb 2023
  lsoa21_to_icb23 <- readr::read_csv(lsoa21_link)
  
  #download and read sub-icb to nhs region lookup table
  region_22 <- readr::read_csv(region22_link)
  
  #download and read sub-icb to nhs region lookup table
  region_23 <- readr::read_csv(region23_link)
  
  #download and read sub-icb to nhs region lookup table
  region_24 <- readr::read_csv(region24_link)
  
  lookups <- list()
  lookups$lsoa11_icb22 <- lsoa11_to_icb22
  lookups$lsoa21_icb23 <- lsoa21_to_icb23
  lookups$region_22 <- region_22
  lookups$region_23 <- region_23
  lookups$region_24 <- region_24
  
  return(lookups)
  
}