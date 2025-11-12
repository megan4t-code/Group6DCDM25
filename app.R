#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    https://shiny.posit.co/
# choose a knock out mouse and show the statistical score all phenotype tested 
# show the statistic score of all knockout mice for a selected phenotype
# clusters of genes with similar phenotyoe scores

# 6 phenotypes 
library(ggplot2)
library(matrixStats)
library(shiny)
library(dplyr)

data <- data.frame(
  gene_symbol = rep(c("GeneA", "GeneB", "GeneC", "GeneD", "GeneE"), each = 3),
  phenotype = rep(c("Weight", "Images", "Brain"), times = 100),
  score = rnorm(300, mean = 0.5, sd = 0.2)
)

# Define UI for application that draws a histogram
ui <- fluidPage(

    # Application title
    titlePanel("mouse phenotype"),

    # Sidebar with a slider input for number of bins 
    sidebarLayout(
      sidebarPanel(
        selectInput(
        inputId = "phenotype",
        label = "Choose a phenotype",
         choices =
         list(
          "Weight", 
          "Images", 
          "Brain",
          "1",
          "2",
          "3"
           )
        )
      ),

        mainPanel(
          textOutput("selected_text"),  # 顯示使用者選擇
          plotOutput("histPlot", height = "500px") #顯示圖片
        )
      )
   )
# Define server logic required to draw a histogram
server <- function(input, output) {
  output$selected_text <- renderText({
    paste("You selected:", input$phenotype)
  })
  
  output$histPlot <- renderPlot({
    filtered <- data %>% filter(phenotype == input$phenotype)
    
    ggplot(filtered, aes(x = score)) +
      geom_histogram(
        bins = 10,               # 直方圖分成幾格
        fill = "steelblue",
        color = "black",
        alpha = 0.7
      ) +
      theme_minimal(base_size = 14) +
      labs(
        title = paste("Distribution of scores for phenotype:", input$phenotype),
        x = "Score",
        y = "Count"
      )
  })
  
  # 也可以在 console 看：
  observe({
    print(paste("Current selection:", input$phenotype))
  })
}
  

# Run the application 
shinyApp(ui = ui, server = server)
fjdkal;
