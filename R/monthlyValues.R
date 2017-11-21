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

#' Obtain a single groundwater level for each month
#'
#' Assigns each reading to a month; sometimes there are several readings in a
#' month that may be better assigned to a different month if they are at the 
#' border.  Does not estimate values for months where there were 0 observations.
#' 
#' @param df data frame with columns EMS_ID, Well_Num, Date, GWL
#' 
#' @return a data frame with one value per month. Does not estimate values 
#'         for months where there were 0 observations.
#' @examples \dontrun{
#'
#'}
#' @export
monthlyValues <- function(df) {
  
  if (!is.data.frame(df)) stop("df must be a dataframe")

  monthlywell <- df %>%
    dplyr::group_by(EMS_ID, Well_Num, 
                    Year = lubridate::year(Date),
                    Month = lubridate::month(Date)) %>%
    dplyr::mutate(Date = dplyr::case_when(length(Well_Num) < 5 ~ lubridate::round_date(Date, "month"),
                                          length(Well_Num) >= 5 ~ lubridate::floor_date(Date, "month"))) %>%
    dplyr::ungroup() %>% 
    dplyr::group_by(EMS_ID, Well_Num, Date) %>% 
    dplyr::summarize(med_GWL = stats::median(GWL), 
                     nReadings = length(Well_Num)) %>% 
    dplyr::mutate(Year = lubridate::year(Date), 
                  Month = lubridate::month(Date)) %>%
    dplyr::ungroup() %>% 
    dplyr::group_by(EMS_ID, Well_Num, Year) %>%
    dplyr::mutate(dev_med_GWL = med_GWL - mean(med_GWL)) %>%
    dplyr::ungroup()

#   TODO: May want to make these values flipped in sign, then would have to 
#   remove the scale_y_reverse in gwlMonthlyPlot 
     
    return(monthlywell)
}