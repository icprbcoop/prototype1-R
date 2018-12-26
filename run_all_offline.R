#******************************************************************
# run_all_offline runs the model outside of Shiny, for QAing purposes
#******************************************************************
# First run global.R, which loads all data, paths, functions
source("global.R", local = TRUE) 
#
# date_today is set in /input/parameters/parameters.R, 
#    but might want to change it
date_today <- as.Date("1930-02-01")
#
  # Run the main simulation to the hard-coded input, date_today
  #    - ts here is the precursor of the set of reactive values
  ts0 <- list(sen = sen.ts.df0, 
              jrr = jrr.ts.df0, 
              flows = potomac.ts.df0)
  ts <- sim_main_func(date_today, 
                      mos_0day,
                      mos_1day,
                      mos_9_day,
                      ts0)
  #
  flows.ts.df <- ts$flows
  #   #
  # Now write some output
  write.csv(ts$flows, paste(ts_output, "offline_flows.csv"))
  write.csv(ts$sen, paste(ts_output, "offline_sen.csv"))
  write.csv(ts$jrr, paste(ts_output, "offline_jrr.csv"))
  #
  # The End