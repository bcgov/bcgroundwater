set.seed(20)
x <- rnorm(200)
x[c(2:8, 21:27, 170:179, 194:199)] <- 0

val <- 0
n_consec = 5
head = 0.1

runs <- unclass(rle(x))
runs <- as.data.frame(runs, stringsAsFactors=FALSE)
runs$end <- cumsum(runs$lengths)
runs$beginning <- runs$end - runs$lengths
val_runs <- runs$values == val & runs$lengths >= n_consec

for (i in which(val_runs)) {
  run <- runs[i,]
  try(
    if (run$beginning <= sum(runs$lengths) * head) {
      runs <- runs[i:length(runs),]
    }
  )
}
