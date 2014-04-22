knitr_latex_char <- function(x) {
  y <- gsub("\\\\", "\\\\textbackslash{}", x) # backslash has to be first!
  y <- gsub("([#$%&_])", "\\\\\\1", y) # Doesdn't deal with { or } because of function{}
  y <- gsub("\\^", "\\\\textasciicircum{}", y)
  y <- gsub("~", "\\\\textasciitilde{}", y)
  return(y)
}