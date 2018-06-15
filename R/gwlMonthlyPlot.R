# Copyright 2015 Province of British Columbia
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
# http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.

#' Create a graph of historical monthly water level deviations
#' 
#' Create a graph of historical median monthly water level deviations from
#' yearly average with 5th and 95th percentiles.
#' 
#' @param  dataframe Dataframe containing 'Well_Num', 'Date', 'dev_med_GWL'
#' @param  splines Logical: smooth the line using splines?
#' @param  last12 Logical: plot the last 12 monthly readings as points?
#' @param  save Logical: save as a pdf?
#' @param  path Path to folder in which to save if save=TRUE
#' @param  opts Other options passed on to ggplot2
#' @return A ggplot object.
#'
#' @export
gwl_monthly_plot <- function(dataframe, splines = TRUE, last12 = TRUE, 
                           save = FALSE, path = "./", opts = NULL) {
  
  WellNum <- dataframe$Well_Num[1]
  
  data <- dataframe %>%
    dplyr::group_by(month = lubridate::month(.data$Date, label = TRUE)) %>%
    dplyr::summarize(dev_med = mean(.data$dev_med_GWL, na.rm = TRUE),
                     dev_Q5 = stats::quantile(.data$dev_med_GWL, prob = 0.05,
                                       na.rm = TRUE),
                     dev_Q95 = stats::quantile(.data$dev_med_GWL, prob = 0.95,
                                        na.rm = TRUE))
  
  data.last.12 <- utils::tail(dataframe[, c("Date","dev_med_GWL")], 12)
  #row.names(data.last.12) <- 1:12
  
  if (splines) {
    splines.df <- as.data.frame(stats::spline(as.numeric(data$month), data$dev_med,
                                       method = "fmm"))
    splines.df$y_Q5 <- stats::spline(as.numeric(data$month), data$dev_Q5,
                              method = "fmm")$y
    splines.df$y_Q95 <- stats::spline(as.numeric(data$month), data$dev_Q95,
                               method = "fmm")$y
    names(splines.df) <- names(data)
    data <- splines.df
  }
  
  plot.monthly <- ggplot(data = data, aes_string(x = "month", y = "dev_med")) + 
    geom_ribbon(aes_string(ymin = "dev_Q5", ymax = "dev_Q95", fill = "''"), alpha = 0.2) + 
    geom_line(aes_string(colour = "''"), alpha = 0.4, size = 1) + 
    labs(title = "Monthly Groundwater Level Patterns", x = "Month",
         y = "Difference from Groundwater Level\nYearly Average (metres)") + 
    theme_minimal() +
    theme(
      text = element_text(colour = "black"),
      panel.grid.minor.x = element_blank(),
      panel.grid.major.x = element_blank(),
      axis.line = element_line(colour="grey50"),
      legend.position = "top", legend.box = "horizontal",
      plot.title = element_text(hjust = 0.5)
      #axis.text.x = element_text(angle = 45) # May need if using full month names
    ) +
    scale_y_reverse() +
    scale_x_continuous(breaks = 1:12, labels = month.abb) + 
    scale_colour_manual(name = '', values = "#1E90FF",
                        labels = c("Mean Deviation from Yearly Average"),
                        guide = "legend") +
    scale_fill_manual(name = '', values = "#1E90FF", guide = 'legend',
                      labels = c('Range of 90% of Water Levels')) +
    scale_alpha_identity(name = '', labels = NA) + 
    opts
  
  if (save) {
    ggsave(filename = paste0(path, "monthly_chart_well_", WellNum, ".pdf"), 
           plot = plot.monthly)
  }
  
  return(plot.monthly)
  
}
