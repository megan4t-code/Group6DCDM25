#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    https://shiny.posit.co/
#

# Example data
df <- data.frame(
  gene = paste0("Gene_", 1:20),
  Pheno_A = c(0.12,0.66,0.87,0.45,0.34,0.91,0.55,0.17,0.99,0.41,0.62,0.11,0.74,0.55,0.81,0.33,0.52,0.67,0.91,0.28),
  Pheno_B = c(0.55,0.23,0.33,0.19,0.44,0.52,0.31,0.66,0.21,0.77,0.41,0.56,0.35,0.28,0.12,0.51,0.94,0.21,0.45,0.63),
  Pheno_C = c(0.33,0.91,0.12,0.78,0.29,0.01,0.44,0.89,0.54,0.19,0.48,0.72,0.08,0.92,0.34,0.11,0.44,0.33,0.77,0.41),
  Pheno_D = c(0.91,0.11,0.44,0.67,0.33,0.65,0.22,0.55,0.88,0.34,0.59,0.43,0.88,0.31,0.29,0.44,0.15,0.56,0.08,0.91),
  Pheno_E = c(0.02,0.45,0.67,0.23,0.88,0.32,0.76,0.91,0.41,0.67,0.16,0.27,0.56,0.15,0.98,0.60,0.22,0.44,0.11,0.34),
  Pheno_F = c(0.48,0.78,0.22,0.99,0.52,0.15,0.43,0.12,0.76,0.82,0.18,0.94,0.77,0.32,0.61,0.73,0.11,0.78,0.67,0.15),
  Pheno_G = c(0.61,0.33,0.18,0.56,0.13,0.99,0.12,0.33,0.05,0.54,0.91,0.62,0.14,0.99,0.43,0.22,0.55,0.36,0.44,0.71),
  Pheno_H = c(0.77,0.21,0.51,0.22,0.98,0.21,0.67,0.56,0.15,0.13,0.12,0.52,0.44,0.76,0.32,0.67,0.88,0.47,0.21,0.33),
  Pheno_I = c(0.34,0.09,0.88,0.61,0.76,0.53,0.91,0.44,0.32,0.66,0.88,0.35,0.53,0.48,0.55,0.39,0.31,0.68,0.19,0.52),
  Pheno_J = c(0.12,0.55,0.44,0.39,0.16,0.44,0.88,0.22,0.71,0.42,0.31,0.89,0.12,0.67,0.11,0.15,0.99,0.22,0.87,0.66)
)

mat <- as.matrix(df[, -1])
rownames(mat) <- df$gene


colnames(IMPC_analysis)

install.packages("reshape2")

install.packages('heatmaply')

"heatmaplyOutput" %in% ls("package:shinyHeatmaply")


library(shiny)
library (reshape2)
library(heatmaply)
library(plotly)


ui <- fluidPage(
  titlePanel("Phenotype Profile Heatmap of Knockout Genes"),
  
  mainPanel(
    plotlyOutput("heat", height = "1500px", width = "2000px")   # FIXED: use plotlyOutput and correct ID
  )
)

server <- function(input, output) {
  output$heat <- renderPlotly({
    
    collapsed <- IMPC_analysis %>%
      group_by(gene_symbol, parameter_name) %>%
      summarise(pvalue = min(pvalue, na.rm = TRUE), .groups = "drop")
    
    mat <- collapsed %>%
      tidyr::pivot_wider(
        names_from = parameter_name,
        values_from = pvalue
      ) %>%
      as.data.frame()
    
    rownames(mat) <- mat$gene_symbol
    mat$gene_symbol <- NULL
    
    # Customize Hover label
    mat_num <- as.matrix(mat)
    
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
          "p-value: ", mat_num[i, j]) } }
    
    
    # Generate Heatmap
    heatmaply(
      mat,
      scale = "none",
      midpoint = 0,
      custom_hovertext = text,
      colors = viridis::magma(256),
      # Remove defult hover label
      plot_method = "plotly",      
      label_names = c("", "", "") 
    )
  })
  
}

shinyApp(ui = ui, server = server)