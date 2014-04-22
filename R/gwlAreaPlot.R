gwlAreaPlot <- function (dataframe, trend, intercept, state, sig, change 
                         , showInterpolated=FALSE, save=FALSE
                         , path="./", mkperiod="monthly", opts=NULL)
{
  # Creates area plot of gw levels with Mann-Kendall Trend line plotted
  
  # dataframe: a dataframe with well level monthly time series and the following 
  #            columns: Date, med_GWL, nReadings
  # trend: (numeric) trend in m/month
  # intercept: (numeric) intercept in m
  # state: Trend classification (stable, declining, increasing)
  # sig: (numeric)significance of trend test
  # change: (numeric) total change in water level in m. Only printed if smooth=TRUE
  # showInterpolated: (logical) show the points where missing values in the 
  #             time series were interpolated
  # mkperiod: the period (monthly or annual) the m-k test was performed on
  
  require(grid)
  require(ggplot2)
  require(scales)
  
  if (showInterpolated) {
    df <- dataframe
    # if there are no interpolated values, reset showInterpolated to FALSE
    if (nrow(dataframe[dataframe$nReadings == 0,]) == 0) {
      showInterpolated <- FALSE
    }
  } else {
    df <- dataframe[dataframe$nReadings > 0,]
  }
  
  smooth <- FALSE # Did have as a parameter, but building legend was complicated 
  # and I don't think it's necessary anyway
  
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
  
  #Don't print change unless smooth (because change derived from smooth)
  if (smooth) {
    changepre <- ifelse(change > 0
                        , "        Total change in water level: +"
                        , "        Total change in water level: ")
    changetxt <- paste0(changepre, format(change, digits=2, nsmall=1), "m")
  } else {
    changetxt <- NULL
  }
  
  int.well <- intercept + slope*as.numeric(minDate)
  
  maxgwl <- max(df$med_GWL, na.rm=TRUE)
  mingwl <- min(df$med_GWL, na.rm=TRUE)
  gwlrange <- maxgwl-mingwl
  midgwl <- (maxgwl+mingwl)/2
  lims <- c(midgwl+gwlrange, midgwl-gwlrange)
  
  .e <- environment()
  
  plot.area <- ggplot(df, aes(x=as.Date(Date)), environment=.e) + 
    geom_ribbon(aes(ymin=med_GWL, ymax=max(lims[1],max(med_GWL, na.rm=TRUE)+5)
                    , fill="#1E90FF"), alpha=0.3) + 
    geom_abline(intercept=-int.well, slope=slope
                , aes(colour='LTT'), size=1, show_guide=TRUE) + 
    annotate(geom="text", x=minDate+as.numeric(maxDate-minDate)/50
             , y=lims[2], hjust=0, vjust=1, colour="grey50", size=3
             , label=paste0(trendprint, "        Significance: "
                            , format(sig, digits=2, nsmall=3
                                     , scientific=3)
                            , "        State: ", state
                            , changetxt)) + 
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
    scale_fill_identity(name='', labels=c('Groundwater Level')
                        , guide=guide_legend(override.aes=list(linetype = 0
                                                                 , shape=NA)))
  
  if (showInterpolated) {
    plot.area <- plot.area + geom_point(data=df[df$nReadings==0,]
                                        , aes(y=med_GWL
                                              , colour='Interp')
                                        , size=1)
    intline <- 0
    intshape <- 16
    intlabel <- 'Interpolated (missing) values'
  } else {
    intline <- NULL
    intshape <- NULL
    intlabel <- NULL
  }
  
  if (smooth) {
    plot.area <- plot.area + geom_smooth(aes(y=med_GWL, colour='Smooth Trend')
                                         , method="loess")
  }
  
  plot.area <- plot.area + 
    scale_colour_manual(name='', values=c('Interp'='red', 'LTT'='orange')
                        , labels=c(intlabel, 'Long-term trend')
                        , guide=guide_legend(override.aes=
                                               list(linetype=c(intline, 1)
                                                    , shape=c(intshape,NA)))) + 
    opts
  
  if (save) {
    ggsave(filename=paste0(path, "trend_chart_well_", WellNum, ".pdf")
           , plot=plot.area)
  }
  
  return(plot.area)
  
}