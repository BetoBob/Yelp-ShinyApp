library(shiny)
library(tidyverse)
library(jsonlite)
library(DT)

# Data Handling 

Yelp_SLO <- as.data.frame(fromJSON("data/businesses_SLO.json"))

categories <- Yelp_SLO %>% 
  select(businesses.id, businesses.categories) %>%
  unnest() 

categories_matrix <- categories %>%
  spread(key = title, value = alias)

categories_map <- data.frame(alias = unique(categories$alias), title = unique(categories$title))

shinyServer(function(input, output) {
  
  check_category <- function(id, category) {
    !categories_matrix %>%
      filter(businesses.id == id) %>%
      select(category) %>% 
      is.na()
  }
  
  update_data <- function() {
    
    update <- Yelp_SLO
      
    if(input$price != 0) {
      update <- update %>%
        filter(businesses.price == input$price)
    }
    
    if(input$category != "All") {
      update <- update %>% 
        filter(sapply(businesses.id, check_category, category = "American (Traditional)"))
    }
    
    update
  }
  
  # method for printing the main map
  output$generalmap <- renderLeaflet({
    leaflet(data = update_data(), options = leafletOptions(minZoom = 10, maxZoom = 20)) %>%
      addMarkers(~longitude, ~latitude, popup = ~as.character(businesses.name), icon = list(iconUrl = "img/red-map-marker.png", iconSize = c(25, 25))) %>%
      setView(Yelp_SLO$region.center.longitude[1], Yelp_SLO$region.center.latitude[1], zoom = 12) %>%
      setMaxBounds(Yelp_SLO$region.center.longitude[1] - 0.25,
                   Yelp_SLO$region.center.latitude[1] - 0.25, 
                   Yelp_SLO$region.center.longitude[1] + 0.25, 
                   Yelp_SLO$region.center.latitude[1] + 0.25) %>%
      addTiles()
  })
  
  output$table <- DT::renderDataTable({
    Yelp_SLO
  })
  
})
