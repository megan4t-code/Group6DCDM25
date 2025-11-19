library(shiny)
library(ggplot2)
library(plotly)
library(dplyr)

clean_data <- read.csv("~/Desktop/Data_cleaning_and_management/DCDM_25_26/DCDM_group_coursework/clean_input_files/IMPC_analysis.csv", 
                       header = TRUE,   # 第一列是欄位名稱
                       sep = ",",       # CSV 的分隔符號
                       stringsAsFactors = FALSE)  # 不自動轉成 factor

ui <- fluidPage(
  titlePanel("IMPC Mouse Phenotype & Gene Viewer"),
  
  tabsetPanel(
    # ----------------------------------
    tabPanel("Gene Search",
             sidebarLayout(
               sidebarPanel(
                 textInput("gene_id", "Enter GeneID:", value = ""),
                 selectizeInput("gene_name", "Enter Gene Symbol:", 
                                choices = unique(clean_data$gene_symbol)),
                 actionButton("gene_search", "Search")
               ),
               mainPanel(
                 conditionalPanel(
                   condition = "input.gene_search > 0",
                   h4("Phenotypes associated with the Selected Gene")
                 ),
                 plotlyOutput("volcanoPlot", height = "2000px")
               )
             )
    ),
    # ----------------------------------
    tabPanel("Parameter Search",
             sidebarLayout(
               sidebarPanel(
                 textInput("param_id", "Enter ParameterID:", value = ""),
                 selectizeInput("param_name", "Enter Parameter Symbol:", 
                                choices = unique(clean_data$parameter_name)),
                 actionButton("param_search", "Search")
               ),
               mainPanel(
                 conditionalPanel(
                   condition = "input.param_search > 0",
                   h4("Selected Gene associated with the Parameter")
                 ),
                 plotlyOutput("dotPlot", height = "2000px")
               )
             )
    )
)
)

server <- function(input, output, session) {
  
  # ----------------- Tab 1: Parameter Search -----------------
  filtered_param <- eventReactive(input$param_search, {
    if (nzchar(input$param_id) && nzchar(input$param_name)) {
      showNotification("Please enter only one input.", type = "error")
      return(NULL)
    }
    clean_data %>% filter(
      (input$param_id != "" & parameter_id == input$param_id) |
        (input$param_name != "" & parameter_name == input$param_name)
    )
  })
  
  output$dotPlot <- renderPlotly({
    df <- filtered_param()
    req(df)
    
    p <- ggplot(df, aes(x = reorder(gene_symbol, pvalue, FUN = min, decreasing = TRUE), y =pvalue, 
                        text = paste("Score:", pvalue, "<br>ID:", parameter_id))) +
      geom_hline(yintercept = 0.05, linetype = "dashed", color = "blue")+
      coord_flip() +
      geom_point(size = 2, color = "forestgreen") +
      theme_minimal() +
      labs(x = "Gene", y = "p-value") +
      theme(plot.title = element_text(hjust = 0.5, size = 20, face = "bold"),
            axis.title.x = element_text(size =15, face = "bold"),
            axis.title.y = element_text(size = 15, face = "bold"),
            axis.text.x = element_text(angle = 90, hjust = -2))
    
    ggplotly(p, tooltip = "text")
  })
  
  # ----------------- Tab 2: Gene Search -----------------
  selected_gene <- eventReactive(input$gene_search, {
    if (nzchar(input$gene_id) && nzchar(input$gene_name)) {
      showNotification("Please enter only one input.", type = "error")
      return(NULL)
    }
    if (nzchar(input$gene_id)) {
      subset(clean_data, mgi_accession_id == input$gene_id)
    } else {
      subset(clean_data, gene_symbol == input$gene_name)
    }
  })
  
  output$volcanoPlot <- renderPlotly({
    df <- selected_gene()
    req(df)
    
    p <- ggplot(df, aes(
      x = reorder(parameter_name, pvalue, FUN = min, decreasing = TRUE),
      y = pvalue,
      text = paste("Phenotype:", parameter_name, "<br>p-value:", pvalue)
    )) +
      geom_point(color = "indianred", size = 2) +
      geom_hline(yintercept = 0.05, linetype = "dashed", color = "royalblue") +
      coord_flip() +
      labs(x = "Phenotype", y = "p-value", title = "Phenotype Significance for Knockout Gene") +
      theme_minimal() +
      theme(
        plot.title = element_text(hjust = 0.5, size = 20, face = "bold"),
        axis.title.x = element_text(size =15, face = "bold"),
        axis.title.y = element_text(size = 15, face = "bold"),
        axis.text.x = element_text(angle = 90, hjust = -2)
        # axis.text.y = element_text(size = 5)
      )
    
    ggplotly(p, tooltip = "text")
  })
}

shinyApp(ui = ui, server = server)