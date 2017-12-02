context("monthlyValues and gwlMonthlyPlot")

test_that("monthlyValues returns data", {
  g <- get_gwl(well = 309)
  expect_silent(m <- monthlyValues(g))
  expect_is(m, "data.frame")
  expect_gt(nrow(m), 0)
  
  expect_silent(p <- gwlMonthlyPlot(m, last12 = TRUE))
  expect_is(p, "ggplot")
})