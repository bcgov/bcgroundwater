# Copyright 2018 Province of British Columbia
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

#' @noRd
#' 
# Render vignettes and keep the md file.
# 
# This function take the quoted name of the vignette with no extension, renders the vignette
# and keeps a .md file in the vignettes directory. The primary purpose here is 
# to render vignettes so they are more easily visible on GitHub.

render_keep_md <- function(vignette_name) {
  
  path_without_extension <- paste0("./vignettes/", vignette_name)

  rmarkdown::render(paste0(path_without_extension, ".Rmd"), clean = FALSE)
  
  ## Remove unused files
  files_to_remove <- paste0(path_without_extension, c(".html", ".utf8.md"))

  lapply(files_to_remove, file.remove)
  
  ## Rename to a more familiar .md file
  file.rename(from = paste0(path_without_extension,".knit.md"),
              to = paste0(path_without_extension,".md")
              )
  
  return(invisible(TRUE))
  }


