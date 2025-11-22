library(shiny)
library(ggplot2)
library(plotly)
library(dplyr)

clean_data <- read.csv("./clean_input_files/IMPC_analysis.csv", 
                       header = TRUE,   # 第一列是欄位名稱
                       sep = ",",       # CSV 的分隔符號
                       stringsAsFactors = FALSE)  # 不自動轉成 factor
  
cleaned_analysisid <- clean_data %>% group_by(
    #gene_accession_id,
    gene_symbol,
    mouse_life_stage,
    mouse_strain,
    parameter_id,
    parameter_name
  ) %>% 
  slice_min(order_by = pvalue, n = 1, with_ties = FALSE) %>%
  ungroup()

cleaned_analysisid2<- cleaned_analysisid %>% group_by(
  mgi_accession_id,
  gene_symbol,
  mouse_life_stage,
  mouse_strain,
  #parameter_id,
  parameter_name
) %>% 
  slice_min(order_by = pvalue, n = 1, with_ties = FALSE) %>%
  ungroup()

names(clean_data)

ui <- fluidPage(
  titlePanel("IMPC Mouse Phenotype & Gene Viewer"),
  
  tabsetPanel(
    # UI for Panel 1: Gene search
    tabPanel("Gene Search",
             sidebarLayout(
               sidebarPanel(
                 textInput("gene_id", "Enter GeneID:", value = ""),
                 selectizeInput("gene_name", "Enter Gene Symbol:", 
                                choices = unique(  
                                  cleaned_analysisid2$gene_symbol)),
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
                                choices = unique(  
                                  cleaned_analysisid2$parameter_name)),
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
    
    cleaned_analysisid2 %>% filter(
      (input$param_id != "" & parameter_id == input$param_id) |
        (input$param_name != "" & parameter_name == input$param_name)
    )
  })
  
  output$dotPlot <- renderPlotly({
    df <- filtered_param()
    req(df)
    df$text_info <- paste(
      "Gene:", df$gene_symbol,
      "<br>Parameter ID:", df$parameter_id,
      "<br>Life Stage:", df$mouse_life_stage,
      "<br>Strain:", df$mouse_strain,
      "<br>p-value:", df$pvalue
    )
    p <- ggplot(df, aes(x = reorder(gene_symbol, pvalue, FUN = min, decreasing = TRUE), y =pvalue, 
                        text = text_info)) +
      geom_hline(yintercept = 0.05, linetype = "dashed", color = "blue")+
      coord_flip() +
      geom_point(aes(color = mouse_life_stage, shape = mouse_strain), size = 2) +
      theme_minimal() +
      scale_shape_manual(
        values = c(
          "C57BL" = 16,   # Circle
          "129SV" = 17,     # ▲
          "C3H" = 15,     # ■
          "B6J"
        ))+
      labs(
        color = "Mouse Life Stage",
        shape = "Mouse Strain"
      )+
      labs(x = "Gene", y = "p-value") +
      theme(plot.title = element_text(hjust = 0.5, size = 20, face = "bold"),
            axis.title.x = element_text(size =15, face = "bold"),
            axis.title.y = element_text(size = 15, face = "bold"),
            axis.text.x = element_text(angle = 90, hjust = -2))
    
    ggplotly(p, tooltip = "text")
  })
  
  # ----------------- Tab 2: Gene Search -----------------
  # Server-side logic for Gene search: Search gene by ID or name and returns phenotypes associated to it (p-value)
  
  # Select the p-value of  by gene ID or gene name
  # Shows error if both terms are entered
  selected_gene <- eventReactive(input$gene_search, {
    if (nzchar(input$gene_id) && nzchar(input$gene_name)) {
      showNotification("Please enter only one input.", type = "error")
      return(NULL)
    }
    if (nzchar(input$gene_id)) {
      subset(cleaned_analysisid2, gene_accession_id == input$gene_id)
    } else {
      subset(cleaned_analysisid2, gene_symbol == input$gene_name)
    }
  })
  
  
  output$DotPlot <- renderPlotly({
    
    # Retrieves the filtered dataset for the chosen gene
    # Ensure the plot only runs when valid data is avaliable
    df <- selected_gene()
    req(df)
    
    # Provide information to the hover text
    df$text_info <- paste(
      "Phenotype:", df$parameter_name,
      "<br>Parameter ID:", df$parameter_id,
      "<br>Life Stage:", df$mouse_life_stage,
      "<br>Strain:", df$mouse_strain,
      "<br>p-value:", df$pvalue
    )
    
    # Crete a dot plot (ggplot)
    # Puts phenotype in X-axis, reordered to allow the significant association occured first in the dot plot
    # Puts p-values on the Y-axis, and attach the hover text to each points for interactive purpose
    p <- ggplot(df, aes(
      x = reorder(parameter_name, pvalue, FUN = min, decreasing = TRUE),
      y = pvalue,
      text = text_info
    )) +
      
      # Coloring the dot points by life stage and re-shaping them by different mouse strain for visually distinguishing in the dot plot
      geom_point(aes(color = mouse_life_stage, shape = mouse_strain), size = 2) +
      scale_shape_manual(
        values = c(
          "C57BL" = 16,   # Circle
<<<<<<< HEAD
          "129SV" = 17,     # triangle
          "C3H" = 15,     # square
          "B6J"
        ))+
      
      # Create a horizontal dashed line at p=0.05 for easy visulize the significant gene-phenotype associations
=======
          "129SV" = 17,     # ▲
          "C3H" = 15,     # ■
          "B6J" = 8
        ))+
      labs(
        color = "Mouse Life Stage",
        shape = "Mouse Strain"
      )+
>>>>>>> 4176ba3 (Change plot legend with lab)
      geom_hline(yintercept = 0.05, linetype = "dashed", color = "royalblue") +
      
      # Swap the x and y axis, make the phenotype names easier to read 
      coord_flip() +
      
      # Plot lables
      labs(x = "Phenotype", y = "p-value", title = "Phenotype Significance for Knockout Gene") +
      
      # Setting theme
      theme_minimal() +
      theme(
        plot.title = element_text(hjust = 0.5, size = 20, face = "bold"),
        axis.title.x = element_text(size =15, face = "bold"),
        axis.title.y = element_text(size = 15, face = "bold"),
        axis.text.x = element_text(angle = 90, hjust = -2)
        # axis.text.y = element_text(size = 5)
      )
    
    # Convert ggplot into an interactive plot
    ggplotly(p, tooltip = "text")
  })
}

# Launching the Shiny application
shinyApp(ui = ui, server = server)