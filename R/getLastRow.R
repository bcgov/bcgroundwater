#' Find out which well was downloaded laast
#'
#' Find the last well that was downloaded and find the row that represents that 
#' well in the dataframe of wells.
#' @param dir the directory where well files are being saved
#' @param df the dataframe from which well IDs are taken
#' @export
#' @return (integer) the row of the dataframe representing the last well downloaded
#' @examples \dontrun{
#'
#'}
getLastRow <- function(dir="./data/welldata", df=wells.df) {
  files <- list.files(dir, pattern="well[A-Za-z0-9]+\\.csv", full.names=TRUE)
  if (length(files)==0) {
    last.row <- 1
  } else {
    fileinfo <- do.call("rbind", lapply(files, file.info))
    last.file <- rownames(fileinfo[fileinfo$ctime==max(fileinfo$ctime),])
    last.emsID <- strsplit(last.file,paste0(dir,"/well|.csv"))[[1]][2]
    last.row <- as.numeric(rownames(wells.df[wells.df$EMS_ID == last.emsID,]))
  }
  return(last.row)
}