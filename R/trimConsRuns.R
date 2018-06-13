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

#' Find consecuctive runs of a value in extremes of a vector
#'
#' Finds the start and end points of consecutive runs of a value in the 
#' beginning and end of a vector.
#' @param  x The vector
#' @param  val The value for which to find consecutive runs
#' @param  head (Proportion between 0 and 1, default = 0.1) The beginning portion of 
#'         the vector in which to look for consecutive missing values
#' @param  tail (Proportion between 0 and 1, default = 0.9) The end portion of 
#'         the vector in which to look for consecutive missing values
#' @param  n_consec The number of consecutive values which constitutes a 'long' run (default = 4)
#' @export
#' @return A list of start and end points of a vector to remove heavily weighted
#'         heads and tails containing continuous runs of a value (likely denoting missing)
#' @examples \dontrun{
#'  x <- rbinom(100, size=1, prob=0.5)
#'  trunc <- trimConsRuns(x, 1, n_consec=4)
#'  trunc_x <- x[trunc$start:trunc$end]
#'}
trimConsRuns <- function(x, val, head=0.1, tail=0.9, n_consec = 4)  {
  
  x_orig <- x
  
  counter_env <- new.env()
  counter_env$head_rem <- 0
  counter_env$tail_rem <- length(x)
  
  inner <- function(x, val, head, tail, n_consec) {
    
    # The function body
    runs <- unclass(rle(x))
    runs$end <- cumsum(runs$lengths)
    runs$beginning <- runs$end - runs$lengths
    runs <- as.data.frame(runs, stringsAsFactors=FALSE)
    runs <- runs[runs$values == val & runs$lengths >= n_consec,]
    
    # Find where runs occur in head
    head_remove <- suppressWarnings(
      max(runs$end[runs$beginning + n_consec <= length(x) * head])
    )
    
    if (is.infinite(head_remove)) head_remove <- 0
    
    # Find where runs occur in tail:
    tail_remove <- suppressWarnings(
      min(runs$beginning[runs$end - n_consec >= length(x) * tail])
    )
    
    if (is.infinite(tail_remove)) tail_remove <- length(x)
    
    # Get counters from counter_env and update them
    glob_head_rem <- get("head_rem", envir = counter_env) + head_remove
    assign("head_rem", glob_head_rem, envir = counter_env)
    
    glob_tail_rem <- get("tail_rem", envir = counter_env) - (length(x) - tail_remove)
    assign("tail_rem", glob_tail_rem, envir = counter_env)
    
    # The recursive part.
    if (head_remove == 0 && tail_remove == length(x)) {
      return(list(start = glob_head_rem + 1, end = glob_tail_rem))
    } else {
      inner(x[(head_remove + 1):tail_remove], val, head, tail, n_consec)
    }
    
  }
  
  inner(x, val, head, tail, n_consec)
  
}
