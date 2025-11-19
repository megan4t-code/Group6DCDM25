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
library(plotly)



clean_data <- read.csv("~/Desktop/Data_cleaning_and_management/DCDM_25_26/DCDM_group_coursework/clean_input_files/cleaned_analysis_data.csv", 
                   header = TRUE,   # 第一列是欄位名稱
                   sep = ",",       # CSV 的分隔符號
                   stringsAsFactors = FALSE)  # 不自動轉成 factor

#data <- data.frame(
  #parameter_ID = rep(c("IMPC_CBC_018_001", "IMPC_OFD_011_001", "M-G-P_006_001_026", "M-G-P_007_001_010", "IMPC_GRS_008_001"), each = 3),
  #parameter_symbol = rep(c("Glucose", "Periphery resting time", "Fusion of vertebrae", "center - distance", "Forelimb grip strength measurement mean"), each = 3),
  #gene_symbol = rep(c("Ube2j2", "Necap1", "Spata21", "Ucn3", "Clcc1"),  time = 3),
  #score = rnorm(15, mean = 0.5, sd = 0.2)
#)

# Define UI for application that draws a histogram
ui <- fluidPage(

    # Application title
    titlePanel("mouse phenotype"),

    # Sidebar with a slider input for number of bins 
    sidebarLayout(
      sidebarPanel(
        textInput("text_search", "Enter ParameterID:", value = ""),
        helpText("Search by ParameterID (e.g. IMPC_CBC_018_001)"),
        
        selectizeInput(
          "parameter_search",
          "Enter Parameter Symbol:",
          choices = clean_data$parameter_name,   
          options = list(
            placeholder = "Type a parameter name...",
            maxOptions = 50
          )
        ),
        helpText("Search by Gene Symbol (e.g. Ube2j2)"),
        
        actionButton(inputId = "search", label = "Search")
      ),
        
        mainPanel(
          conditionalPanel(
          condition = "input.search > 0",
          h4("Selected Gene associated with the Parameter")
      ),
      plotlyOutput("scorePlot", height = "500px")
    )
 )
)
# Define server logic required to draw a histogram
server <- function(input, output) {
  #output$selected_text <- renderText({
   # paste("You selected:", input$phenotype)
  #})
  
  filtered_data <- eventReactive(input$search, {
    
    # 如果使用者同時輸入兩個，顯示錯誤並回傳 NULL
    if (nzchar(input$parameter_search) && nzchar(input$text_search)) {
      showNotification("Please enter a ParameterID OR a Parameter Symbol.", type = "error")
      return(NULL)
    }
    
    # 篩選資料
    clean_data %>% filter(
      (input$parameter_search != "" & parameter_name == input$parameter_search) |
        (input$text_search != "" & parameter_id == input$text_search)
    )
  })
  
  
  # dot plot
  output$scorePlot <- renderPlotly({
    df <- filtered_data()
    
    # 如果沒有選擇任何參數就不畫圖
    if(nrow(df) == 0) return(NULL)
    
    p <- ggplot(df, aes(x = gene_symbol, y = pvalue)) +
      geom_point(size = 1, color = "steelblue") +
      theme_minimal(base_size = 7) +
      labs(
        title = paste("Scores for parameter:", input$parameter_search),
        x = "Parameter",
        y = "p-value"
      ) +
      theme(axis.text.x = element_text(angle = 45, hjust = 1))
    
    ggplotly(p)  # 轉成互動式 plotly
  })
  
  # 也可以在 console 看：
  observe({
    print(paste("Current selection:", input$parameter_search, input$text_search))
  })
}
  

# Run the application 
shinyApp(ui = ui, server = server)
