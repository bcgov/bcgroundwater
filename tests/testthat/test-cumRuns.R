# Four sets in head: two within 10%, one within 10% after first 2 removed, 
# one shouldn't be removed
set.seed(20)
x <- rnorm(100000)
x[c(10:20, 2000:2010, 11000:11020, 20000:21000)] <- 0
foo <- trimConsRuns(x, val = 0, n_consec = 5, head = 0.1, tail = 0.9)

# Four sets in tail: two within 10%, one within 10% after first 2 removed, 
# one shouldn't be removed
y <- rev(x)
foo <- trimConsRuns(y, val = 0, n_consec = 5, head = 0.1, tail = 0.9)

#Four runs in each of head and tail
z <- c(x[1:(0.5 * length(x))], y[(0.5 * length(y)):length(y)])
foo <- trimConsRuns(z, val = 0, n_consec = 5, head = 0.1, tail = 0.9)
