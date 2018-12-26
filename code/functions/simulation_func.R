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
  #-----------------------------------------------------------------------------
  # 0. The demand forecasts (fcs)
  #-----------------------------------------------------------------------------
  #  - right now just use values from input demand time series
  #  - eventually, would use CO-OP demand models
  #
  demands.fc.df <- forecasts_demands_func(date_sim, demands.daily.df)
   # demand_fc_0_day <- demands_fc[1]
   # demand_fc_9_day <- demands_fc[10]
   #
  #-----------------------------------------------------------------------------
  # 1. Compute today's upstr releases assuming no water supply (ws) needs
  #-----------------------------------------------------------------------------
  # last 2 function inputs are withdr_req & ws_rel_req
  #  - don't need flow fcs yet - assuming normal res wq releases
  #  - there are no withdrawals from Jennings or L Seneca
  #  - assume no ws releases in this step
  #
  ts$sen <- reservoir_ops_today_func(date_sim, 
                                     res = sen, 
                                     res.ts.df = ts$sen, 
                                     withdr_req = 0, 
                                     ws_rel_req = 0)
  ts$jrr <- reservoir_ops_today_func(date_sim, 
                                     res = jrr, 
                                     res.ts.df = ts$jrr, 
                                     withdr_req = 0, 
                                     ws_rel_req = 0)
  #
  sen.ts.df1 <- ts$sen
  jrr.ts.df1 <- ts$jrr
  #-----------------------------------------------------------------------------
  # 2. Do prelim update of flows in potomac.ts.df 
  #    - this adds fc's of today's flows assuming no ws releases
  #-----------------------------------------------------------------------------
  ### Next get the river flow forecasts
   sen_outflow_today <- last(sen.ts.df1$outflow)
   jrr_outflow_today <- last(jrr.ts.df1$outflow)
   need_0day <- 0.0
   ts$flows <- forecasts_flows_func(date_sim, 
                                       demands.fc.df,
                                       sen_outflow_today,
                                       jrr_outflow_today,
                                       need_0day,
                                       ts$flows)
   # Grab some results for use as input in next step
   potomac.ts.df2 <- ts$flows
   lfalls_obs_fc0_no_ws <- last(potomac.ts.df2$lfalls_obs)
   lfalls_obs_fc9_no_ws <- last(potomac.ts.df2$lfalls_obs_fc9)
   #-----------------------------------------------------------------------------
   # 3. Compute today's ws needs
   #-----------------------------------------------------------------------------
   #
   # Compute ws need today - for Seneca release
   #
   ws_need_0day <- estimate_need_func(lfalls_obs_fc0_no_ws,
                                      mos_0day)
   #
   # Compute ws need in 9 days - for N Br release
   #  - add a bit extra for quick and dirty balancing
   # jrr_sen_balance set in global.R
   ws_need_9day <- estimate_need_func(lfalls_obs_fc9_no_ws,
                                      mos_9day + jrr_sen_balance)
   #
   #-----------------------------------------------------------------------------
   # 4. Compute today's reservoir releases, taking into account ws needs
   #-----------------------------------------------------------------------------
   #   There are no withdrawals from Sen or JRR
   #
   ts$sen <- reservoir_ops_today_func(date_sim, 
                                         sen, 
                                         ts$sen, 
                                         0, 
                                         ws_rel_req = ws_need_0day)
   ts$jrr <- reservoir_ops_today_func(date_sim, 
                                         jrr, 
                                         ts$jrr, 
                                         0, 
                                         ws_rel_req = ws_need_9day)
   sen.ts.df4 <- ts$sen
   jrr.ts.df4 <- ts$jrr
   sen_out <- last(sen.ts.df4$outflow)
   jrr_out <- last(jrr.ts.df4$outflow)
   #
   #-----------------------------------------------------------------------------
   # 5. Do final update of flows in potomac.ts.df
   #   -  taking into account possible changes in res releases
   #-----------------------------------------------------------------------------
   ts$flows <- forecasts_flows_func(date_sim, 
                                    demands.fc.df,
                                    sen_out,
                                    jrr_out,
                                    need_0day,
                                    ts$flows)
   #
return(ts)
} # end function
 
