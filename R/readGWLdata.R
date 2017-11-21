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




#' Retrive and format groundwater data from BC Government GWL site
#'
#' Go to <http://www.env.gov.bc.ca/wsd/data_searches/obswell/map/> to find your
#' well of interest.
#' 
#' Daily averages (\code{daily}) are calculated based on all Validated data.
#' 
#' @param well Character. The well number, accepts either \code{OW000} or
#'   \code{000} format
#' @param which Character. Which data to retrieve \code{all} hourly data,
#'   \code{recent} hourly data, or all \code{daily} averages.
#' @param url Character. Override the url location of the data.
#' @param quiet Logical. Suppress progress messages?
#' 
#' @return A dataframe of the groundwater level observations
#' 
#' @examples \dontrun{
#' 
#' all_309 <- get_gwl_data(well = 309)
#' recent_309 <- get_gwl_data(well = "OW309", which = "recent")
#'}
#'
#' @export
get_gwl <- function(well, which = "all", url = NULL, quiet = FALSE) {
  
  if(!(which %in% c("all", "recent", "daily"))) stop("type must be either 'all', 'recent', or 'daily'.")
  if(which == "all") which <- "data"
  if(which == "daily") which <- "average"
  
  if(is.null(url)) url <- "http://www.env.gov.bc.ca/wsd/data_searches/obswell/map/data/"
  
  if(!grepl("OW", well)) well <- paste0("OW", well)
  
  url <- paste0(url, well, "-")
  gwl <- download_gwl(url, which, quiet = quiet)
  gwl <- format_gwl(gwl, quiet = quiet)
  
  return(gwl)
}

#' Download groundwater data from url
#' 
#' @noRd
download_gwl <- function(url, which, quiet) {
  
  if(!quiet) message("Retrieving data...")
  gwl_data <- httr::GET(paste0(url, which, ".csv"))
  httr::stop_for_status(gwl_data)
  gwl_data <- httr::content(gwl_data, as = "text", encoding = "UTF-8")
  
  gwl_avg <- httr::GET(paste0(url, "minMaxMean.csv"))
  httr::stop_for_status(gwl_avg)
  gwl_avg <- httr::content(gwl_avg, as = "text", encoding = "UTF-8")
  
  return(list(gwl_data, gwl_avg))
}

format_gwl <- function(data, quiet) {
  
  if(!quiet) message("Formatting data...")
  
  welldf <- read.csv(text = data[[1]], stringsAsFactors = FALSE)
  
  # For average data
  if("QualifiedTime" %in% names(welldf)) {
    welldf <- dplyr::rename(welldf, "Time" = "QualifiedTime")
    welldf$Approval <- "Validated"
  }

  # Merge with mean/min/max  
  welldf$Time <- as.POSIXct(welldf$Time, tz="UTC")
  welldf$dummydate <- paste0("1800-", format(welldf$Time, "%m-%d"))
  
  well_avg <- read.csv(text = data[[2]], stringsAsFactors = FALSE)
  well_avg <- well_avg[, names(well_avg)[names(well_avg) != "year"]]
  well_avg <- tidyr::spread(well_avg, "type", "Value")
  
  welldf <- dplyr::left_join(welldf, 
                             well_avg[, c("dummydate", "max", "mean", "min")],
                             by = "dummydate")
  
  ################################
  # Need station name/location meta information!
  ################################
  
  ## Extract Well number and if deep or shallow from station name:
  
  # st_name <- welldf$Station_Name[1]
  # wl_num <- gsub("OBS\\w*\\s*WELL\\s*#*\\s*(\\d+)(\\s.+|$)", "\\1", st_name)
  # if (grepl("shallow", st_name, ignore.case = TRUE)) wl_num <- paste(wl_num, "shallow")
  # if (grepl("deep", st_name, ignore.case = TRUE)) wl_num <- paste(wl_num, "deep")

  # welldf$EMS_ID <- emsID
  
  welldf$EMS_ID <- NA
  welldf$Station_Name <- NA
  
  # Select and rename final variables
  welldf <- dplyr::select(welldf,
                          "Well_Num" = "myLocation",
                          "EMS_ID", "Station_Name",
                          "Date" = "Time", "GWL" = "Value", 
                          "Historical_Daily_Average" = "mean", 
                          "Historical_Daily_Minimum" = "min",
                          "Historical_Daily_Maximum" = "max",
                          "Status" = "Approval")
  
  return(welldf)
}

#' (DEFUNCT) Read in groundwater data from file downloaded from GWL tool
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
  stop("'readGWLdata' is now defunct and has been replaced by 'get_gwl'")
}