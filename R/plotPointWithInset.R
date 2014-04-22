plotPointWithInset <- function(long, lat, pointColour, bigMap=NULL, overviewMap=NULL
                               , overviewExtent=c(-139,48,-114,60), opts=NULL) {
  
  # long: longitude (dd) of point
  # lat: latitude (dd) of point
  # overviewMap: ggMap of large area that will be in the inset.  If not provided, 
  #           will be generated using overviewExtent
  # overviewExtent: the extent (left, botton, right, top) of the large area that
  #             will be in the inset. Default is British Columbia
  
  require(ggplot2)
  require(ggmap)

  mapExtent <- c(long-2, lat-1, long+2, lat+1)
  insExtentR <- abs(mapExtent[3]-mapExtent[1])*.95+mapExtent[1]
  insExtentL <- abs(mapExtent[3]-mapExtent[1])*.6+mapExtent[1]
  insExtentT <- abs(mapExtent[4]-mapExtent[2])*.95+mapExtent[2]
  insExtentB <- abs(mapExtent[4]-mapExtent[2])*.7+mapExtent[2]
  
  ## Use retry functions, as get_map sometimes fails. From here:
  ## http://stackoverflow.com/a/3151766/1736291
  
  retry <- function(.FUN, max.attempts = 3, sleep.seconds = 0.5) {
    expr <- substitute(.FUN)
    retry_expr(expr, max.attempts, sleep.seconds)
  }
  
  retry_expr <- function(expr, max.attempts = 3, sleep.seconds = 0.5) {
    x <- try(eval(expr))
    if(inherits(x, "try-error") && max.attempts > 0) {
      Sys.sleep(sleep.seconds)
      return(retry_expr(expr, max.attempts - 1))
    }
    x
  }
  
  if (is.null(overviewMap)) {
    overviewMap <- retry(get_map(location=overviewExtent
                                 , scale=1, maptype='terrain'
                                 , source = 'google'),5,5)
  }
  
  if (is.null(bigMap)) {
    bigMap <- retry(get_map(location=mapExtent, scale=1 
                            , maptype='terrain'
                            , source = 'google'),5,5)
  }

  
  inset <- ggmap(overviewMap, extent='device') + 
    coord_map(xlim=overviewExtent[c(1,3)], ylim=overviewExtent[c(2,4)]) + 
    annotate("rect", xmin = mapExtent[1], xmax = mapExtent[3]
             , ymin = mapExtent[2], ymax = mapExtent[4]
             , alpha=0.3, colour="black", size=0.2) +
#     geom_point(x=long, y=lat, colour=pointColour, size=2) + 
    theme(panel.border=element_rect(fill=NA, colour = "black", size=0.5))
  
  mapPlot <- ggmap(bigMap, extent='panel') + 
    geom_point(x=long, y=lat, fill=pointColour, colour="#3182BD", shape=21, size=2.5) + 
    theme(panel.border=element_rect(fill=NA, colour = "black", size=0.5)) + 
    labs(x=NULL, y=NULL) + opts +
    inset(ggplotGrob(inset), xmin = insExtentL, xmax = insExtentR
          , ymin = insExtentB, ymax = insExtentT)
  
  return(mapPlot)
}