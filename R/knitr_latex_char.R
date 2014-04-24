#' Replace characters with LaTeX compatible characters/code
#'
#' Replaces or escapes characters (\,#,$,%,&,_,^,~) that can't be used 
#' directly in LaTeX. Does not deal with { and }
#' @param x String containing invalid LaTeX characters
#' @export
#' @return String with LaTeX compatbible characters
#' @examples \dontrun{
#'
#'}
knitr_latex_char <- function(x) {
  y <- gsub("\\\\", "\\\\textbackslash{}", x) # backslash has to be first!
  y <- gsub("([#$%&_])", "\\\\\\1", y) # Doesdn't deal with { or } because of function{}
  y <- gsub("\\^", "\\\\textasciicircum{}", y)
  y <- gsub("~", "\\\\textasciitilde{}", y)
  return(y)
}