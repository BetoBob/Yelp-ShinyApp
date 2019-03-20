library(shiny)
library(leaflet)

navbarPage("Yelp Leaflet App",
           
  # Map Panel for Map Stuff
  tabPanel("Map",
    leafletOutput("generalmap"),
    actionButton("recalc", "New points")
  ),
  
  # An Overview of Our Data
  tabPanel("Data",
    DT::dataTableOutput("table")
  ), 
  
  
  tabPanel("About", 
    p("Stuff")
  )
)

