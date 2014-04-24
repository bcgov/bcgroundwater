\name{getLastRow}
\alias{getLastRow}
\title{Find out which well was downloaded laast}
\usage{
getLastRow(dir = "./data/welldata", df = wells.df)
}
\arguments{
  \item{dir}{the directory where well files are being
  saved}

  \item{df}{the dataframe from which well IDs are taken}
}
\value{
(integer) the row of the dataframe representing the last
well downloaded
}
\description{
Find the last well that was downloaded and find the row
that represents that well in the dataframe of wells.
}
\examples{
\dontrun{

}
}

