# Copyright 2015 Jay R Brown
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
#'
#' Read in groundwater data from files downloaded from GWL tool
#' @author Jay R Brown, \email{jay@@systemicresult.com}
#' @importFrom reshape2 dcast
#' @param historical The path to the csv with historical data
#' @param datafile The path to the csv with current data
#' @param stnName The station name to use as it is no longer in data
#' @param emsID The EMS ID of the well retained for compatibility
#' @export
#' @return A dataframe of the groundwater level observations
#' @examples \dontrun{
#'
#'}
readGWLdata2 <- function(historical, datafile, stnName="Not Available", emsID="NA") {
  
  if (!inherits(historical, "textConnection") && !file.exists(historical)) {
    stop(paste0("The historical file ", historical, " does not exist."))
  }

  if (!inherits(datafile, "textConnection") && !file.exists(datafile)) {
    stop(paste0("The data file ", datafile, " does not exist."))
  }
  
  # get the well ID from the filenames and try to check they match
  histfilename <- strsplit(historical, "[.]")[[1]][-2]
  histwellid <- substr(histfilename, 3, 5)
  
  filename <- strsplit(datafile, "[.]")[[1]][-2]
  wellid <- substr(filename, 3, 5)
  
  # Just warn, don't stop, in case user changed the file names
  if (!identical(histwellid, wellid)) {
    warning("The Well ID in file names do not match. Are the files both for the same well?")
  }
  
  # load hisorical data
  historicaldf <- read.csv(historical, row.names=NULL, stringsAsFactors=TRUE)
  
  # check column count, historical file should be 6: 
  # dummydate, Value, type, year, month, daynum
  if (length(names(historicaldf)) != 6) {
    stop(paste0("Invalid number of fields in historical file. Expecting 6 and see ", length(names(historicaldf))))
  }
  
  # put measures into columns using reshape2 library
  historicaldf <- dcast(historicaldf, dummydate ~ type, value.var="Value")
  
  # why is the max < min?
  # arrange and create a key from the date '01-01' for merging
  historicaldf <- historicaldf %>%
    arrange(dummydate) %>%
    mutate(key = substr(dummydate, 6, 10)) %>%
    select(key, mean, min, max)
  
  names(historicaldf) <- c("key", "Historical_Daily_Average", 
                           "Historical_Daily_Minimum", "Historical_Daily_Maximum")
  
  # historicaldf is now ready to be a reference with the key as index
  
  # work with the observations with fields Time, Value, Approval
  # May be recent data for last 2 years, or full dataset
  currentdf <- read.csv(datafile, row.names=NULL, stringsAsFactors=FALSE)
  
  # check column count, data file should be 3: 
  # Time, Value, Approval
  if (length(names(currentdf)) != 3) {
    stop(paste0("Invalid number of fields in data file. Expecting 3 and see ", length(names(currentdf))))
  }

  # create Date column in expected format
  currentdf <- currentdf %>%
    mutate(Date = as.POSIXct(strptime(Time, format="%Y-%m-%d")))
  
  # add a key '01-01' for merge with historical data
  currentdf <- currentdf %>%
    mutate(key = substr(as.character(Date), 6, 10)) %>%
    select(key, Date, Value, Approval) 
  
  # Observations in the 'recent' or 'data' files have hourly observations each day.
  # Based on viewing the bcgoundwater vingette, the expected data frame has one 
  # observation per day at 12.
  # Going with calculating a mean value per day and call it GWL
  daydf <- currentdf %>%
    group_by(Date) %>%
    summarise(GWL = mean(Value))

  # Join up with currentdf taking distinct value of Date and drop original value
  # Main reason for this step is to include the Approval variable which gets lost 
  # in the summarise step above.
  dailydf <- left_join(daydf, currentdf) %>%
    distinct(Date) %>%
    select(-Value)
  
  names(dailydf) <- c("Date", "GWL", "key", "Status")  

  # now left join historical data on the key  
  welldf <- left_join(dailydf, historicaldf)
  
  # sort rows and set up as expected
  welldf <- welldf %>%
    mutate(Well_Num=wellid, EMS_ID=emsID, Station_Name=stnName) %>%
    arrange(Date) %>%
    select(Well_Num, EMS_ID, Station_Name, Date, GWL, Historical_Daily_Average, Historical_Daily_Minimum, 
           Historical_Daily_Maximum, Status)
  
  # remove NAs
  welldf <- welldf[!is.na(welldf$GWL),]

  welldf
}