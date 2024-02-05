#source("00_setup.R")
devtools::install_github("anguswg-ucsb/cdssr",quiet = TRUE)
library(cdssr)
library(tidyverse)

grab_DWR_clp_plus <- function(start_dt){

CLP_stations <- get_sw_stations(water_district = 3)
laramie_riv_stations <- get_sw_stations(water_district = 48)
sand_crk_stations <- get_sw_stations(water_district = 76)

#combine all stations
all_stations <- rbind(CLP_stations, laramie_riv_stations, sand_crk_stations)%>%
  mutate(end_year = year(end_date),
         status = case_when(end_year == 2024 ~ "Active",
                            end_year < 2024 ~ "Historical"), 
         start_date = as.Date(start_dt), 
         end_date = as.Date(end_date))

### ------ ALL Stations ------ ####
# Keep hitting daily data limit....

station_abbrev<- all_stations%>%
  filter(status == "Active"& data_source == "DWR") %>%
  select(abbrev, start_date, end_date)%>%
  mutate(parameter = case_when(abbrev %in% c("BOBGLNCO","NEWMERCO")  ~ "DISCHRG1",
                               TRUE ~ "DISCHRG"),
         include_third_party = TRUE)%>%
  filter(abbrev %nin% c("BOBGLNCO","NEWMERCO", "0300907A", "LARNO2CO"))
# #not working : BOBGLNCO,"NEWMERCO", "0300907A", "LARNO2CO"


new_q <- tibble()

for (i in 1:nrow(station_abbrev)){
  telem_ts <- get_telemetry_ts(
    abbrev              = station_abbrev$abbrev[i],
    parameter           = station_abbrev$parameter[i],
    start_date          = station_abbrev$start_date[i],
    end_date            = station_abbrev$end_date[i],
    timescale           = "hour",
    include_third_party = TRUE
  )
  all_q <- bind_rows(all_q, telem_ts)
}

saveRDS(all_q, "data/historical_dwr/hist_clp_run8.RDS")


}