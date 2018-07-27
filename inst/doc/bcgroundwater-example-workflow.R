## ----set-options, echo=FALSE---------------------------------------------
knitr::opts_chunk$set(fig.width = 7, fig.height = 4, message=FALSE, warning=FALSE)

## ----setup---------------------------------------------------------------
library(bcgroundwater) # get B.C. data, implements `zyp` M-K trend test
# you will need to install `bcgroundwater` with remotes::install_github("bcgov/bcgroundwater")
library(ggplot2) # plotting
library(dplyr) # data munging
library(gghighlight) # highlight interpolated (missing) values
library(EnvStats) # for seasonal M-K test
library(tibble) # wrangle Sesonal Kendall output

## ------------------------------------------------------------------------
well <- "45" # Observation Well Number

data <- get_gwl(wells = well)
head(data)

## ------------------------------------------------------------------------
# calculate the median monthly values
monthly_data <- monthly_values(data) %>% 
  mutate(Date = as.Date(Date))

# visualise the monthly time-series data
ggplot(monthly_data, aes(Date, med_GWL)) + 
  geom_point() +
  scale_x_date(date_breaks = "3 year", date_labels = "%Y") +
  scale_y_reverse() +
  theme_bw() +
  labs(title = paste0("Median Monthly GWL Values from Well #", well),
       caption = paste0("\nData sourced from B.C. Data Catalogue on ", Sys.Date()),
       x = NULL,
       y = "Depth Below Ground (metres)")

## ------------------------------------------------------------------------
# interpolate missing median monthly values
full_monthly_data <- make_well_ts(monthly_data, trim=FALSE)

# visualise the interpolated data in the time-series with gghighlight
ggplot(full_monthly_data, aes(Date, med_GWL)) + 
  geom_point() +
  gghighlight(nReadings == "0") +
  scale_x_date(date_breaks = "3 year", date_labels = "%Y") +
  scale_y_reverse() +
  theme_bw() +
  theme(legend.position="none") +
  labs(title = paste0("Interpolated Median Monthly GWL Values from Well #", well),
       subtitle = "Interpolated (missing) values = black dots",
       caption = paste0("\nData sourced from B.C. Data Catalogue on ", Sys.Date()),
       x = NULL,
       y = "Depth Below Ground (metres)")

## ------------------------------------------------------------------------
full_monthly_data %>%
  group_by(Well_Num) %>%
  summarise(dataStart = as.Date(min(Date)), 
            dataEnd = as.Date(max(Date)), 
            dataYears = as.numeric(dataEnd - dataStart) / 365, 
            nObs = n(), 
            nMissing = length(med_GWL[nReadings == 0]), 
            percent_missing = round(nMissing/nObs*100, 1)) %>% 
  select(Well_Num, dataYears, dataEnd, nMissing, percent_missing) 

## ------------------------------------------------------------------------
#calculate mean annual values
annual_data <- full_monthly_data %>%
  select(-yearmonth) %>%
  group_by(EMS_ID, Well_Num, Year) %>%
  summarize(nReadings = n(),
            mean_GWL = mean(med_GWL),
            SD = sd(med_GWL),
            med_GWL = median(med_GWL),
            q95_GWL = quantile(med_GWL, 0.95),
            n_months = n()) %>% 
  mutate(Date = as.Date(paste0(Year,"-01-01"))) 

#Mann-Kendall trend test using result from the yuepilon method
result <- gwl_zyp_test(annual_data, byID = "Well_Num", col = "mean_GWL") %>% 
  filter(test_type == "yuepilon")
result

#visualise the data & Mann-Kendall results
ggplot(annual_data) +
  geom_point(aes(Date, mean_GWL)) +
  geom_abline(data = result, intercept = -result$intercept, slope = -(result$trend/365),
              colour = "orange") +
  scale_x_date(date_breaks = "3 year", date_labels = "%Y") +
  scale_y_reverse() + 
  theme_bw() +
  labs(title = paste0("M-K Trend Test on Mean Annual GWL Values - Well #",
                      well),
       subtitle = paste0("Model Effect Size: ", signif(-result$trend, digits = 3),
                         " (m/year)   P-Value: ", format(signif(result$sig, digits = 2),
                                                         scientific = FALSE)), 
       caption = paste0("\nData sourced from B.C. Data Catalogue on ",
                        Sys.Date()),
       x = NULL,
       y = "Depth Below Ground (metres)") 

## ------------------------------------------------------------------------
# use years with all (12) months data
full_monthly_data_comp_yrs <- full_monthly_data %>% 
  group_by(Year) %>% 
  filter(n() == 12) %>% 
  ungroup()

#seasonal-K trend test
sk <- kendallSeasonalTrendTest(med_GWL ~ Month + Year, 
                               data = full_monthly_data_comp_yrs)
print(sk)

## ----fig.width = 7, fig.height = 6---------------------------------------
# overall seasonal model effect size
sk_slope <- sk[["estimate"]][["slope"]]

# overall seasonal model significance
sk_sig <- sk[["p.value"]][["z (Trend)"]]

# put seasonal estimates into a dataframe with Month column
s_est <- as.data.frame(sk$seasonal.estimates)
s_est <- rowid_to_column(s_est, "Month")

# calculate seasonal y-intercepts
s_est$corr_int <- -(s_est$intercept +
                      s_est$slope *
                      as.numeric(format(min(full_monthly_data_comp_yrs$Date), "%Y")))
                            
# create month labels facets in plot
month.abb2 <- setNames(month.abb, as.character(1:12))

# plot seasonal M-K trend results
ggplot(full_monthly_data_comp_yrs) +
  geom_point(data = , aes(Date, med_GWL)) +
  geom_abline(data = s_est,
              aes(intercept = s_est$corr_int,
                  slope = -s_est$slope/365), colour = "orange") +
  geom_text(data = s_est,
            aes(label = paste0(signif(-s_est$slope, digits = 2), " (m/year)" )),
            x = 12000, y = -5.5,
            size = 3, colour = "orange") +
  facet_wrap(~Month, labeller = as_labeller(month.abb2)) +
  scale_x_date(date_breaks = "11 year", date_labels = "%Y") +
  scale_y_reverse() + 
  theme_bw() +
  labs(title = paste0("Seasonal Kendall Trend Test on Median Monthly GWL Values - Well #",
                      well),
       subtitle = paste0("Overall Model Effect Size: ",
                         signif(sk_slope, digits = 3),
                         " (m/year)   P-Value: ",
                         format(round(sk_sig, digits = 2),
                                scientific = FALSE)), 
       caption = paste0("\nData sourced from B.C. Data Catalogue on ",
                        Sys.Date()),
       x = NULL,
       y = "Depth Below Ground (metres)")

