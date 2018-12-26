#--------------------------------------------------------------------------------
#--------------------------------------------------------------------------------
# Define a function that provides the necessary flow forecasts
#--------------------------------------------------------------------------------
#--------------------------------------------------------------------------------
# Inputs
#--------------------------------------------------------------------------------
# date_sim = current date in the simulation
# demands = forecasts of demands from date_sim to date_sim + 14
# data.df = potomac.data.df - wide format
#    this contains natural river flows, trib flows, other?
#--------------------------------------------------------------------------------
# Output
#--------------------------------------------------------------------------------
# Returns a vector of 15 Potomac River flows at Little Falls,
#   beginning with date_sim and ending with 14 days hence.
#--------------------------------------------------------------------------------
#
# date_sim = as.Date("1930-03-15")
# data.df = potomac.data.df
forecasts_flows_func <- function(date_sim00, 
                                 demands.fc.df, 
                                 sen_outflow_today,
                                 jrr_outflow_today,
                                 need_0day,
                                 flows.ts){
  #
  # Trim the flow.ts.df to make sure the last row is yesterday
  flows.ts.df <- data.frame(flows.ts) %>%
    dplyr::filter(date_time < date_sim00)
  #
  # Get the last row of the flows.ts.df, "yesterday", 
  #    and read its values:
  yesterday.df <- tail(flows.ts.df,1)
  yesterday_date <- yesterday.df[1,1] # yesterday's date
  #
  #
  flows.past9 <- tail(flows.ts.df, 9) # from 9 days past to yesterday
  jrr_outflow_lagged_today <- flows.past9$jrr_outflow[1] # Jrr release nine days ago
  # print(paste(date_sim00, yesterday_date, jrr_outflow_lagged_today))
  #  sen_outflow_yesterday <- flows.past9$sen_outflow[9] # sen release yesterday
  #
  # Grab today's flows from potomac.data.df - a placeholder for flow data sources
  #   - but probably should be passing this to the function
  #   - and we also make use of the values passed to the func
  #  newrow.df <- potomac.data.df %>%
  #    dplyr::filter(date_time == date_sim) %>%  
  newrow.df <- subset(potomac.data.df, 
                      date_time == yesterday_date + 1) %>%
    # 
    dplyr::mutate(withdr_pot = demands.fc.df$demands_fc[1],
                  need_0day = need_0day,
                  sen_outflow = sen_outflow_today, # a func input
                  sen_outflow_lagged = sen_outflow_today,
                  jrr_outflow = jrr_outflow_today, # a func input
                  jrr_outflow_lagged = jrr_outflow_lagged_today,
                  lfalls_nat = lfalls_nat*1.0, # somehow int - need num
                  lfalls_adj = lfalls_nat + jrr_outflow_lagged,
                  #----------------------------------------------------------------
                  # The 0-day fc happens here
                  # ie what's where we need it to be today
                  #
                  lfalls_obs_fc0 = lfalls_nat + 
                    jrr_outflow_lagged + 
                    sen_outflow_lagged -
                    withdr_pot,
                  lfalls_obs = lfalls_obs_fc0,
                  #------------------------------------------------------------------------------
                  # The 9-day lfalls observed fc
                  #
                  lfalls_nat_fc9 = 288*exp(0.0009*lfalls_nat),
                  lfalls_nat_fc9 = if_else(lfalls_nat_fc9 <= lfalls_nat,
                                           lfalls_nat_fc9, lfalls_nat*1.0),
                  lfalls_obs_fc9 = lfalls_nat_fc9 +
                    jrr_outflow + sen_flowby -
                    withdr_pot
    ) %>% # end of mutate
    #------------------------------------------------------------------------------
  dplyr::select(date_time, 
                lfalls_nat,  
                lfalls_adj, lfalls_obs, 
                lfalls_obs_fc9, lfalls_obs_fc0,
                sen_outflow, sen_outflow_lagged,
                jrr_outflow, jrr_outflow_lagged,
                need_0day,
                withdr_pot)
  #
  flows.ts <- rbind(flows.ts.df, newrow.df)
  #
  return(flows.ts)
}