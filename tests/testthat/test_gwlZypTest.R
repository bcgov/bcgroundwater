context("gwlZypTest")

test_that("gwlZypTest returns data", {
  g_month <- get_gwl(wells = 309) %>%
    monthlyValues() %>%
    makeWellTS()
  
  g_annual <- g_month %>%
    dplyr::select(-yearmonth) %>% 
    dplyr::group_by(EMS_ID, Well_Num, Year) %>%
    dplyr::summarize(nReadings = length(Well_Num),
                     mean_GWL = mean(med_GWL),
                     SD = sd(med_GWL),
                     med_GWL = median(med_GWL),
                     q95_GWL = quantile(med_GWL, 0.95))
  
  expect_silent(t <- gwlZypTest(g_annual, byID = "Well_Num", col = "mean_GWL"))
  expect_is(t, "data.frame")
  expect_gt(nrow(t), 0)
  expect_true(all(!is.na(t$intercept)))
  
  expect_silent(p <- gwlAreaPlot(g_month, 
                                 trend = t$trend[1],
                                 intercept = t$intercept[1], sig = t$sig[1],
                                 state = "Stable", mkperiod = "annual", showInterpolated = TRUE))
  expect_is(p, "ggplot")
})
