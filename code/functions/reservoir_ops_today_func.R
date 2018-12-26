#
#
# Define a function that takes a reservoir ops dataframe and
#   adds one row, ie, one day to the time series 
reservoir_ops_today_func <- function(date_sim, res, res.ts.df, 
                                     withdr_req, ws_rel_req){
  #
  # Implement the water balance eq. for s = beginning of period (BOP) storage:
  #   s(i+1) = s(i) + inflow(i) - withdr(i) - outflow(i)
  #   taking into account that withdr = 0 for these prototype1 reservoirs, and
  #   taking into account constraints:
  #       0 <= s <= cap
  #       withdr(i) = withdr_req(i), or = s + inflow if not enough water
  #       spill(i) = excess water, over capacity
  # (Note the loop will write 1 extra row at end with date_time = <NA>)
    cap <- res@capacity
    flowby <- res@flowby
    w_req <- withdr_req
    #
    # Trim the res.ts.df to make sure the last row is yesterday
    res.ts.df <- data.frame(res.ts.df) %>%
      dplyr::filter(date_time < date_sim)
# Get the last row of the res.ts.df, "yesterday", 
    # and read its values:
    yesterday.df <- tail(res.ts.df,1)
    yesterday_date <- yesterday.df[1,1] # yesterday's date
    stor <- yesterday.df[1,2] # yesterday's storage
    inflow <- yesterday.df[1,3] # yesterday's inflow
#    w <- yesterday.df[1,4] # yesterday's  withdrawal from intake in reservoir
    outflow <- yesterday.df[1,5] # yesterday's release over dam
# calculate today's BOP storage
    stor <- stor + inflow - outflow
# calculate the minimum release over the dam
    rel_min <- ifelse(flowby > ws_rel_req, flowby, ws_rel_req)
# calculate a new row, "today", of the res.ops.df:
    newrow.df <- subset(res@inflows, 
                        date_time == yesterday_date + 1) %>%
      mutate(storage = stor,
             inflow = inflows,
             # available for release over dam - high storage conditions
             available = stor + inflow - w_req,
             rel_req = ws_rel_req,
             outflow = case_when(
               # if excess water (over capacity) is greater 
               #    than that needed for release, release it all
               available - cap >= rel_min ~ available - cap, # spill
               available - cap < rel_min & available > rel_min ~ rel_min,
               # simplify last case: available >= 0 since w_req = 0
               available - cap < rel_min & available <= rel_min ~ available
               # available - cap < rel_min & 
               #   available <= rel_min &
               #   available >= 0 ~ available,
               # available - cap < rel_min & 
               #   available <= rel_min &
               #   available < 0 ~ 0
               ),
             withdr = w_req,
             withdr_req = withdr
             # Keep it simple for the prototypes experiment!
             # # The following isn't necessary since withdrawal = 0
             # withdr_req = w_req, # output withdrawal request in the ts
             # #
             # withdr = case_when(stor + inflow >= w_req ~ w_req,
             #               stor + inflow < w_req ~ stor + inflow)
             #   
      ) %>%
      select(date_time, storage, inflow, withdr, outflow, 
             withdr_req, rel_req, available)
    # add the new row, today, to res.ops.df:
    res.ts.df <- rbind(res.ts.df, newrow.df)
  return(res.ts.df)
}