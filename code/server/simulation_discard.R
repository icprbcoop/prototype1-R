#------------------------------------------------------------------
#------------------------------------------------------------------
# Simulate CO-OP system operations 
# - this is the "main" code
#------------------------------------------------------------------
#------------------------------------------------------------------
#
#--------------------------------------------------------------------------------
# Define the simulation date range and "todays" date
#--------------------------------------------------------------------------------
# The simulation period is currently defined in global.R. 
#    Might want to add debug code to 
#    verify that this is within the data date range.
# 
date_today <- as.Date("1930-03-15") # later to be reactive
sim_n <- as.numeric(as.POSIXct(date_today) - as.POSIXct(date_start),
                    units = "days")
#
#--------------------------------------------------------------------------------
# Make the reservoir objects and reservoir time series df's
#--------------------------------------------------------------------------------
source("code/server/reservoirs_make.R", local = TRUE) 
#
#--------------------------------------------------------------------------------
# Make the Potomac River flows dataframe
#--------------------------------------------------------------------------------
source("code/server/potomac_flows_init.R", local = TRUE)
#
#--------------------------------------------------------------------------------
# Run daily simulation
#--------------------------------------------------------------------------------
for (i in 1:sim_n) {
   date_sim <- as.Date(date_start + i)
   #
   ### First get the demand forecasts
   #  (eventually will add restrictions so will depend on reservoir storage)
   demands.fc.df <- forecasts_demands_func(date_sim, demands.daily.df)
   # demand_fc_0_day <- demands_fc[1]
   # demand_fc_9_day <- demands_fc[10]
   #
   ### Next get the river flow forecasts
   flows.fc.df <- forecasts_flows_func(date_sim, demands.fc.df,
                                 potomac.data.df)
#   forecasts.river.df <- forecasts_today_func(date_sim, potomac.ts.df)
   sen.ts.df <- reservoir_ops_today_func(sen, sen.ts.df, 0, sen_ws_rel_req)
   jrr.ts.df <- reservoir_ops_today_func(jrr, jrr.ts.df, jrr_withdr_req, jrr_ws_rel_req)
#   potomac.ts.df <- potomac_flow_func()
}
#
# *************************************************
# This is temporary: *************
graph_range <- date_today + 30
# Convert data to "long" format for graphing:
potomac.data.df <- potomac.data.df %>%
  gather(key = "location", 
         value = "flow_mgd", -date_time) %>%
  dplyr::filter(date_time <= date_end)
# dplyr::filter(date_time <= date_today)
# temp.df <- data.frame(date_time = date_today + 9, 
#                       location = "test", 
#                       flow_mgd = 999,
#                       stringsAsFactors = FALSE)
# *************************************************

 
