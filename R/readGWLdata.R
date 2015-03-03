#' Read in groundwater data from file downloaded from GWL tool
#'
#' Read in groundwater data from file downloaded from GWL tool
#' @param path The path to the csv
#' @param emsID The EMS ID of the well
#' @export
#' @return A dataframe of the groundwater level observations
#' @examples \dontrun{
#'
#'}
readGWLdata <- function(path, emsID) {
  
  if (!inherits(path, "textConnection") && !file.exists(path)) {
    stop(paste0("The file ", path, "does not exist."))
  }
  
  welldf <- read.csv(path, skip=5, row.names=NULL, stringsAsFactors=FALSE
                     , na.strings=c("","N/A","NA","No Reading","NoReading"))
  
  # remove last row with html/java gibberish
  welldf <- welldf[-nrow(welldf),]
  
  names(welldf) <- c("Station_Name", "Date", "GWL", "Historical_Daily_Average"
                     , "Historical_Daily_Minimum", "Historical_Daily_Maximum"
                     , "Status")
  
  welldf <- welldf[!is.na(welldf$GWL),]
  
  welldf$Station_Name <- welldf$Station_Name[1]
  
  welldf$Date <- as.POSIXct(strptime(welldf$Date
                                     , format="%Y-%m-%d %H:%M", tz="GMT"))
  
  welldf$EMS_ID <- emsID
  
  welldf$Well_Num <- as.numeric(gsub("OBS\\w*\\s*WELL\\s*#*\\s*(\\d+)(\\s.+|$)", 
                                     "\\1", welldf$Station_Name))
  
  welldf[,c(8,9,1:7)]
}