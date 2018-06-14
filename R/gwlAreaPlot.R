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

#' Creates an area plot of groundwater levels with trend line
#'
#' An area plot (hydrograph) of groundwater levels, with trend line of a 
#' given slope and intercept, optionally with interpolated values shown.

#' @importFrom scales date_breaks date_format
#' @param  dataframe A dataframe with well level monthly time series and the 
#'         following columns: Date, med_GWL, nReadings
#' @param  trend (Numeric) Trend in m/month
#' @param  intercept (Numeric) Intercept in m
#' @param  state Trend classification: \code{"stable"}, or another description 
#'         of the magnitude and direction of the trend. This description will
#'         be displayed on the graph in Title Case. 
#'         If \code{"stable"}, no trend value or statistical significance 
#'         will be displayed on the plot, otherwise this information will be 
#'         displayed alongside the \code{state} information.
#' @param  sig (Numeric) Significance of trend test
#' @param  showInterpolated (Logical) Show the points where missing values in the 
#'         time series were interpolated
#' @param  save Save the graph to file?
#' @param  path Where to save the graph if \code{save = TRUE}
#' @param  mkperiod The period (\code{"monthly"} or \code{"annual"}) 
#'         the Mann-Kendall test was performed on
#' @param  opts Other options to pass to ggplot2
#' 
#' @return A ggplot2 object.
#' 
#' @export
gwlAreaPlot <- function(dataframe, trend, intercept, state, sig, 
                        showInterpolated = FALSE, save = FALSE, 
                        path = "./", mkperiod = "monthly", opts = NULL) {
  
  if (showInterpolated) {
    df <- dataframe
    # if there are no interpolated values, reset showInterpolated to FALSE
    if (nrow(dataframe[dataframe$nReadings == 0,]) == 0) {
      showInterpolated <- FALSE
    }
  } else {
    df <- dataframe[dataframe$nReadings > 0,]
  }
  
  df$Date <- as.Date(df$Date)
  
  minDate <- min(df$Date)
  maxDate <- max(df$Date)
  
  WellNum <- df$Well_Num[1]
  
  if (mkperiod == "monthly") {
    ## Slope is in m/month, have to convert to m/day to work with Date format
    slope <- -(trend/12/365)
  } else if (mkperiod == "annual") {
    slope <- -(trend/365)
  } else {
    stop("mkperiod must be either 'monthly' or 'annual'")
  }
  
  if (tolower(state) == "stable") {
    trendprint <- "Trend: No Significant Trend"
    sigprint <- ""
  } else {
    trendpre <- ifelse(slope > 0, "Trend: +", "Trend: ")
    trendprint <- paste0(trendpre, 
                         paste0(format(slope * 365, digits = 2, nsmall = 2,
                                       scientific = FALSE), "m/year"))
    
    sigprint <- paste0("Significance: ", 
                       format(sig, digits = 2, nsmall = 3, scientific = 3))
  }

  int.well <- intercept + slope * as.numeric(minDate)
  
  maxgwl <- max(df$med_GWL, na.rm = TRUE)
  mingwl <- min(df$med_GWL, na.rm = TRUE)
  gwlrange <- maxgwl - mingwl
  midgwl <- (maxgwl + mingwl)/2
  lims <- c(midgwl + gwlrange, midgwl - gwlrange)
  
  df$max_lims <- max(lims[1], max(df$med_GWL, na.rm = TRUE) + 5)
  
  plot.area <- ggplot(df, aes_string(x = "Date")) + 
    geom_ribbon(aes_string(ymin = "med_GWL", 
                           ymax = "max_lims",
                           fill = "'Groundwater Level'"), alpha = 0.3) + 
    geom_abline(aes_string(intercept = "intercept", slope = "slope", colour = "'LTT'"), 
                data = data.frame(intercept = -int.well, slope = slope), size = 1) + 
    labs(title = "Observed Long-term Trend in Groundwater Levels\n", x = "Date",
         y = "Depth Below Ground (metres)",
         subtitle = paste0("State: ", tools::toTitleCase(tolower(state)),
                           "        ",
                           trendprint,
                           "        ",
                           sigprint)) +
                           # "Significance: ",
                           # format(sig, digits = 2, nsmall = 3, scientific = 3))) +
    theme_minimal() +
    theme(
      text = element_text(colour = "black"),
      panel.grid.minor.x = element_blank(),
      panel.grid.major.x = element_blank(),
      axis.line = element_line(colour="grey50"),
      legend.position = "bottom", legend.box =  "horizontal",
      plot.title = element_text(hjust = 0.5),
      plot.subtitle = element_text(hjust = 0.5)) + 
    scale_y_reverse(expand = c(0,0)) + coord_cartesian(ylim = lims) + 
    scale_x_date(labels = date_format("%Y"), breaks = date_breaks("3 years"),
                 expand = c(0,0)) + 
    scale_fill_manual(name = '', values = c('Groundwater Level' = "#1E90FF"))
  
  vals <- c(LTT = 'orange', Interp = 'grey30')
  labs <- c('Long-term Trend', 'Interpolated (Missing) Values')
  override_list <- list(colour = c("orange", "grey30"), shape = c(NA, 16), linetype = c(1, 0))
  
  if (showInterpolated) {
    plot.area <- plot.area + 
      geom_point(data = df[df$nReadings == 0,],
                 aes_string(y = "med_GWL", colour = "'Interp'"),
                 size = 1)
  } else {
    vals <- vals[1]
    labs <- labs[1]
    override_list <- lapply(override_list, `[`, 1)
  }
  
  plot.area <- plot.area +
    scale_colour_manual(name = '', values = vals, labels = labs,
                        guide = guide_legend(override.aes = override_list)) +
    
    opts
  
  if (save) {
    ggsave(filename = paste0(path, "trend_chart_well_", WellNum, ".pdf"),
           plot = plot.area)
  }
  
  return(plot.area)
  
}