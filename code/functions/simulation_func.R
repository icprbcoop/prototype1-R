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
# date_today <- as.Date("1930-03-15") # later to be reactive
# sim_n <- as.numeric(as.POSIXct(date_today) - as.POSIXct(date_start),
#                     units = "days")
#
# #--------------------------------------------------------------------------------
# # Make the reservoir objects and reservoir time series df's
# #--------------------------------------------------------------------------------
# source("code/server/reservoirs_make.R", local = TRUE) 
# #
# #--------------------------------------------------------------------------------
# # Make the Potomac River flows dataframe
# #--------------------------------------------------------------------------------
# source("code/server/potomac_flows_init.R", local = TRUE)
# #
#--------------------------------------------------------------------------------
# Run daily simulation
#--------------------------------------------------------------------------------
simulation_func <- function(date_sim,
                            mos_0day,
                            mos_1day,
                            mos_9day,
                            demands.daily.df,
                            potomac.daily.df,
                            sen, jrr,
                            ts){
   #
   ### First get the demand forecasts
   #  (eventually will add restrictions so will depend on reservoir storage)
   demands.fc.df <- forecasts_demands_func(date_sim, demands.daily.df)
   # demand_fc_0_day <- demands_fc[1]
   # demand_fc_9_day <- demands_fc[10]
   #
   ### Next get the river flow forecasts
   sen_outflow_today <- 0.0
   jrr_outflow_today <- 120.0
   need_0day <- 0.0
   ts$flows <- forecasts_flows_func(date_sim, 
                                       demands.fc.df,
                                       sen_outflow_today,
                                       jrr_outflow_today,
                                       need_0day,
                                       ts$flows)
#   forecasts.river.df <- forecasts_today_func(date_sim, potomac.ts.df)
   ts$sen <- reservoir_ops_today_func(date_sim, 
                                         sen, 
                                         ts$sen, 
                                         0, 
                                         sen_ws_rel_req)
   ts$jrr <- reservoir_ops_today_func(date_sim, 
                                         jrr, 
                                         ts$jrr, 
                                         jrr_withdr_req, 
                                         jrr_ws_rel_req)
#   potomac.ts.df <- potomac_flow_func()
#   ts$flows <- flows.fc.df
   # ts$sen <- sen.ts.df
   # ts$jrr <- jrr.ts.df
return(ts)
} # end function
 
