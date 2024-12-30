# Load necessary libraries
library(shiny)

# Define UI
ui <- fluidPage(
  titlePanel("Random Data Generator and Histogram"),
  
  sidebarLayout(
    sidebarPanel(
      sliderInput("num_points", 
                  "Number of Points:", 
                  min = 10, max = 1000, value = 100),
      selectInput("distribution", 
                  "Distribution Type:", 
                  choices = c("Normal", "Uniform", "Exponential"), 
                  selected = "Normal"),
      sliderInput("bins", 
                  "Number of Bins:", 
                  min = 5, max = 50, value = 20)
    ),
    
    mainPanel(
      plotOutput("histPlot"),
      verbatimTextOutput("summary")
    )
  )
)

# Define server logic
server <- function(input, output) {
  # Reactive expression to generate random data
  random_data <- reactive({
    switch(input$distribution,
           "Normal" = rnorm(input$num_points),
           "Uniform" = runif(input$num_points),
           "Exponential" = rexp(input$num_points))
  })
  
  # Render histogram
  output$histPlot <- renderPlot({
    hist(random_data(), 
         breaks = input$bins, 
         col = "skyblue", 
         border = "white", 
         main = paste(input$distribution, "Distribution"),
         xlab = "Value")
  })
  
  # Render summary statistics
  output$summary <- renderPrint({
    summary(random_data())
  })
}

# Run the application
shinyApp(ui = ui, server = server)
