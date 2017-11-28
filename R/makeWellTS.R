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
#' 
#' @param df A monthly dataframe created by `monthlyValues`. Must minimally
#'   include fields `EMS_ID`, `Well_Num` `Date`, 'med_GWL`, `nReadings`
#'   
#' @return A full monthly time series with interpolated missing values, 
#'         retaining all of the columns in the original data frame.
#' @examples \dontrun{
#'
#'}
#'
#' @export
makeWellTS <- function(df) {
  
  well <- df[1, "EMS_ID"]
  
  ## Turn monthlies into yearmon data type from package {zoo}
  df$yearmonth <- zoo::as.yearmon(df$Date)
  
  ## Create a full sequence of months for the timespan of the data
  well.seq <- data.frame(yearmonth =
                           zoo::as.yearmon(seq(from = zoo::as.Date(min(df$yearmonth)),
                                               to = zoo::as.Date(max(df$yearmonth)),
                                               by = "month")))
  
  ## Join the monthly sequence to the well level data to fill missing values 
  ## with NAs so we can create a time series
  well.ts <- merge(well.seq, df, by = "yearmonth", all = TRUE)
  
  # Interpolate missing values - see StackOverflow question here:
  # http://stackoverflow.com/questions/4964255/interpolate-
  # missing-values-in-a-time-series-with-a-seasonal-cycle
  # Answer by Rob Hyndman
  x <- stats::ts(well.ts$med_GWL, frequency = 12)
  
  #Check for convergence fitting the time series model
  struct <- suppressWarnings(stats::StructTS(x))
  if (struct$code != 0) {
    print(paste0("Convergence code for well ", well, " returned ", struct$code,
                 ": ", struct$message))
  }
  
  well.ts$fit <- as.vector(stats::ts(rowSums(stats::tsSmooth(struct)[, -2])))
  # Fill in missing values
  
  well.ts <- dplyr::mutate(well.ts, 
                           Date = zoo::as.Date(.data$yearmonth),
                           Year = lubridate::year(.data$yearmonth),
                           Month = lubridate::month(.data$yearmonth),
                           med_GWL = replace(.data$med_GWL, 
                                             is.na(.data$med_GWL), 
                                             .data$fit[is.na(.data$med_GWL)]),
                           nReadings = replace(.data$nReadings, is.na(.data$nReadings), 0))
  
  for (col in c("EMS_ID", "Well_Num")) {
    well.ts[, col] <- zoo::na.locf(well.ts[, col])
  }
  
  return(well.ts)
}