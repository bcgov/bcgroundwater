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
#' @import grid ggplot2 scales
#' @param  dataframe a dataframe with well level monthly time series and the 
#'         following columns: Date, med_GWL, nReadings
#' @param  trend (numeric) trend in m/month
#' @param  intercept (numeric) intercept in m
#' @param  state Trend classification (stable, declining, increasing)
#' @param  sig (numeric) significance of trend test
#' @param  showInterpolated (logical) show the points where missing values in the 
#'         time series were interpolated
#' @param  save Save the graph to file?
#' @param  path Where to save the graph if save=TRUE
#' @param  mkperiod the period (monthly or annual) the Mann-Kendall test was 
#'         performed on
#' @param  opts other options to pass to ggplot2
#' @export
#' @return A ggplot2 object
#' @examples \dontrun{
#'
#'}
gwlAreaPlot <- function(dataframe, trend, intercept, state, sig, showInterpolated=FALSE, save=FALSE, path="./", mkperiod="monthly", opts=NULL) {
  
  if (showInterpolated) {
    df <- dataframe
    # if there are no interpolated values, reset showInterpolated to FALSE
    if (nrow(dataframe[dataframe$nReadings == 0,]) == 0) {
      showInterpolated <- FALSE
    }
  } else {
    df <- dataframe[dataframe$nReadings > 0,]
  }
  
  minDate <- min(as.Date(df$Date))
  maxDate <- max(as.Date(df$Date))
  
  WellNum <- df$Well_Num[1]
  
  ## Slope is in m/month, have to convert to m/day to work with Date format
  if (mkperiod == "monthly") {
    slope <- -(trend/365)
  } else {
    slope <- -(trend/12/365)
  }
  
  trendpre <- ifelse(slope > 0,"Trend: +", "Trend: ")
  trendprintval <- paste0(format(slope*365,digits=2, nsmall=2
                                 , scientific=FALSE),"m/year")
  
  trendprint <- paste0(trendpre, trendprintval)
  
  int.well <- intercept + slope*as.numeric(minDate)
  
  maxgwl <- max(df$med_GWL, na.rm=TRUE)
  mingwl <- min(df$med_GWL, na.rm=TRUE)
  gwlrange <- maxgwl-mingwl
  midgwl <- (maxgwl+mingwl)/2
  lims <- c(midgwl+gwlrange, midgwl-gwlrange)
  
  plot.area <- ggplot(df, aes(x=as.Date(Date))) + 
    geom_ribbon(aes(ymin=med_GWL, ymax=max(lims[1],max(med_GWL, na.rm=TRUE)+5)
                    , fill="Groundwater Level"), alpha=0.3) + 
    geom_abline(intercept=-int.well, slope=slope, aes(colour='LTT'), size=1) + 
    annotate(geom="text", x=minDate+as.numeric(maxDate-minDate)/50
             , y=lims[2], hjust=0, vjust=1, colour="grey50", size=3
             , label=paste0(trendprint, "        Significance: "
                            , format(sig, digits=2, nsmall=3
                                     , scientific=3)
                            , "        State: ", state)) + 
    labs(title="Groundwater levels and long-term trend", x="Date"
         , y="Depth below ground (m)") + 
    theme(panel.background=element_rect(fill="white")
          , line=element_line(colour="grey50")
          , text=element_text(colour="grey50")
          , panel.grid.major.x=element_blank()
          , panel.grid.minor.x=element_blank()
          , legend.position="top", legend.box="horizontal") + 
    scale_y_reverse(expand=c(0,0)) + coord_cartesian(ylim=lims) + 
    scale_x_date(labels=date_format("%Y"), breaks=date_breaks("2 years")
                 , expand=c(0,0)) + 
    scale_fill_manual(name='', values=c('Groundwater Level' = "#1E90FF"))
  
  nms <- c('', '')
  vals <- c(Interp='red', LTT='orange')
  labs <- c('Interpolated (missing) values', 'Long-term trend')
  override_list <- list(shape=c(16, NA), linetype=c(0, 1))
  
  if (showInterpolated) {
    plot.area <- plot.area + geom_point(data=df[df$nReadings==0,]
                                        , aes(y=med_GWL), colour='red'
                                        , size=1)
  } else {
    vals <- vals[-1]
    labs <- labs[-1]
    override_list <- lapply(override_list, `[`, -1)
  }
  
  plot.area <- plot.area +
    scale_colour_manual(name = nms, values=vals, labels=labs) +
    guides(fill = guide_legend(override.aes=list(linetype = 0, shape=NA)),
           colour = guide_legend(override.aes= override_list))
  opts
  
  if (save) {
    ggsave(filename=paste0(path, "trend_chart_well_", WellNum, ".pdf")
           , plot=plot.area)
  }
  
  return(plot.area)
  
}