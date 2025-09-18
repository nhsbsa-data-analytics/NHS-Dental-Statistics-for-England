#Ward lookups function
#download files from ONS website and get names and codes of Wards December 2023

#example:  ward_lookup <- get_ward_lookup()

get_ward_lookup <- function(ward_23_link = "https://hub.arcgis.com/api/v3/datasets/8e206a9475a9426491b68f096568cb8b_0/downloads/data?format=csv&spatialRefId=4326&where=1%3D1"){
  
  #use read_csv() directly on download url
  
  #download and read Ward names and codes table
  lookup <- readr::read_csv(ward_23_link)
  
  return(lookup)
  
}