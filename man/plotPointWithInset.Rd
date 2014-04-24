\name{plotPointWithInset}
\alias{plotPointWithInset}
\title{Plot a point on a map with an overview inset}
\usage{
plotPointWithInset(long, lat, pointColour, bigMap = NULL,
  overviewMap = NULL, overviewExtent = c(-139, 48, -114, 60), opts = NULL)
}
\arguments{
  \item{long}{longitude (dd) of point}

  \item{lat}{latitude (dd) of point}

  \item{pointColour}{the colour of the point}

  \item{bigMap}{ggmap of the zoomed in area that will
  comprise the large map}

  \item{overviewMap}{ggMap of large area that will be in
  the inset.  If not provided, will be generated using
  overviewExtent}

  \item{overviewExtent}{the extent (left, botton, right,
  top) of the large area that will be in the inset. Default
  is British Columbia}

  \item{opts}{additional options to pass to ggplot2}
}
\value{
a ggmap object
}
\description{
Plot a point on a map with an inset in the top right corner
showing an overview of a larger area.
}
\examples{
\dontrun{

}
}

