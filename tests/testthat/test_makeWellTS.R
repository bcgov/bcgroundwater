context("makeWellTS")

test_that("makeWellTS returns timeseries with no missing data", {
  g <- get_gwl(well = 309)
  expect_silent(m <- makeWellTS(monthlyValues(g)))
  expect_is(m, "data.frame")
  expect_gt(nrow(m), 0)
  expect_true(all(!is.na(m$med_GWL)))
  
  expect_silent(p <- gwlMonthlyPlot(m, last12 = TRUE))
  expect_is(p, "ggplot")
})