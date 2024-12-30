library(shiny)
library(DT)

# Create a data frame to hold nominations and votes
nominations <- data.frame(
  Name = character(),
  Reason = character(),
  Votes = numeric(),
  stringsAsFactors = FALSE
)

# Define UI
ui <- fluidPage(
  titlePanel("Employee Recognition and Reward System"),
  
  sidebarLayout(
    sidebarPanel(
      h3("Nominate a Colleague"),
      textInput("name", "Employee Name", ""),
      textAreaInput("reason", "Reason for Recognition", ""),
      actionButton("nominate", "Submit Nomination"),
      br(),
      br(),
      h3("Vote for a Colleague"),
      uiOutput("vote_ui"), # Dynamic voting UI
      actionButton("vote", "Submit Vote")
    ),
    
    mainPanel(
      h3("Current Nominations and Votes"),
      DTOutput("nominations_table") # Table showing nominations and votes
    )
  )
)

# Define server logic
server <- function(input, output, session) {
  
  # Reactive value to store nominations and votes
  rv <- reactiveValues(data = nominations)
  
  # Observe when the nomination is submitted
  observeEvent(input$nominate, {
    if (input$name != "" && input$reason != "") {
      # Check if the nomination already exists
      if (input$name %in% rv$data$Name) {
        showNotification("This employee is already nominated!", type = "error")
      } else {
        # Add new nomination to the data frame
        rv$data <- rbind(rv$data, data.frame(Name = input$name, Reason = input$reason, Votes = 0, stringsAsFactors = FALSE))
        showNotification("Nomination submitted!", type = "message")
      }
    } else {
      showNotification("Please provide a name and reason for nomination.", type = "warning")
    }
  })
  
  # Create a dynamic UI for voting (dropdown with nominees)
  output$vote_ui <- renderUI({
    selectInput("vote_nominee", "Select a Nominee", choices = rv$data$Name)
  })
  
  # Observe when a vote is submitted
  observeEvent(input$vote, {
    if (!is.null(input$vote_nominee)) {
      # Update vote count for the selected nominee
      rv$data$Votes[rv$data$Name == input$vote_nominee] <- rv$data$Votes[rv$data$Name == input$vote_nominee] + 1
      showNotification("Your vote has been submitted!", type = "message")
    } else {
      showNotification("Please select a nominee to vote for.", type = "warning")
    }
  })
  
  # Render the nominations table
  output$nominations_table <- renderDT({
    datatable(rv$data, options = list(pageLength = 5))
  })
}

# Run the application 
shinyApp(ui = ui, server = server)
