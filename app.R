# Load necessary libraries
library(shiny)
library(ggplot2)
library(dplyr)

# Define UI
ui <- fluidPage(
  titlePanel("Dataset Analyzer"),
  
  sidebarLayout(
    sidebarPanel(
      fileInput("file", "Upload CSV File", 
                accept = c(".csv")),
      uiOutput("selectVars"),
      actionButton("analyze", "Analyze")
    ),
    
    mainPanel(
      tabsetPanel(
        tabPanel("Summary", tableOutput("summary")),
        tabPanel("Visualization", plotOutput("plot"))
      )
    )
  )
)

# Define server logic
server <- function(input, output) {
  # Reactive value to store the dataset
  dataset <- reactiveVal(NULL)
  
  # Load dataset when a file is uploaded
  observeEvent(input$file, {
    req(input$file)
    dataset(read.csv(input$file$datapath))
  })
  
  # Dynamic UI for variable selection
  output$selectVars <- renderUI({
    req(dataset())
    tagList(
      selectInput("x_var", "X-axis Variable", choices = names(dataset()), selected = names(dataset())[1]),
      selectInput("y_var", "Y-axis Variable", choices = names(dataset()), selected = names(dataset())[2]),
      selectInput("group_var", "Group By (Optional)", choices = c("None", names(dataset())), selected = "None")
    )
  })
  
  # Generate summary statistics
  output$summary <- renderTable({
    req(dataset(), input$x_var, input$y_var)
    data <- dataset()
    x <- data[[input$x_var]]
    y <- data[[input$y_var]]
    summary_df <- data.frame(
      Statistic = c("Mean", "Median", "Min", "Max", "Std Dev"),
      X = c(mean(x, na.rm = TRUE), median(x, na.rm = TRUE), min(x, na.rm = TRUE), max(x, na.rm = TRUE), sd(x, na.rm = TRUE)),
      Y = c(mean(y, na.rm = TRUE), median(y, na.rm = TRUE), min(y, na.rm = TRUE), max(y, na.rm = TRUE), sd(y, na.rm = TRUE))
    )
    summary_df
  })
  
  # Generate visualization
  output$plot <- renderPlot({
    req(dataset(), input$x_var, input$y_var)
    data <- dataset()
    
    ggplot(data, aes_string(x = input$x_var, y = input$y_var, color = ifelse(input$group_var == "None", NULL, input$group_var))) +
      geom_point(size = 3, alpha = 0.7) +
      labs(title = paste(input$y_var, "vs", input$x_var), color = input$group_var) +
      theme_minimal()
  })
}

# Run the application
shinyApp(ui = ui, server = server)
