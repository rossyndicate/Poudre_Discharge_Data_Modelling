devtools::install_github("anguswg-ucsb/cdssr",quiet = TRUE)
library(cdssr)

# list of packages required for this pipeline
required_pkgs <- c( #data wrangling packages
                    "tidyverse","lubridate","padr","janitor","padr", "broom","arrow","readxl",
                    #spatial packages
                    "sf","terra","nhdplusTools", "tigris","raster", "leaflet","tmap",
                    # plotting
                    "ggpubr","ggthemes","scales","corrplot","gghighlight", "geomtextpath", "ggbeeswarm","plotly", "ggpmisc","flextable",
                    # web scrapping
                    "rjson", "rvest", "dataRetrieval", "httr", "jsonlite",
                    #extra
                    "devtools", "trend", "rmarkdown")

# helper function to install all necessary pacakges
package_installer <- function(x) {
  if (x %in% installed.packages()) {
    print(paste0("{", x ,"} package is already installed."))
  } else {
    install.packages(x)
    print(paste0("{", x ,"} package has been installed."))
  }
}

# map function using base lapply
lapply(required_pkgs, package_installer)


#!/usr/bin/env Rscript

# This is a helper script to run the pipeline.
# Choose how to execute the pipeline below.
# See https://books.ropensci.org/targets/hpc.html
# to learn about your options.

targets::tar_make()
# targets::tar_make_clustermq(workers = 2) # nolint
# targets::tar_make_future(workers = 2) # nolint
