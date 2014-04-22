makeWellTS <- function(df) {
  ##############################################################################
  ## Get full time series with missing values interpolated  
  ## df: a monthly dataframe created by getWellData() with monthlyOut=TRUE, or 
  ##     an annual df by summarizing monthly by year
  ##############################################################################
  
  require(zoo)
  require(lubridate)
  require(dplyr)
  
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
  x <- ts(well.ts$med_GWL,f=12)
  
  #Check for convergence fitting the time series model
  struct <- suppressWarnings(StructTS(x))
  if (struct$code != 0) {
    print(paste0("Convergence code for well ", well, " returned ", struct$code
                 , ": ", struct$message))
  }
  
  
  well.ts$fit <- as.vector(ts(rowSums(tsSmooth(struct)[,-2])))
  # Fill in missing values
  
  well.ts[is.na(well.ts$EMS_ID),] <- well.ts[is.na(well.ts$EMS_ID),] %.%
    mutate(EMS_ID=well,
           Well_Num=df[1,"Well_Num"],
           Date=as.POSIXct(yearmonth),
           Year=year(yearmonth),
           Month=month(yearmonth),
           med_GWL=fit,
           nReadings=0)
  
  return(well.ts)
}