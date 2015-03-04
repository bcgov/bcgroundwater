## ----, set-options, echo=FALSE, message=FALSE, results='hide'------------
knitr::opts_chunk$set(fig.width = 6, fig.height = 4)

## ------------------------------------------------------------------------
## First load the library:
library("bcgroundwater")

data <- getGWLdata("E208036", fromDate = "1989-01-01", 
                   toDate = "2014-01-01", save = FALSE)

## ----, eval=FALSE--------------------------------------------------------
#  getGWLdata("E208036", fromDate = "1989-01-01",
#             toDate = "2014-01-01", save = TRUE, data.dir = ".")
#  
#  data <- readGWLdata("wellE208036.csv", emsID = "E208036")

## ----echo = FALSE--------------------------------------------------------
head(data)

## ------------------------------------------------------------------------
monthly_data <- monthlyValues(data)
head(monthly_data)

## ------------------------------------------------------------------------
monthlyplot <- gwlMonthlyPlot(monthly_data, last12 = TRUE)
plot(monthlyplot)

## ----, fig.width=6, fig.height=4-----------------------------------------
full_monthly_data <- makeWellTS(monthly_data)
head(monthly_data)

## ------------------------------------------------------------------------
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

## ------------------------------------------------------------------------
trends <- gwlZypTest(annual_data, col = "mean_GWL")
trends

## ----, warning=FALSE-----------------------------------------------------
trend_plot <- gwlAreaPlot(full_monthly_data, trend = trends$trend[1], 
                          intercept = trends$intercept[1], sig = trends$sig[1], 
                          state = "Stable", mkperiod = "annual", showInterpolated = TRUE)
plot(trend_plot)


