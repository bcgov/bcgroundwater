#' Obtain a single groundwater level for each month
#'
#' Assigns each reading to a month; sometimes there are several readings in a
#' month that may be better assigned to a different month if they are at the 
#' border.  Does not estimate values for months where there were 0 observations.
#' @import dplyr
#' @importFrom lubridate year
#' @importFrom lubridate month
#' @importFrom lubridate round_date
#' @importFrom lubridate floor_date
#' @param df data frame with columns EMS_ID, Well_Num, Date, GWL
#' @export
#' @return a data frame with one value per month. Does not estimate values 
#'         for months where there were 0 observations.
#' @examples \dontrun{
#'
#'}
monthlyValues <- function(df) {
  
  if (!is.data.frame(df)) {
    stop("df must be a dataframe")
  } else {
    well <- df
  }
   
    monthlywell <- well %.%
      group_by(EMS_ID, Well_Num, Year=year(Date)
               , Month = month(Date)) %.%
      mutate(length_x = n()
             , Date = if (n() < 5) {
               round_date(Date, "month")
             } else {
               floor_date(Date, "month")
             }
      ) %.%
      group_by(Date) %.%
      summarize(med_GWL = median(GWL)
                , nReadings = length(GWL)) %.%
      ungroup() %.% group_by(EMS_ID, Well_Num, Year) %.%
      mutate(dev_med_GWL = med_GWL-mean(med_GWL)) %.%
      ungroup()

#   TODO: May want to make these values flipped in sign, then would have to 
#   remove the scale_y_reverse in gwlMonthlyPlot 
     
    return(monthlywell)
}