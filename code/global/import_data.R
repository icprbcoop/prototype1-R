#------------------------------------------------------------------------------
#------------------------------------------------------------------------------
# This script imports time series inputs (ts).
# The path to the time series is defined by /config/paths.R
#   and is currently input/ts/daily_test - just 2 years of data.
#------------------------------------------------------------------------------
#------------------------------------------------------------------------------
#
# Import river flow and reservoir inflow ts:
# flows.daily.mgd.df <- data.table::fread(paste(ts_path, "flows_daily_mgd.csv", sep = ""),
#                                       data.table = FALSE) %>%
#   dplyr::mutate(date_time = as.Date(date)) %>%
#   dplyr::select(sim_day, date_time,
#                 jrr_in = jrr,
#                 lsen_in = lsen,
#                 por_nat, below_por, lfalls_nat)
#
flows.df <- data.table::fread(paste(ts_path, "lfalls_nat_daily.csv", sep = ""),
                                        data.table = FALSE) %>%
  dplyr::mutate(date_time = as.Date(date),
                lfalls_nat = flow_daily_mgd) %>%
  dplyr::select(date_time, lfalls_nat)
#
flows.daily.mgd.df <- flows.df
#
flows.df <- data.table::fread(paste(ts_path, "nbr_res_inflow_daily.csv", sep = ""),
                              data.table = FALSE) %>%
  dplyr::mutate(date_time = as.Date(date),
                jrr_in = flow_daily_mgd) %>%
  dplyr::select(date_time, jrr_in)
#
flows.daily.mgd.df <- cbind(flows.daily.mgd.df, jrr_in = flows.df$jrr_in)
#
#
flows.df <- data.table::fread(paste(ts_path, "seneca_res_inflow_daily.csv", sep = ""),
                              data.table = FALSE) %>%
  dplyr::mutate(date_time = as.Date(date),
                sen_in = flow_daily_mgd) %>%
  dplyr::select(date_time, sen_in)
#
flows.daily.mgd.df <- cbind(flows.daily.mgd.df, sen_in = flows.df$sen_in)
#
# Import a time series of total system demands.
# (Later we could create a stochastic demand model like in PRRISM.)
demands.daily.df <- data.table::fread(paste(ts_path, "wma_demand_daily.csv", sep = ""),
                                       data.table = FALSE) %>%
  dplyr::mutate(date_time = as.Date(date_daily),
                demands_total_unrestricted = wma_demand_daily_mgd) %>%
  dplyr::select(date_time, demands_total_unrestricted)

                                        