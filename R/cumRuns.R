cumRuns <- function(x, val, head=0.2, tail=0.8, n_consec)  {
  # Return a list of start and end points of a vector to remove heavily weighted
  # heads and tails containing continuous runs of a value (likely denoting misssing)
  # x: the vector
  # val: the value fo which to find consecutive runs
  # head (proportion between 0 and 1, default = 0.2): the beginning portion of 
  #       the vector in which to look for consecutive missing values
  # tail (proportion between 0 and 1, default = 0.8): the end portion of 
  #       the vector in which to look for consecutive missing values
  # n_consec: the number of consecutive values which constitutes a 'long' run
  
  runs <- unclass(rle(x))
  runs$end <- cumsum(runs$lengths)
  runs$beginning <- runs$end - runs$lengths
  runs <- as.data.frame(runs, stringsAsFactors=FALSE)
  runs <- runs[runs$values == val & runs$length >= n_consec,]
  
  # Find where runs occur in head
  head_remove <- suppressWarnings(
    max(runs$end[length(x) * head - runs$beginning >= n_consec])
    )
  if (is.infinite(head_remove)) head_remove <- 1
  if (x[head_remove] == val) head_remove <- 2
  
  # Find where runs occur in tail:
  tail_remove <- suppressWarnings(
    min(runs$beginning[runs$end - length(x) * tail >= n_consec])
    )
  if (is.infinite(tail_remove)) tail_remove <- length(x)
  
  list(start=head_remove, end=tail_remove)
}