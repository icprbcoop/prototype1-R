#------------------------------------------------------------------
#------------------------------------------------------------------
# This script loads in basic reservoir data, ie capacity, inflow, etc.,
# creates reservoir "objects" (R S4 class type objects) to hold this data,
# and initializes reservoir dataframes with daily time series
#------------------------------------------------------------------
#------------------------------------------------------------------
#
#------------------------------------------------------------------
# Create a dataframe of reservoir inflows
#------------------------------------------------------------------
# (This is not really necessary - maybe get rid of)
#
inflows.df <- flows.daily.mgd.df %>%
  dplyr::select(date_time, jrr_in, sen_in) %>%
  dplyr::filter(date_time <= date_end,
                date_time >= date_start)
#
#------------------------------------------------------------------
# Load the basic reservoir data and inflow time series
#------------------------------------------------------------------
# Later want to read this from /input/parameters/*.R
sen_cap <- 3900.0
sen_stor0 <- 3900.0
sen_flowby <- 1.12
sen_withdr_req <- 0.0
sen_ws_rel_req <- 0.0
sen.inflows.df <- inflows.df %>%
  select(date_time, inflows = sen_in)
#
jrr_cap <- 35400.0 # nbr = jrr wq + jrr ws + savage
jrr_stor0 <- 35400.0
jrr_flowby <- 113.0 # nbr = (120 + 55) cfs = 113 mgd
jrr_withdr_req <- 0.0
jrr_ws_rel_req <- 0.0
jrr.inflows.df <- inflows.df %>%
  select(date_time, inflows = jrr_in)
#
#------------------------------------------------------------------
# Create "reservoir" objects - in the reservoir class:
#------------------------------------------------------------------
sen <- new("Reservoir", name = "Little Seneca Reservoir", 
           capacity = sen_cap,
           stor0 = sen_stor0,
           flowby = sen_flowby,
#           withdr_req = sen_withdr_req,
           inflows = sen.inflows.df)
jrr <- new("Reservoir", name = "Jennings Randolph Reservoir", 
           capacity = jrr_cap,
           stor0 = jrr_stor0,
           flowby = jrr_flowby,
#           withdr_req = jrr_withdr_req,
           inflows = jrr.inflows.df)
#
#------------------------------------------------------------------
# Initialize dataframes that hold the reservoir time series (ts)
#------------------------------------------------------------------
sen.ts.df <- reservoir_ops_init_func(sen, sen_withdr_req, sen_ws_rel_req)
jrr.ts.df <- reservoir_ops_init_func(jrr, jrr_withdr_req, jrr_ws_rel_req)
sen.ts.df0 <- sen.ts.df
jrr.ts.df0 <- jrr.ts.df

