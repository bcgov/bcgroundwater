#' Read in groundwater data from file downloaded from GWL tool
#'
#' Read in groundwater data from file downloaded from GWL tool
#' @param emsID The EMS ID of the well
#' @param  wellNum The Well Number of the well
#' @param  dir The directory the file is stored in
#' @export
#' @return A dataframe of the groundwater level observations
#' @examples \dontrun{
#'
#'}
readGWLdata <- function(emsID, wellNum, dir) {
  
  file.loc <- paste0(dir, "well", emsID, ".csv")
  
  if (!file.exists(file.loc)) {
    stop(paste0("The file ", file.loc, "does not exist."))
  }
  
  welldf <- read.csv(file.loc, skip=5, row.names=NULL, stringsAsFactors=FALSE
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
  
  welldf$Well_Num <- as.character(wellNum)
  
  welldf$Well_Num <- gsub("\\s+", "", welldf$Well_Num)
  
  welldf[,c(8,9,1:7)]
}