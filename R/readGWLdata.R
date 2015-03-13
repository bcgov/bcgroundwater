# Copyright 2015 Province of British Columbia
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
# http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.

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
readGWLdata <- function(path, emsID = NULL) {
  
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
  
  ## Extract Well number and if deep or shallow from station name:
  st_name <- welldf$Station_Name[1]
  wl_num <- gsub("OBS\\w*\\s*WELL\\s*#*\\s*(\\d+)(\\s.+|$)", "\\1", st_name)
  if (grepl("shallow", st_name, ignore.case = TRUE)) wl_num <- paste(wl_num, "shallow")
  if (grepl("deep", st_name, ignore.case = TRUE)) wl_num <- paste(wl_num, "deep")

  ## Set station name and well number
  welldf$Station_Name <- st_name
  welldf$Well_Num <- wl_num
  
  
  welldf$Date <- as.POSIXct(strptime(welldf$Date
                                     , format="%Y-%m-%d %H:%M", tz="GMT"))
  
  welldf$EMS_ID <- emsID
  
  
  welldf[,c(8,9,1:7)]
}