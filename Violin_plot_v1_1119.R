#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    https://shiny.posit.co/
#

library(shiny)
library(ggplot2)

ui <- fluidPage(
  
  titlePanel("Gene cluster"),
  
  mainPanel(
    plotOutput("violinPlot", width = "2000px", height = "3000px")   # tall enough to scroll
  )
)

server <- function(input, output) {
  
  output$violinPlot <- renderPlot({
    ggplot(IMPC_analysis, aes(x = parameter_name, y = pvalue)) +
      geom_violin() +
      geom_point() +
      facet_wrap(~ parameter_name, ncol = 10, scales = "free_x") +
      theme(axis.text.x = element_blank(),
            axis.ticks.x = element_blank())
  })
}

shinyApp(ui = ui, server = server)