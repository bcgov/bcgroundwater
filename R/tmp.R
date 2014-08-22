set.seed(20)
x <- rnorm(200)
x[c(2:8, 21:27, 170:179, 194:199)] <- 0

val <- 0
n_consec = 5
head = 0.1
tail = 0.9

runs <- unclass(rle(x))
runs <- as.data.frame(runs, stringsAsFactors=FALSE)
runs$end <- cumsum(runs$lengths)
runs$beginning <- runs$end - runs$lengths + 1
val_runs <- runs$values == val & runs$lengths >= n_consec
h <- 1
t <- length(x)

for (i in which(val_runs)) {
  run <- runs[i,]
  
  if (run$beginning + n_consec <= length(x[h:t]) * head) {
    h <- run$end + 1
  }
  
  if (run$end - n_consec >= length(x[h:t]) * tail) {
    t <- run$beginning - 1
  }
  
}