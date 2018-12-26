#------------------------------------------------------------------------------
# Info found online:
  # "global.R is a script that is executed before
  # the application launch. For this reason, it can include the same
  # pieces of code to execute the reactive independent processes,
  # but it also has an additional capability: the objects 
  # generated in global.R can be used both in server.R and UI.R"
#------------------------------------------------------------------------------
# The script, import_data.R, load in all available time series data. 
#  Right now the directory with time series data (set by paths.R)
#  has 2 years of data, from 1929-10-01 to 1931-09-30.
# date_tsdata_start <- as.Date("1929-10-01")
# date_tsdata_end <- as.Date("1931-09-30")

source("code/global/load_packages.R", local = TRUE)
source("config/paths.R", local = TRUE)
source("code/global/import_data.R", local = TRUE)
#
#-----------------------------------------------------------------
# Block temporarily pasted into global.R - for ease of debugging
#-----------------------------------------------------------------
# Define the simulation period - later do this reactively:
date_start <- as.Date("1929-10-01")
date_end <- as.Date("1932-12-15")
date_today0 <- as.Date("1931-10-31")
date_plot_start <- as.Date("1930-01-01")
date_plot_end <- as.Date("1931-12-31")

#
mos_0day0 <- 50.0
mos_1day <- 0.0
mos_9day <- 0.0
lfalls_flowby <- 100.0
jrr_sen_balance <- 0.0
#
source("code/classes/reservoir_class.R", local = TRUE)
source("code/functions/reservoir_ops_init_func.R", local = TRUE)
source("code/functions/reservoir_ops_today_func.R", local = TRUE)
source("code/functions/forecasts_demands_func.R", local = TRUE)
source("code/functions/forecasts_flows_func.R", local = TRUE)
source("code/functions/sim_main_func.R", local = TRUE)
source("code/functions/simulation_func.R", local = TRUE)
source("code/functions/estimate_need_func.R", local = TRUE)
source("code/server/potomac_flows_init.R", local = TRUE)
source("code/server/reservoirs_make.R", local = TRUE) 
# source("code/server/potomac_flows.R", local = TRUE)
# source("code/server/simulation.R", local = TRUE)
#-----------------------------------------------------------------
# End block temporarily pasted into global.R
#-----------------------------------------------------------------
#
#------------------------------------------------------------------------------
plot.height <- "340px"
plot.width <- "95%"
#------------------------------------------------------------------------------




