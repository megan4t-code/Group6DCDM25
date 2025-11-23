# IMPC Genotype–Phenotype Viewer (Group 6)
# R version: 4.5.1

# This is a R shiny script for interactive visualisations
# (1) Section "Gene Search" – allows users to select a knockout gene and view p-value profiles across all tested phenotypes, highlighting significant effects
# (2) Section "Parameter Search" – allows users to select a phenotype and view p-value profiles across all tested knockout genes, highlighting significant effects 
# (3) Section "Phenotype Heatmap" – generates a clustered heatmap showing groups of genes with similar phenotype patterns
# Code is generated into labelled blocks: Data, UI, Server, and App Run, comments in this script described the purpose and logic of each section.
# R version 4.5.2 (2025-10-31)
# Last updated: __ (final version for submission)

library(shiny)
library(ggplot2)
library(plotly)
library(dplyr)
library(reshape2)
library(heatmaply)
library(tidyr)
library(viridis)

# ------------------ Data ------------------
clean_data <- read.csv("./clean_input_files/IMPC_analysis.csv", 
                       header = TRUE, sep = ",", stringsAsFactors = FALSE)

cleaned_analysisid <- clean_data %>% group_by(
    gene_symbol,
    mouse_life_stage,
    mouse_strain,
    parameter_id,
    parameter_name
  ) %>% 
  slice_min(order_by = pvalue, n = 1, with_ties = FALSE) %>%
  ungroup()

cleaned_analysisid2 <- cleaned_analysisid %>% group_by(
  mgi_accession_id,
  gene_symbol,
  mouse_life_stage,
  mouse_strain,
  parameter_name
) %>% 
  slice_min(order_by = pvalue, n = 1, with_ties = FALSE) %>%
  ungroup()

# ------------------ UI ------------------
ui <- fluidPage(
  titlePanel("IMPC Mouse Phenotype & Gene Viewer"),
  
  tabsetPanel(
    # ---------------- Tab 1: Gene Search ----------------
    tabPanel("Gene Search",
             sidebarLayout(
               sidebarPanel(
                 textInput("gene_id", "Enter GeneID:", value = ""),
                 selectizeInput("gene_name", "Enter Gene Symbol:", 
                                choices = unique(cleaned_analysisid2$gene_symbol)),
                 actionButton("gene_search", "Search")
               ),
               mainPanel(
                 conditionalPanel(
                   condition = "input.gene_search > 0",
                   h4("Phenotypes associated with the Selected Gene")),
                 plotlyOutput("dotPlot_gene", height = "2000px")
               )
             )
    ),
    
    # ---------------- Tab 2: Parameter Search ----------------
    tabPanel("Parameter Search",
             sidebarLayout(
               sidebarPanel(
                 textInput("param_id", "Enter ParameterID:", value = ""),
                 selectizeInput("param_name", "Enter Parameter Symbol:", 
                                choices = unique(cleaned_analysisid2$parameter_name)),
                 actionButton("param_search", "Search")
               ),
               mainPanel(
                 conditionalPanel(
                   condition = "input.param_search > 0",
                   h4("Selected Gene associated with the Parameter")
                 ),
                 
               plotlyOutput("dotPlot_param", height = "2000px")
               )
             ) 
             ),
    
    # ---------------- Tab 3: Heatmap ----------------
    tabPanel("Phenotype Heatmap",
             mainPanel(
               plotlyOutput("heatmap", height = "1500px", width = "2000px")
             )
             ) 
  )
)

# ------------------ Server ------------------
server <- function(input, output, session) {
  
  # --------------- Gene Search ---------------
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
  
  output$dotPlot_gene <- renderPlotly({
    df <- selected_gene()
    req(df)
    df$text_info <- paste(
      "Phenotype:", df$parameter_name,
      "<br>Parameter ID:", df$parameter_id,
      "<br>Life Stage:", df$mouse_life_stage,
      "<br>Strain:", df$mouse_strain,
      "<br>p-value:", df$pvalue
    )
    p <- ggplot(df, aes(
      x = reorder(parameter_name, pvalue, FUN = min, decreasing = TRUE),
      y = pvalue,
      text = text_info
    )) +
      geom_point(aes(color = mouse_life_stage, shape = mouse_strain), size = 2) +
      scale_shape_manual(
        values = c("C57BL" = 16, "129SV" = 17, "C3H" = 15, "B6J" = 8)
      ) +
      labs(color = "Mouse Life Stage", shape = "Mouse Strain") +
      geom_hline(yintercept = 0.05, linetype = "dashed", color = "royalblue") +
      coord_flip() +
      labs(x = "Phenotype", y = "p-value", title = "Phenotype Significance for Knockout Gene") +
      theme_minimal() +
      theme(plot.title = element_text(hjust = 0.5, size = 20, face = "bold"),
            axis.title.x = element_text(size =15, face = "bold"),
            axis.title.y = element_text(size = 15, face = "bold"),
            axis.text.x = element_text(angle = 90, hjust = -2))
    
    ggplotly(p, tooltip = "text")%>%
      layout(
        legend = list(
          title = list(text = "Mouse Metadata<br>(Mouse strain, Mouse lifestage)") ) )
  })
  
  # --------------- Parameter Search ---------------
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
  
  output$dotPlot_param <- renderPlotly({
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
      geom_point(aes(shape = mouse_strain, color = mouse_life_stage), size = 2) +
      scale_shape_manual(
        values = c("C57BL" = 16, "129SV" = 17, "C3H" = 15, "B6J" = 8)
      )+
      labs(shape = "Mouse Strain", color = "Mouse Life Stage")+
      labs(x = "Gene", y = "p-value") +
      theme_minimal() +
      theme(plot.title = element_text(hjust = 0.5, size = 20, face = "bold"),
            axis.title.x = element_text(size =15, face = "bold"),
            axis.title.y = element_text(size = 15, face = "bold"),
            axis.text.x = element_text(angle = 90, hjust = -2))
    
    ggplotly(p, tooltip = "text")%>%
      layout(
        legend = list(
          title = list(text = "Mouse Metadata<br>(Mouse strain, Mouse lifestage)") ) )
    
  })
  
  # --------------- Heatmap ---------------
  output$heatmap <- renderPlotly({
    collapsed <- cleaned_analysisid2 %>%
      group_by(gene_symbol, parameter_name) %>%
      summarise(pvalue = min(pvalue, na.rm = TRUE), .groups = "drop")
    
    mat <- collapsed %>%
      tidyr::pivot_wider(names_from = parameter_name, values_from = pvalue) %>%
      as.data.frame()
    
    rownames(mat) <- mat$gene_symbol
    mat$gene_symbol <- NULL
    
    mat_num <- as.matrix(mat)
    
    # Custom hover text
    text <- matrix(
      nrow = nrow(mat_num),
      ncol = ncol(mat_num),
      dimnames = list(rownames(mat_num), colnames(mat_num))
    )
    
    for (i in 1:nrow(mat_num)) {
      for (j in 1:ncol(mat_num)) {
        text[i, j] <- paste0(
          "Knockout gene: ", rownames(mat_num)[i], "<br>",
          "Phenotype: ", colnames(mat_num)[j], "<br>",
          "p-value: ", mat_num[i, j]
        )
      }
    }
    
    heatmaply(
      mat_num,
      scale = "none",
      midpoint = 0,
      custom_hovertext = text,
      colors = viridis::magma(256),
      plot_method = "plotly",
      label_names = c("", "", "")
    )
  })
}

# ------------------ Run App ------------------
shinyApp(ui = ui, server = server)