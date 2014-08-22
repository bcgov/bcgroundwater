#' Find consecuctive runs of a value in extremes of a vector
#'
#' Finds the start and end points of consecutive runs of of a value in the 
#' beginning and end of a vector 
#' @param  x the vector
#' @param  val the value for which to find consecutive runs
#' @param  head (proportion between 0 and 1, default = 0.2) the beginning portion of 
#'         the vector in which to look for consecutive missing values
#' @param  tail (proportion between 0 and 1, default = 0.8) the end portion of 
#'         the vector in which to look for consecutive missing values
#' @param  n_consec the number of consecutive values which constitutes a 'long' run
#' @export
#' @return a list of start and end points of a vector to remove heavily weighted
#'         heads and tails containing continuous runs of a value (likely denoting missing)
#' @examples \dontrun{
#'  x <- rbinom(100, size=1, prob=0.5)
#'  trunc <- consRuns(x, 1, n_consec=4)
#'  trunc_x <- x[trunc$start:trunc$end]
#'}
consRuns <- function(x, val, head=0.2, tail=0.8, n_consec)  {
  
  x_orig <- x
  
  # occur function from here:
  # http://r.789695.n4.nabble.com/matching-a-sequence-in-a-vector-td4389523.html
  occur <- function(patrn, exmpl)
  {
    m <- length(patrn)
    n <- length(exmpl)
    candidate <- seq.int(length=n-m+1)
    for (i in seq.int(length=m)) {
      candidate <- candidate[patrn[i] == exmpl[candidate + i - 1]]
    }
    candidate
  }
  
  wrap <- function(x, val, head, tail, n_consec) {
    
    # The function body
    runs <- unclass(rle(x))
    runs$end <- cumsum(runs$lengths)
    runs$beginning <- runs$end - runs$lengths
    runs <- as.data.frame(runs, stringsAsFactors=FALSE)
    runs <- runs[runs$values == val & runs$lengths >= n_consec,]
    
    # Find where runs occur in head
    head_remove <- suppressWarnings(
      max(runs$end[length(x) * head - runs$beginning >= n_consec])
    )
    if (is.infinite(head_remove)) head_remove <- 1
    if (x[head_remove] == val) head_remove <- head_remove + 1
    
    # Find where runs occur in tail:
    tail_remove <- suppressWarnings(
      min(runs$beginning[runs$end - length(x) * tail >= n_consec])
    )
    
    if (is.infinite(tail_remove)) tail_remove <- length(x)
    
    # The recursive part. TODO: iterate head_remove and tail_remove
    if (head_remove == 1 && tail_remove == length(x)) {
      #return(x[head_remove:tail_remove])
      start <- occur(x[head_remove:tail_remove], x_orig)
      end <- length(x[head_remove:tail_remove]) + start - 1
      return(list(start = start, end = end))
    } else {
      wrap(x[head_remove:tail_remove], val, head, tail, n_consec)
    }
    
  }
  
  wrap(x, val, head, tail, n_consec)
  
}

# http://stackoverflow.com/questions/16480722/recursive-functions-and-global-vs-local-variables
                                                                                                          