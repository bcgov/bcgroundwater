#' Convert zone+utm pairs to lat/long.
#'
#' Convert zone+utm pairs to lat/long. Can take either a single zone + utm,
#' or a data frame with many.  Allows for datasets with different zones and 
#' datum for each utm.
#' @import rgdal dplyr
#' @param zone integer, or column name in 'data'
#' @param  easting integer, or column name in 'data'
#' @param  northing integer, or column name in 'data'
#' @param  datum string or column name in 'data'. Default 'NAD83'
#' @param  data (optional) a data frame with zone + utms
#' @param  key Name of column in 'data' that contains a unique identifier for each row
#' @export
#' @return either a vector of length 2 with longitude  and latitude
#'        respectively, or a dataframe with the 'key' column and longitude
#'        and latitude.
#' @examples \dontrun{
#'
#'}
utm_dd <- function(zone=NULL, easting=NULL, northing=NULL, datum="NAD83", data=NULL, key=NULL) {

  get_dd <- function(d) {
    # requires a one-row dataframe with zone, easting, northing, datum (in that order)
    
    utm <- SpatialPoints(d[2:3]
                         , proj4string=CRS(paste0("+proj=utm +datum=", d[4]
                                                  , " +zone=", d[1])))
    sp <- spTransform(utm, CRS("+proj=longlat"))  
    coordinates(sp)
    
  }
  
  if (any(is.null(zone),is.null(easting),is.null(northing))) {
    
    stop("You must supply zone, easting, and northing")
    
  } else if (is.null(data)) {
    
    utms <- data.frame(zone,easting,northing,datum, stringsAsFactors=FALSE)
    as.vector(get_dd(utms))
    
  } else if (is.null(key)) {
    
    stop("You must supply a column name for 'key'")
    
  } else {
    if (!datum %in% colnames(data)) {
      datum <- rep(datum,nrow(data))
      utms <- data.frame(data[c(key,zone,easting,northing)],datum
                         , stringsAsFactors=FALSE)
    } else {
      utms <- data[c(key,zone,easting,northing,datum)]
    }
    
    utms <- na.omit(utms)
    
    longlat <- utms %.%
      do(function(x) get_dd(x[2:5]))
    
    names(longlat)[2:3] <- c("Longitude","Latitude")
    
    return(longlat)    
  }
  
}