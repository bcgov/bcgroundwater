simpleCap <- function(x) {
  s <- strsplit(gsub("\\s+"," ",x), "\\s|\\(")
  
  s <- sapply(s, function(t) {
    paste(toupper(substring(t, 1, 1)), tolower(substring(t, 2))
          , sep = "", collapse = " ")
    })
  
  gsub("\\s\\s"," \\(",s)
}