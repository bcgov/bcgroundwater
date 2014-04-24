#' converts a string to a string with capitalized first letters
#'
#'<full description>
#' @param x string
#' @export
#' @return string
#' @examples \dontrun{
#' simpleCap(c("HELLO MY NAME IS", "the quick brown fox"))
#'}
simpleCap <- function(x) {
  s <- strsplit(gsub("\\s+"," ",x), "\\s|\\(")
  
  s <- sapply(s, function(t) {
    paste(toupper(substring(t, 1, 1)), tolower(substring(t, 2))
          , sep = "", collapse = " ")
    })
  
  gsub("\\s\\s"," \\(",s)
}