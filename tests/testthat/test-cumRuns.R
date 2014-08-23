# Simple case with one set of missing vals in head
set.seed(20)
x <- rnorm(200)
x[2:10] <- 0
y <- consRuns(x, val = 0, n_consec = 5)

# One set of missing vals in tail
set.seed(20)
x <- rnorm(200)
x[190:198] <- 0
consRuns(x, val = 0, n_consec = 5, head = 0.1, tail = 0.9)

# Two sets in head
set.seed(20)
x <- rnorm(200)
x[c(2:8, 25:35)] <- 0 # check that these would be evaluated in two loops
consRuns(x, val = 0, n_consec = 5, head = 0.1, tail = 0.9)

# Two sets in tail
set.seed(20)
x <- rnorm(200)
x[c(185:190, 194:199)] <- 0
consRuns(x, val = 0, n_consec = 5)

# Two sets in head and tail
set.seed(20)
x <- rnorm(100000)
x[c(10:20, 2000:2010, 10000:10099,90010:90020,95000:96000)] <- 0
foo <- consRuns(x, val = 0, n_consec = 5, head = 0.1, tail = 0.9)

