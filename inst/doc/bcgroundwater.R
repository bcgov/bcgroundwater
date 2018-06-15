## ----set-options, echo=FALSE---------------------------------------------
knitr::opts_chunk$set(fig.width = 6, fig.height = 4)

## ---- eval=FALSE---------------------------------------------------------
#  install.packages("remotes")

## ---- eval=FALSE---------------------------------------------------------
#  library("remotes")
#  install_github("bcgov/bcgroundwater")

## ------------------------------------------------------------------------
library(bcgroundwater)

## ---- message=FALSE, warning=FALSE---------------------------------------
daily_data <- get_gwl(wells = 309, which = "daily")
head(daily_data)

## ---- message=FALSE, warning=FALSE---------------------------------------
recent_data <- get_gwl(wells = 309, which = "recent")
head(recent_data)

## ---- message=FALSE, warning=FALSE---------------------------------------
data <- get_gwl(wells = 309)
head(data)

## ---- message=FALSE, warning=FALSE---------------------------------------
monthly_data <- monthly_values(data)
head(monthly_data)

## ---- message=FALSE, warning=FALSE, fig.align='center'-------------------
monthlyplot <- gwl_monthly_plot(monthly_data, last12 = TRUE)
plot(monthlyplot)

## ---- fig.width=6, fig.height=4, message=FALSE, warning=FALSE------------
full_monthly_data <- make_well_ts(monthly_data)
head(full_monthly_data)

## ---- message=FALSE, warning=FALSE---------------------------------------
library(dplyr)

time_series_attr <- full_monthly_data %>%
  group_by(Well_Num) %>%
  summarise(dataStart = as.Date(min(Date)), 
            dataEnd = as.Date(max(Date)), 
            dataYears = as.numeric(dataEnd - dataStart) / 365, 
            nObs = n(), 
            nMissing = length(med_GWL[nReadings == 0]), 
            percent_missing = round(nMissing/nObs*100, 1)) %>% 
  select(Well_Num, dataYears, nMissing, percent_missing) 
time_series_attr

## ---- message=FALSE, warning=FALSE---------------------------------------
library(dplyr)

annual_data <- full_monthly_data %>%
  select(-yearmonth) %>%
  group_by(EMS_ID, Well_Num, Year) %>%
  summarize(nReadings = n(),
            mean_GWL = mean(med_GWL),
            SD = sd(med_GWL),
            med_GWL = median(med_GWL),
            q95_GWL = quantile(med_GWL, 0.95))
head(annual_data)

## ---- message=FALSE, warning=FALSE---------------------------------------
trends <- gwl_zyp_test(annual_data, byID = "Well_Num", col = "mean_GWL")
trends

## ---- message=FALSE, warning=FALSE---------------------------------------
result <-  trends %>% 
  filter(test_type == "yuepilon") %>%
  mutate(state = case_when(trend >= 0.1 & sig < 0.05 ~ "Large Rate of Decline",
                           trend >= 0.03 & trend < 0.1 & sig < 0.05 ~ "Moderate Rate of Decline",
                           trend <= -0.03 & sig < 0.05 ~ "Increasing",
                           TRUE ~ "Stable")) 
result

## ---- message=FALSE, warning=FALSE, fig.align='center'-------------------
trend_plot <- gwl_area_plot(full_monthly_data, trend = result$trend,
                          intercept = result$intercept, sig = result$sig, state = result$state,
                          mkperiod = "annual", showInterpolated = TRUE)
plot(trend_plot)


