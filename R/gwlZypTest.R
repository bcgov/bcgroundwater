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

#' Perform Mann-Kendall trend test on many wells
#'
#' Uses the zyp package to calculate Mann-Kendall trend test on pre-whitened
#' data (to remove autocorrelation) for many wells, using one or both of two 
#' Pre-whitening methods, see zyp documentation
#' @import zyp
#' @param dataframe dataframe containing minimally: EMS_ID, med_GWL
#' @param  wells vector of well numbers to test. Default NULL does all in dataframe
#' @param  col the name of the column with the GWL values
#' @param  method "both" (default), "yuepilon", or "zhang"
#' @export
#' @return a dataframe of results for all wells evaluated
#' @examples \dontrun{
#'
#'}
gwlZypTest <- function(dataframe, wells=NULL, col, method="both") {
  
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