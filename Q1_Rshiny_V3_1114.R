# Example data
data <- data.frame(
  gene_ID = rep(c("2153608", "3607787", "1922928", "1928486", "88289"), each = 3),
  gene_symbol = rep(c("Ube2j2", "Spata21", "Actr3b", "Tdo2", "Pld3"), each = 3),
  phenotype = rep(c("Lower Urinary Tract", "Large Intestine", "White Adipose Tissue"), times = 5),
  score = rnorm(15, mean = 0.5, sd = 0.2)
)




library(shiny)
library(ggplot2)
library(plotly)

# Define User Interface
ui <- fluidPage(
  titlePanel("IMPC Gene Impact Viewer"),
  helpText("Tool for search IMPC Phenotypes-gene relation"),
  helpText("Please use only ONE search box at a time"),
  
  sidebarLayout(
    
    sidebarPanel(
      textInput("text_search", "Enter GeneID:", value = ""),
      helpText("Search by GeneID (e.g. MGI:2153608)"),
      
      selectizeInput(
        "gene_search",
        "Enter Gene Symbol:",
        choices = IMPC_analysis$gene_symbol,   
        options = list(
          placeholder = "Type a gene name...",
          maxOptions = 15
        )
      ),
      helpText("Search by Gene Symbol (e.g. Ube2j2)"),
      
      actionButton("search", "Search")
    ),
    
    mainPanel(
      conditionalPanel(
        condition = "input.search > 0",
        h4("Phenotypes associated with the Selected Gene")
      ),
      plotlyOutput("scorePlot",  height = "2000px", width = "2000px")
    )
    
  )
)

# Define Server
server <- function(input, output, session) {
  
  selected_data <- eventReactive(input$search, {
    
    id  <- input$text_search
    sym <- input$gene_search
    
    # Block double search
    if (nzchar(id) && nzchar(sym)) {
      showNotification("Please use only ONE search box at a time.", type = "error")
      return(NULL)
    }
    
    # Block blank input
    if (!nzchar(id) && !nzchar(sym)) {
      showNotification("Please enter a GeneID OR a Gene Symbol.", type = "error")
      return(NULL)
    }
    
    # Use GeneID
    if (nzchar(id)) {
      subset(IMPC_analysis, mgi_accession_id == id)
    } else {
      subset(IMPC_analysis, gene_symbol == sym)
    }
    
  })   
  
  # Dot_Plot
  output$scorePlot <- renderPlotly({
    
    df <- selected_data()
    req(df)
    
    p <- ggplot(df, aes(
      x = reorder(parameter_name,pvalue,FUN=min, decreasing = TRUE),
      y = pvalue,
      text = paste ("Phenotype:", parameter_name,
                    "<br>p-value:", pvalue)
    )) +
      geom_point(color = "pink", size = 3) +
      geom_hline(
        yintercept = 0.05, 
        linetype = "dashed", 
        colour = "blue"
      ) +
      coord_flip() +
      labs(
        x = "Phenotype",
        y = "p-value",
        title = "Phenotype Significance for Knockout Gene"
      ) +
      theme_minimal() +
      theme(
        plot.title = element_text(hjust = 0.5, size = 20, face = "bold"), 
        axis.title.x = element_text(size = 15, face = "bold"),    
        axis.title.y = element_text(size = 15, face = "bold"),
        axis.text.x = element_text(angle = 90, hjust = 1))
    ggplotly(p, tooltip = "text") 
  }
  )
}
  
# Run app
shinyApp(ui = ui, server = server)