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

#' Get full time series with missing values interpolated  
#'
#' Takes a dataframe with monthly values and creates a full time series, interpolating
#' missing values.
#' @import zoo dplyr
#' @importFrom lubridate year month
#' 
#' @param df A monthly dataframe created by `monthlyValues`. Must minimally include 
#'        fields `EMS_ID`, `Well_Num` `Date`, 'med_GWL`, `nReadings`
#' @export
#' @return A full monthly time series with interpolated missing values, 
#'         retaining all of the columns in the original data frame.
#' @examples \dontrun{
#'
#'}
makeWellTS <- function(df) {
  
  well <- df[1,"EMS_ID"]
  
  ## Turn monthlies into yearmon data type from package {zoo}
  df$yearmonth <- as.yearmon(df$Date)
  
  ## Create a full sequence of months for the timespan of the data
  well.seq <- data.frame(yearmonth=
                           as.yearmon(seq(from=as.Date(min(df$yearmonth))
                                          , to=as.Date(max(df$yearmonth))
                                          , by="month")))
  
  ## Join the monthly sequence to the well level data to fill missing values 
  ## with NAs so we can create a time series
  well.ts <- merge(well.seq, df, by="yearmonth", all=TRUE)
  
  # Interpolate missing values - see StackOverflow question here:
  # http://stackoverflow.com/questions/4964255/interpolate-
  # missing-values-in-a-time-series-with-a-seasonal-cycle
  # Answer by Rob Hyndman
  x <- ts(well.ts$med_GWL,frequency=12)
  
  #Check for convergence fitting the time series model
  struct <- suppressWarnings(StructTS(x))
  if (struct$code != 0) {
    print(paste0("Convergence code for well ", well, " returned ", struct$code
                 , ": ", struct$message))
  }
  
  well.ts$fit <- as.vector(ts(rowSums(tsSmooth(struct)[,-2])))
  # Fill in missing values
  
  well.ts <- mutate(well.ts, 
                  Date=as.Date(yearmonth),
                  Year=year(yearmonth),
                  Month=month(yearmonth),
                  med_GWL = ifelse(is.na(med_GWL), fit, med_GWL),
                  nReadings = ifelse(is.na(nReadings), 0, nReadings))
  
  for (col in c("EMS_ID", "Well_Num")) {
    well.ts[,col] <- na.locf(well.ts[,col])
  }
  
  
  
  return(well.ts)
}