
library(shiny)
ui <- fluidPage(
  titlePanel("Online Voting System"),
  
  sidebarLayout(
    sidebarPanel(
      h1("Vote for Your Favorite Collage"),
      radioButtons("candidate", 
                   "Select a candidate:",
                   choices = c("DSU", "BMS", "CMRIT")),
      
      #Vote button
      actionButton("vote", "Submit Vote")
    ),
    
    # Main panel to display vote counts
    mainPanel(
      h3("Vote Counts"),
      tableOutput("voteTable")
    )
  )
)

# Define server logic required to update vote counts
server <- function(input, output, session) {
  
  # Reactive values to store vote counts
  vote_counts <- reactiveValues(DSU = 0, BMS = 0, CMRIT = 0)
  
  observeEvent(input$vote, {
    if (input$candidate == "DSU") {
      vote_counts$DSU <- vote_counts$DSU + 1
    } else if (input$candidate == "BMS") {
      vote_counts$BMS <- vote_counts$BMS + 1
    } else if (input$candidate == "CMRIT") {
      vote_counts$CMRIT <- vote_counts$CMRIT + 1
    }
  })
  
  output$voteTable <- renderTable({
    data.frame(
      Candidate = c("DSU", "BMS", "CMRIT"),
      Votes = c(vote_counts$DSU, vote_counts$BMS, vote_counts$CMRIT)
    )
  })
}
shinyApp(ui = ui, server = server)



