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
library(plotly)

# Example data
data <- data.frame(
  gene_symbol = rep(c("GeneA", "GeneB", "GeneC", "GeneD", "GeneE"), each = 3),
  phenotype = rep(c("Weight", "Images", "Brain"), times = 5),
  score = rnorm(15, mean = 0.5, sd = 0.2)
)

# Define UI
ui <- fluidPage(
  titlePanel("Knockout Gene–Phenotype Association"),
  
  sidebarLayout(
    sidebarPanel(
      helpText("Enter a gene symbol (e.g. GeneA)"),
      textInput("gene_id", "Enter Gene Symbol:", value = ""),
      actionButton("search", "Search")
    ), 
    
    mainPanel(
      h4("Results for Selected Gene"),
      plotlyOutput("scorePlot")
    )
  )
)

# Define Server
server <- function(input, output) {
  observeEvent(input$search, {
    gene_data <- subset(data, gene_symbol == input$gene_id)
    gene_data <- gene_data[order(gene_data$score, decreasing = FALSE), ]
    gene_data$phenotype <- factor(gene_data$phenotype, levels = rev(gene_data$phenotype))  # reverse order
    
    output$scorePlot <- renderPlotly({
      p <- ggplot(gene_data, aes(
        x = phenotype,
        y = score
      )) +
        geom_col(fill = "seagreen3", width = 0.3) +
        coord_flip() +
        labs(
          x = "Phenotype",
          y = "Score"
        ) +
        theme_minimal(base_size = 13) +
        theme(plot.title = element_blank())
      
      ggplotly(p, dynamicTicks = TRUE) %>%
        layout(transition = list(duration = 800))
    })
  })
}
# Run the app
shinyApp(ui = ui, server = server)



