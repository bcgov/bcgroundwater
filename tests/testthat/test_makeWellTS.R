context("make_well_ts")

test_that("make_well_ts returns timeseries with no missing data", {
  g <- get_gwl(well = 309)
  expect_silent(m <- make_well_ts(monthly_values(g)))
  expect_is(m, "data.frame")
  expect_gt(nrow(m), 0)
  expect_true(all(!is.na(m$med_GWL)))
  
  expect_silent(p <- gwl_monthly_plot(m, last12 = TRUE))
  expect_is(p, "ggplot")
})