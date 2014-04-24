#' Download B.C. Groundwater level data
#'
#' Download time series of groundwater level measurements from a B.C. groundwater
#' observation well.
#' 
#' @param emsID The EMS ID of the well
#' @param  fromDate desired start date of time series, as a date object or character 
#'         string in the form "YYYY-MM-DD"
#' @param  toDate desired end date of time series, as a date object or character 
#'         string in the form "YYYY-MM-DD". Default today's date
#' @param  hist_avg Do you want the historical averages? (logical)
#' @param  save Do you want to save the time series as a csv (logical)
#' @param  data.dir The directory you want to save in
#' @export
#' @return if save, nothing is returned (but the file is saved in the directory specified). 
#'         If save=FALSE, the well data is returned.
#' @examples \dontrun{
#'
#'}
getGWLdata <- function(emsID, fromDate=NULL, toDate=NULL, hist_avg=TRUE, save=TRUE, data.dir) {
  
  if (is.null(toDate)) {
    toDate <- today()
    warning("No toDate supplied, using today's date")
  }
  
  if (missing(emsID)|missing(fromDate)) {
    stop("You must supply each of emsID, fromDate, and toDate")
  } else {
    fYear <- year(fromDate)
    fMonth <- month(fromDate)
    fDay <- mday(fromDate)
    tYear <- year(toDate)
    tMonth <- month(toDate)
    tDay <- mday(toDate)
    hist_avg <- as.character(hist_avg)
  }
  
  wellChar <- postForm(uri="http://a100.gov.bc.ca/pub/gwl/plot.do"
                      , fromYear=fYear
                      , fromMonth=fMonth
                      , fromDay=fDay
                      , toYear=tYear
                      , toMonth=tMonth
                      , toDay=tDay
                      , submitType="CSV"
                      , mode="GRAPH"
                      , emsIds=as.character(emsID)
                      , mmaFlags=hist_avg # historical daily averages
                      , style="post"
                      , binary=FALSE)
  
  if (nchar(wellChar)<250) {
    print(paste0("There was an error downloading the data for well with emsID "
                 , emsID))
    stop(print(wellChar))
    
  } else {
    
    wellChar <- gsub("(OBS[^\n]+),([^\n]+,\\d{4}-\\d{2}-\\d{2})", "\\1\\2"
                     , wellChar)
    
    if (save) {
      
      dir.create(data.dir, showWarnings=FALSE)
      
      fileloc <- paste0(data.dir,"/well",emsID,".csv")
      
      cat(wellChar, file=fileloc)
      
      print(paste0("Well with EMS ID ", emsID, " was saved to ", fileloc))
      
    } else {
      
      return(wellChar)
      
    }
  }
}