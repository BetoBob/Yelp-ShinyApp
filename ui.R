#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)
library(leaflet)

# Define UI for application that draws a histogram
shinyUI(fluidPage(
  
  # Application title
  titlePanel("Leaflet Yelp"),
  
  # Leaflet Stuff
  leafletOutput("mymap"),
  p(),
  actionButton("recalc", "New points")
  )
)
