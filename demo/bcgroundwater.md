First, download some data for a well of interest from the B.C.
Observation Well Network [interactive map
tool](http://www.env.gov.bc.ca/wsd/data_searches/obswell/map/obsWells.html).
We have downloaded the data from Observation Well 309 and saved it.

Load the package, and read in the data:

    library("bcgroundwater")
    data <- readGWLdata("gwl_report.csv", emsID = "E208036")

The data will be in the following format:

    ##    EMS_ID Well_Num                                     Station_Name
    ## 1 E208036      309 OBS WELL 309 - GOLDEN (HIGHWAY 95 & ALMBERG RD.)
    ## 2 E208036      309 OBS WELL 309 - GOLDEN (HIGHWAY 95 & ALMBERG RD.)
    ## 3 E208036      309 OBS WELL 309 - GOLDEN (HIGHWAY 95 & ALMBERG RD.)
    ## 4 E208036      309 OBS WELL 309 - GOLDEN (HIGHWAY 95 & ALMBERG RD.)
    ## 5 E208036      309 OBS WELL 309 - GOLDEN (HIGHWAY 95 & ALMBERG RD.)
    ## 6 E208036      309 OBS WELL 309 - GOLDEN (HIGHWAY 95 & ALMBERG RD.)
    ##                  Date    GWL Historical_Daily_Average
    ## 1 1989-10-19 12:00:00 23.971                       NA
    ## 2 1989-10-31 12:00:00 23.994                       NA
    ## 3 1989-12-01 12:00:00 24.029                       NA
    ## 4 1990-01-01 12:00:00 24.286                       NA
    ## 5 1990-02-01 12:00:00 24.339                       NA
    ## 6 1990-03-01 12:00:00 24.429                       NA
    ##   Historical_Daily_Minimum Historical_Daily_Maximum     Status
    ## 1                       NA                       NA  Validated
    ## 2                       NA                       NA  Validated
    ## 3                       NA                       NA  Validated
    ## 4                       NA                       NA  Validated
    ## 5                       NA                       NA  Validated
    ## 6                       NA                       NA  Validated

Next, calculate the median monthly values:

    monthly_data <- monthlyValues(data)
    head(monthly_data)

    ## Source: local data frame [6 x 8]
    ## 
    ##    EMS_ID Well_Num       Date med_GWL nReadings Year Month dev_med_GWL
    ## 1 E208036      309 1989-11-01 23.9825         4 1989    11    -0.02325
    ## 2 E208036      309 1989-12-01 24.0290         2 1989    12     0.02325
    ## 3 E208036      309 1990-01-01 24.2860         2 1990     1     0.60000
    ## 4 E208036      309 1990-02-01 24.3390         2 1990     2     0.65300
    ## 5 E208036      309 1990-03-01 24.4290         2 1990     3     0.74300
    ## 6 E208036      309 1990-04-01 24.2290         2 1990     4     0.54300

You can plot the seasonal patterns in the water levels of the well with
`gwlMonthlyPlot()`:

    monthlyplot <- gwlMonthlyPlot(monthly_data, last12 = TRUE)
    plot(monthlyplot)

![](..\demo\bcgroundwater_files/figure-markdown_strict/unnamed-chunk-4-1.png)

To perform the analysis, you will need to generate a full time series
with no gaps. `makeWellTS()` does this for you, interpolating the
missing values:

    full_monthly_data <- makeWellTS(monthly_data)
    head(monthly_data)

    ## Source: local data frame [6 x 8]
    ## 
    ##    EMS_ID Well_Num       Date med_GWL nReadings Year Month dev_med_GWL
    ## 1 E208036      309 1989-11-01 23.9825         4 1989    11    -0.02325
    ## 2 E208036      309 1989-12-01 24.0290         2 1989    12     0.02325
    ## 3 E208036      309 1990-01-01 24.2860         2 1990     1     0.60000
    ## 4 E208036      309 1990-02-01 24.3390         2 1990     2     0.65300
    ## 5 E208036      309 1990-03-01 24.4290         2 1990     3     0.74300
    ## 6 E208036      309 1990-04-01 24.2290         2 1990     4     0.54300

For trend analysis over a long time series, it is often beneficial to
test for trends with yearly averages, otherwise serial autocorrelation
can be a problem (even with pre-whitening). These can be calculated
easily using the `dplyr` package:

    library("dplyr")

    annual_data <- full_monthly_data %>%
      select(-yearmonth) %>% 
      group_by(EMS_ID, Well_Num, Year) %>%
      summarize(nReadings = n()
                , mean_GWL = mean(med_GWL)
                , SD = sd(med_GWL)
                , med_GWL = median(med_GWL)
                , q95_GWL = quantile(med_GWL, 0.95)) %>% 
      as.data.frame(stringsAsFactors = FALSE)

You can now calculate the trend:

    trends <- gwlZypTest(annual_data, col = "mean_GWL")
    trends

    ##    EMS_ID test_type      lbound       trend    trendp     ubound
    ## 1 E208036  yuepilon -0.00858410 0.006741667 0.1752833 0.01971474
    ## 2 E208036     zhang -0.01725774 0.006296706 0.1637144 0.03007101
    ##          tau       sig nruns   autocor valid_frac      linear intercept
    ## 1 0.07333333 0.6238124     1 0.4137587          1 0.006153812  24.03063
    ## 2 0.07333333 0.6238124     3 0.4120372          1 0.006153812  23.96411

Finally, plot the time series with the trend overlaid (we will use the
results from the yuepilon method), optionally with interpolated values
overlaid:

    trend_plot <- gwlAreaPlot(full_monthly_data, trend = trends$trend[1], 
                              intercept = trends$intercept[1], sig = trends$sig[1], 
                              state = "Stable", mkperiod = "annual", showInterpolated = TRUE)
    plot(trend_plot)

![](..\demo\bcgroundwater_files/figure-markdown_strict/unnamed-chunk-8-1.png)
