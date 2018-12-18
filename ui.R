# 
# This is the user-interface of a Shiny web application for the 2018 DREX.
# Run the application by clicking 'Run App' above.
#

dashboardPage(skin = "blue",
  dashboardHeader(title = "Prototype1"),
  dashboardSidebar(
    width = 200,
#    sidebarLayout(
#      sidebarPanel(
dateRangeInput("plot_range",
               "Specify plot range",
               start = date_start,
               # start = "1929-10-01",
               #               end = "1930-12-31",
               # start = date_start,
               end = date_end,
               format = "yyyy-mm-dd",
               width = NULL),
dateInput("DREXtoday",
          "Select today's date",
          value = date_today0 ,
          min = "1929-10-02",
          max = "1931-12-31",
          format = "yyyy-mm-dd")
      ),
  dashboardBody(
    fluidRow(
      column(
        width = 10,
        box(
          title = "Potomac River flow",
          width = NULL,
          plotOutput("potomacFlows", height = 250)
          )
        ),
      column(
        width = 2,
        valueBoxOutput("por_flow", width = NULL),
        valueBoxOutput("lfaa_alert", width = NULL)
      )
    ), # end fluidRow with Potomac flows
    fluidRow(
      tabBox(
#        title = "Storage in system reservoirs",
        width = 10,
        # the id lets us use input$tabset1 on the server to find current tab
        tabPanel("Jennings Randolph",
          plotOutput("jrrStorageReleases", height = 250)
          ),
        tabPanel("Little Seneca",
          plotOutput("senStorageReleases", height = 250)
          )
        ),
        box(
          title = "Storage triggers",
          width = 2,
          "voluntary, mandatory")
) # end fluidRow with reservoir storage
) # end dashboardBody
) # end dashboardPage

