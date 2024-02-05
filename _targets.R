# Created by use_targets().
# Follow the comments below to fill in this target script.
# Then follow the manual to check and run the pipeline:
#   https://books.ropensci.org/targets/walkthrough.html#inspect-the-pipeline

# Load packages required to define the pipeline: ----
library(targets)
library(tarchetypes)
devtools::install_github("anguswg-ucsb/cdssr",quiet = TRUE)

# Set target options: ----
tar_option_set(
  packages = c("tidyverse")
  # need to make sure that we are using all of th
  # packages = c("data.table", "tidyverse", "rvest",
  #              "readxl", "lubridate", "zoo",
  #              "padr","plotly", "feather",
  #              "RcppRoll", "yaml", "ggpubr",
  #              "profvis", "janitor", "HydroVuR") # packages that your targets need to run
  # format = "qs", # Optionally set the default storage format.
  # should this be parquet?
)

# Run the R scripts in the R/ folder with your custom functions: ----
tar_source(files = c(
  "pullers/DWR_pull.R",
  "pullers/USGS_pull.R",
  "pullers/larimer_co_pull.R",
  "cleaners/clean_collate.R"
  
))

list(
  # Pull in the API data -----------------------------------------------

  # accessing the API data ----
  tar_file_read(
    name = hv_creds,
    # to do (j): make sure that credentials are in a separate folder from scripts?
    "src/api_pull/credentials.yml",
    read = read_yaml(!!.x),
    packages = "yaml"
  ),

  # get a token for location lists and data access ----
  tar_target(
    name = hv_token,
    command = hv_auth(client_id = as.character(hv_creds["client"]),
                      client_secret = as.character(hv_creds["secret"]),
                      url = "https://www.hydrovu.com/public-api/oauth/token"),
    packages = c("httr2", "HydroVuR")
  ),

  # get the start times for each site ----

  ## read in the historically flagged data
  tar_file_read(
    name = flagged_data_dfs, # this data is from the RMD files. eventually it will be from this pipeline.
    "data/flagged/all_data_flagged.RDS",
    read = readRDS(!!.x)
  ),


  ## get the start dates for each site
  tar_target(
    name = start_dates_df,
    command = get_start_dates_df(incoming_flagged_data_dfs = flagged_data_dfs),
    packages = "tidyverse"
  ),

  # get the data for each site ----
  tar_target(
    name = incoming_data_csvs_upload, # this is going to have to append to the historical data
    command = walk2(.x = start_dates_df$site,
                    .y = start_dates_df$start_DT_round,
                    ~api_puller(site = .x, start_dt = .y, api_token = hv_token,
                                dump_dir = "data/api/incoming_api_data/")),
    packages = c("tidyverse", "HydroVuR", "httr2")
  ),



  # update the historically flagged data ----
  tar_target(
    name = update_historical_flag_data,
    command = {
      update_historical_flag_data <- update_historical_flag_list(
        new_flagged_data = all_data_flagged,
        historical_flagged_data = flagged_data_dfs
      )
    }
  ),

  # save the updated flagged data ----
  tar_target(
    name = write_flagged_data_RDS,
    command = saveRDS(update_historical_flag_data, "data/flagged/test_all_data_flagged.RDS")
  )

)





