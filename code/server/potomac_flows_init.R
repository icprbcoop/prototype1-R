#------------------------------------------------------------------
#------------------------------------------------------------------
# Create two dataframes: Potomac River inflow & outflow data
#    and Potomac River simulated flow time series
#------------------------------------------------------------------
#------------------------------------------------------------------
#
#--------------------------------------------------------------------------------
# Create dataframe of the flow data needed to simulate Potomac River flows,
#   ie the "natural" river flows, trib inflows, withdrawals
#--------------------------------------------------------------------------------
potomac.data.df <- flows.daily.mgd.df %>%
#  dplyr:: select(date_time, por_nat, below_por, lfalls_nat) %>%
  dplyr:: select(date_time, lfalls_nat) %>%
  dplyr:: filter(date_time <= date_end,
                 date_time >= date_start)
#
# For the moment need to be careful - didn't add enough demand data
demands.daily.df <- demands.daily.df %>%
  dplyr:: filter(date_time <= date_end,
                 date_time >= date_start)
#
potomac.data.df <- left_join(potomac.data.df, 
                             demands.daily.df,
                             by = "date_time") %>%
#  select(date_time,por_nat, below_por, 
         select(date_time, 
         lfalls_nat, demands_total_unrestricted)
#--------------------------------------------------------------------------------
# Create and initialize dataframe of Potomac simulated flow time series
#--------------------------------------------------------------------------------
potomac.ts.df0 <- potomac.data.df[1,] %>%
  mutate(lfalls_adj = lfalls_nat,
         lfalls_obs_fc9 = 1000,
         lfalls_obs_fc0 = 1000,
         withdr_pot = 300, # delete this later
         sen_outflow = 0.0, # represents reservoir outflow
         sen_outflow_lagged = 0, # one-day lag
         jrr_outflow = 120,
         jrr_outflow_lagged = 120,
         need_0day = 0.0,
         lfalls_obs = lfalls_nat - 400) %>%
  select(date_time,
         lfalls_nat,
         lfalls_adj, lfalls_obs, 
         lfalls_obs_fc9, lfalls_obs_fc0,
         sen_outflow, sen_outflow_lagged,  
         jrr_outflow, jrr_outflow_lagged,
         need_0day,
         withdr_pot)
potomac.ts.df <- potomac.ts.df0
# Make the 9-day flow forecast, using our old empirical eq., also used in PRRISM
#--------------------------------------------------------------------------------
#
