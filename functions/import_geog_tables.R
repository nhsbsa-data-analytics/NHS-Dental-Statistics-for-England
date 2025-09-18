import_geog_tables <- function(filepath, con) {
  
  files_list <- list.files(filepath, full.names = T)
  
  files_list_filt <- files_list[grepl("GEOG_TABLE", files_list)]
  
  data <- list()
  
  for (i in files_list_filt) {
    
    statement <- gsub(";", "", readr::read_file(i))
    
    obj_name <- stringr::str_extract(i, "GEOG_TABLE_\\d\\w")

    data[[obj_name]] <- DBI::dbGetQuery(conn = con, statement = statement)
    
    message(paste("Ran ", i))
  }
  
  data
  
}
