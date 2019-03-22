library(shiny)
library(tidyverse)
library(jsonlite)
library(DT)

# Data Handling 

Yelp_SLO <- as.data.frame(fromJSON("data/businesses_SLO.json")) %>%
  filter(!businesses.is_closed)

categories <- Yelp_SLO %>% 
  select(businesses.id, businesses.categories) %>%
  unnest() 

categories_matrix <- categories %>%
  spread(key = title, value = alias)

categories_map <- data.frame(alias = unique(categories$alias), title = unique(categories$title))

last_category <- "All"

shinyServer(function(input, output) {
  
  check_category <- function(id, category) {
    !categories_matrix %>%
      filter(businesses.id == id) %>%
      select(category) %>% 
      is.na()
  }
  
  update_data <- function() {
    
    Yelp_update <- Yelp_SLO
    
    # filter by price
    if(input$price != 0) {
      Yelp_update <- Yelp_update %>%
        filter(businesses.price == input$price)
    }
    
    # filter by category
    if(input$category != "All" & (input$category != last_category)) {
      Yelp_update <- Yelp_update %>% 
        filter(sapply(businesses.id, check_category, category = "American (Traditional)"))
    }
    
    assign("last_category", input$category, envir = .GlobalEnv)
    
    # filter by review count / review number
    Yelp_update %>% 
      filter(businesses.review_count >= input$review_counts[1] & businesses.review_count <= input$review_counts[2]) %>%
      filter(businesses.rating >= input$review_number[1] & businesses.rating <= input$review_number[2])
  }
  
  # method for printing the main map
  output$generalmap <- renderLeaflet({
    
    popupContent <- ~paste0("<a href='",businesses.url,"'>", businesses.name, "</a></b><br>",
                            address, "<br>",
                            "Price: ", businesses.price, "<br>",
                            "Rating: ", businesses.rating, "<br>",
                            '<img src="', businesses.image_url,'"width="200" height="200">'
        
    )
    
    leaflet(data = update_data(), options = leafletOptions(minZoom = 10, maxZoom = 20)) %>%
      addMarkers(~longitude, ~latitude, popup = popupContent, icon = list(iconUrl = "img/red-map-marker.png", iconSize = c(25, 25))) %>%
      setView(Yelp_SLO$region.center.longitude[1], Yelp_SLO$region.center.latitude[1], zoom = 12) %>%
      setMaxBounds(Yelp_SLO$region.center.longitude[1] - 0.25,
                   Yelp_SLO$region.center.latitude[1] - 0.25, 
                   Yelp_SLO$region.center.longitude[1] + 0.25, 
                   Yelp_SLO$region.center.latitude[1] + 0.25) %>%
      addTiles()
  })
  
  output$table <- DT::renderDataTable({
    update_data() %>%
      select(
        Name = businesses.name, 
        "Review Count" = businesses.review_count, 
        Rating = businesses.rating, 
        Price = businesses.price, 
        Phone = businesses.display_phone,
        "Street Address" = address
        )
  })
  
})
