gwlZypTest <- function(dataframe, wells=NULL, col, method="both") {
  # Uses the zyp package to calculate Mann-Kendall trend test on pre-whitened
  # data (to remove autocorrelation) for many wells, using one or both of two 
  # Pre-whitening methods, see zyp documentation
  # Returns: a dataframe of results for all wells evaluated
  #
  # Arguments: 
  # dataframe: dataframe containing minimally: EMS_ID, med_GWL
  # wells: vector of well numbers to test. Default NULL does all in dataframe
  # col: the name of the column with the GWL values
  # method: "both" (default), "yuepilon", or "zhang"
  
  require(zyp)
  
  if (is.null(wells)) {
    wells <- unique(dataframe$EMS_ID)
  } else {
    wells <- wells
  }
  
  # create an empty dataframe to store results
  mk.results <- data.frame(EMS_ID=character(), test_type=character()
                           , lbound=numeric(), trend=numeric(), trendp=numeric()
                           , ubound=numeric(), tau=numeric(), sig=numeric()
                           , nruns=numeric(), autocor=numeric()
                           , valid_frac=numeric(), linear=numeric()
                           , intercept=numeric(), stringsAsFactors=FALSE)
  
  for (well in wells) {
    d <- dataframe[dataframe$EMS_ID==well,col]
    if (method == "both" | method == "yuepilon") {
      zyp.yuepilon <- zyp.trend.vector(d, method="yuepilon", conf.intervals=TRUE)
      
      mk.results[nrow(mk.results)+1,1:2] <- c(well, "yuepilon")
      mk.results[nrow(mk.results),3:13] <- zyp.yuepilon
    }
    if (method == "both" | method == "zhang") {
      zyp.zhang <- zyp.trend.vector(d, method="zhang", conf.intervals=TRUE)
      
      mk.results[nrow(mk.results)+1,1:2] <- c(well, "zhang")
      mk.results[nrow(mk.results),3:13] <- zyp.zhang
    }
  }
  mk.results
}