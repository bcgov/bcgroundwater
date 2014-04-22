monthlyValues <- function(df, rawOut=FALSE, monthlyOut=TRUE) {
  ##############################################################################
  ## rawOut (logical): Output the raw data downloaded from GWL
  ## monthlyOut (logical): Output the monthly summary - needed for timeseries
  ##                       creation (wellTS function)
  ##############################################################################
  
  require(dplyr)
  require(lubridate)
  
  if (!is.data.frame(df)) {
    stop("df must be a dataframe")
  } else {
    well <- df
  }
  
  if (rawOut==TRUE) {
    assign(paste0("well", wellNum, ".df"), well, envir=.GlobalEnv)
  }
  
  if (monthlyOut==TRUE) {
    ## Assign each reading to a month, sometimes there are several readings in a
    ## month that may be better assigned to a different month if they are at the 
    ## border. 
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
      
    
#     well2 <- ddply(well, .(Year = year(Date)
#                           , Month = month(Date)), mutate
#                   , length_x = length(EMS_ID)
#                   , Date=as.Date(ifelse(length_x<5
#                                            , round_date(Date, "month")
#                                            , floor_date(Date, "month"))
#                                  , origin="1970-01-01"))
#     
#     # Calculate monthly median water levels
#     monthlywell2 <- ddply(well2, .(EMS_ID, Well_Num, Date
#                                  , Year = year(Date)
#                                  , Month = month(Date)), summarize
#                          , med_GWL = median(GWL)
#                          , nReadings = length(GWL))
#     
#     # Calculate the monthly deviation from yearly averages
#     #   TODO: May want to make these values flipped in sign, then would have to 
#     #   remove the scale_y_reverse in gwlMonthlyPlot 
#     monthlywell2 <- ddply(monthlywell, .(Year), mutate
#                          , dev_med_GWL = med_GWL-mean(med_GWL))
#     
    return(monthlywell)
  }
}