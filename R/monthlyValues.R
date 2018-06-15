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

#'Obtain a single groundwater level for each month
#'
#'Assigns each reading to a month; sometimes there are several readings in a 
#'month that may be better assigned to a different month if they are at the 
#'border.  Does not estimate values for months where there were 0 observations.
#'
#'@param df Data frame with columns EMS_ID, Well_Num, Date, GWL
#'  
#'@return A data frame with one value per month. Does not estimate values for
#'  months where there were 0 observations.
#' @export
monthly_values <- function(df) {
  
  if (!is.data.frame(df)) stop("df must be a dataframe")

  monthlywell <- df %>%
    dplyr::group_by(.data$EMS_ID, .data$Well_Num, 
                    Year = lubridate::year(.data$Date),
                    Month = lubridate::month(.data$Date)) %>%
    dplyr::mutate(Date = dplyr::case_when(length(.data$Well_Num) < 5 ~ 
                                            lubridate::round_date(.data$Date, "month"),
                                          length(.data$Well_Num) >= 5 ~ 
                                            lubridate::floor_date(.data$Date, "month"))) %>%
    dplyr::ungroup() %>% 
    dplyr::group_by(.data$EMS_ID, .data$Well_Num, .data$Date) %>% 
    dplyr::summarize(med_GWL = stats::median(.data$GWL), 
                     nReadings = length(.data$Well_Num)) %>% 
    dplyr::mutate(Year = lubridate::year(.data$Date), 
                  Month = lubridate::month(.data$Date)) %>%
    dplyr::ungroup() %>% 
    dplyr::group_by(.data$EMS_ID, .data$Well_Num, .data$Year) %>%
    dplyr::mutate(dev_med_GWL = .data$med_GWL - mean(.data$med_GWL)) %>%
    dplyr::ungroup()

#   TODO: May want to make these values flipped in sign, then would have to 
#   remove the scale_y_reverse in gwlMonthlyPlot 
     
    return(monthlywell)
}