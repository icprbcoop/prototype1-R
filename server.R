#
#------------------------------------------------------------------
# For now, restrict graphs to today + 15:
#------------------------------------------------------------------

shinyServer(function(input, output, session) {
  #
  #-----------------------------------------------------------------
  # Block temporarily pasted into global.R - for ease of debugging
  #-----------------------------------------------------------------

  #-----------------------------------------------------------------
  # End block temporarily pasted into global.R
  #-----------------------------------------------------------------
  #
  ts0 <- list(sen = sen.ts.df0, 
              jrr = jrr.ts.df0, 
              flows = potomac.ts.df0)
  ts <- sim_main_func(date_today0,
                      mos_0day0,
                      mos_1day, 
                      mos_9day, 
                      ts0) 
  #
  # Now make ts reactive, initializing to results from above
  ts <- reactiveValues(flows = ts$flows, 
                       sen = ts$sen, 
                       jrr = ts$jrr,
                       pat = ts$pat,
                       occ = ts$occ,
                       states = ts$states)
  #
  # Allow the user to re-run the simulation 
  #   - say, if end date (aka DREXtoday) changes
  observeEvent(input$run_main, {
    ts <- sim_main_func(input$DREXtoday,
                        input$mos_0day,
                        mos_1day,
                        mos_9day,
                        ts)
  })
  #
  #------------------------------------------------------------------
  # Create the graphs etc to be displayed by the Shiny app
  #------------------------------------------------------------------
#   output$potomacFlows <- renderPlot({
#     potomac.data.df <- potomac.data.df %>%
#       filter(date_time >= input$plot_range[1],
#              date_time <= input$plot_range[2])
#     ggplot(data = potomac.data.df, aes(x = date_time, y = flow_mgd, group = location)) +
#       geom_line(aes(linetype = location, color = location, size = location)) +
#       scale_linetype_manual(values = c("dotted", "dotted", "solid", "solid")) +
#       scale_size_manual(values = c(1, 1, 3, 1)) +
#       scale_color_manual(values = c("blue", "red", "skyblue1", "blue")) # +
# #      geom_point(temp.df, aes(x = date_time,
# #                              y = flow_mgd, group = location))
#   })
  #------------------------------------------------------------------
  # Create graph of Potomac River flows
  #------------------------------------------------------------------
  output$potomacFlows <- renderPlot({
    # Grab ts and prepare for graphing:
    potomac.ts.df <- ts$flows
    #
    potomac.graph.df0 <- left_join(potomac.ts.df, 
                                   potomac.data.df, 
                                   by = "date_time") %>%
      dplyr::select(Date = date_time, 
                    "Little Falls flow" = lfalls_obs, 
                    #                 por_nat = por_nat.x, 
                    "WMA withdrawals" = withdr_pot)
    graph_title <- "Potomac River"
    potomac.graph.df <- potomac.graph.df0 %>%
      gather(key = "Flow", 
             value = "MGD", -Date) 
    
    potomac.graph.df <- potomac.graph.df %>%
      filter(Date >= input$plot_range[1],
             Date <= input$plot_range[2])
    ggplot(data = potomac.graph.df, aes(x = Date, y = MGD, group = Flow)) +
      geom_line(aes(color = Flow, size = Flow)) +
      scale_color_manual(values = c("deepskyblue1", "red")) +
      scale_size_manual(values = c(2, 1)) +
      ggtitle(graph_title) +
      theme(plot.title = element_text(size = 20)) +
      
      theme(axis.title.x = element_blank())
  }) # end renderPlot for output$potomacFlows
  #
  #------------------------------------------------------------------
  # Create graph of storage and releases for each reservoir
  #------------------------------------------------------------------
  output$jrrStorageReleases <- renderPlot({
    graph_title <- "Jennings Randolph"
    jrr.graph <- ts$jrr %>%
#      mutate(storage = stor, outflow = rel) %>%
      select(Date = date_time,
             storage, 
             outflow
      ) %>%
      gather(key = "Legend", 
             value = "MG", -Date) %>%
      filter(Date >= input$plot_range[1],
             Date <= input$plot_range[2])
    ggplot(data = jrr.graph,
           aes(x = Date, y = MG, group = Legend)) +
      geom_line(aes(color = Legend, size = Legend)) +
      scale_color_manual(values = c("lightblue", "blue")) +
      scale_size_manual(values = c(0.5, 1)) +
      ggtitle(graph_title) +
      theme(plot.title = element_text(size = 18)) +
      # face = "bold")) +
      theme(axis.title.x = element_blank(),
            axis.title.y = element_blank()) +
      theme(legend.position = "right", 
            legend.title = element_blank())
  }) # end renderPlot for jrr
  #
  #------------------------------------------------------------------
  output$senStorageReleases <- renderPlot({
    sen.graph <- ts$sen
    graph_title <- "Little Seneca"
    res.graph <- sen.graph %>%
#      mutate(storage = stor, outflow = rel) %>%
      select(date_time, storage, outflow) %>%
      gather(key = "Legend",
             value = "MG", -date_time) %>%
      filter(date_time >= input$plot_range[1],
             date_time <= input$plot_range[2])
    ggplot(data = res.graph,
           aes(x = date_time, y = MG, group = Legend)) +
      geom_line(aes(color = Legend, size = Legend)) +
      scale_color_manual(values = c("lightblue",
                                    "blue")) +
      scale_size_manual(values = c(0.5, 1)) +
      ggtitle(graph_title) +
      theme(plot.title = element_text(size = 18)) +
      theme(axis.title.x = element_blank(),
            axis.title.y = element_blank()) +
      theme(legend.position = "none")
  }) # end renderPlot for sen
#
  #------------------------------------------------------------------
  # Create value boxes to display numerical output
  #------------------------------------------------------------------
  output$por_flow <- renderValueBox({
    por_threshold <- 2000
    por_flow <- 1800
    valueBox(
      value = por_flow,
      subtitle = "Flow at Point of Rocks, cfs (Trigger for daily monitoring is 2000 cfs)",
      color = if (por_flow >= por_threshold) "green" else "yellow"
    )
  }) # end renderValueBox
  #
  output$lfaa_alert <- renderValueBox({
    lfaa_alert_threshold <- 800
    lfaa_alert <- 700
    valueBox(
      value = lfaa_alert,
      subtitle = "Little Falls adjusted flow, MGD (Trigger for LFAA Alert stage is 2 x total WMA withdrawals)",
      color = if (lfaa_alert >= lfaa_alert_threshold)
        "green" else "orange"
    )
  }) # end renderValueBox
  #
  #------------------------------------------------------------------
  # Allow the user to write simulation output time series to files
  #------------------------------------------------------------------
  observeEvent(input$write_ts, {
    write.csv(ts$flows, paste(ts_output, "output_flows.csv"))
    write.csv(ts$sen, paste(ts_output, "output_sen.csv"))
    write.csv(ts$jrr, paste(ts_output, "output_jrr.csv"))
  })
  #
  #------------------------------------------------------------------
  # Temporary output for QAing purposes
  #------------------------------------------------------------------
  output$QA_out <- renderValueBox({
    potomac.df <- ts$flows
    sen.df <- ts$sen
    jrr.df <- ts$jrr
    QA_out <- paste("Min flow at LFalls = ",
                    round(min(potomac.df$lfalls_obs, na.rm = TRUE)),
                    " mgd",
                    "________ Min sen, jrr stor = ",
                    round(min(sen.df$storage, na.rm = TRUE)),
                    " mg, ",
                    round(min(jrr.df$storage, na.rm = TRUE)),
                    " mg")
    valueBox(
      value = tags$p(QA_out, style = "font-size: 60%;"),
      subtitle = NULL,
      color = "blue"
    )
  })
  #------------------------------------------------------------------
  
  }) # end shinyServer function

