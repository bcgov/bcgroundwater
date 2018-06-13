# Copyright 2017 Province of British Columbia
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
# http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.

#' A better match.arg especially for checking function inputs
#' 
#' Useful when specifying allowed values for a function argument in a vector in the formals. See examples.
#'
#' @param arg The name of the argument in the parent function
#'
#' @return The value of arg after verifying, or an error
#'
#' @examples \dontrun{
#'   my_fun <- function(my_arg = c("a", "b")) {
#'     my_arg <- arg_match(my_arg)
#'     return(paste("The value is", my_arg))
#'   }
#'   
#'   my_fun("a")
#'   my_fun("b")
#'   my_fun("c")
#'   my_fun()
#'   my_fun(NULL)
#'   my_fun(5)
#' }
arg_match <- function(arg) {
  argname <- as.character(substitute(arg))
  choices <- eval(formals(sys.function(sys.parent()))[[argname]])
  stop_message <- paste0("'", argname, "' must be one of '", 
                         paste(choices, collapse = "', '"), "'")
  
  if (is.null(arg)) 
    stop(stop_message, call. = FALSE)
  if (identical(arg, choices)) 
    return(arg[1L])
  if (length(arg) > 1L || !arg %in% choices) {
    stop(stop_message, call. = FALSE)
  }
  arg
}
