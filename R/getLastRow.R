getLastRow <- function(dir="./data/welldata", df=wells.df) {
  ## Get the last row in the df that was used to access GWL and dowload the well data
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