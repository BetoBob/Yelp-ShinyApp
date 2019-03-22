library(shiny)
library(tidyverse)
library(jsonlite)

# Data Handling 

Yelp_SLO <- as.data.frame(fromJSON("data/businesses_SLO.json")) %>%
  filter(!businesses.is_closed)

categories <- Yelp_SLO %>% 
  select(businesses.id, businesses.categories) %>%
  unnest() 

categories_matrix <- categories %>%
  spread(key = title, value = alias)

categories_map <- data.frame(alias = unique(categories$alias), title = unique(categories$title))

shinyServer(function(input, output) {
  
  # method for printing the main map
  output$map <- renderLeaflet({
    
    # main map features
    Yelp_map <- leaflet(data = Yelp_SLO) %>%
      setView(Yelp_SLO$region.center.longitude[1], Yelp_SLO$region.center.latitude[1], zoom = 12) %>% 
      addEasyButton(easyButton(
        icon="fa-crosshairs", title="Locate Me",
        onClick=JS("function(btn, map){ map.locate({setView: true}); }"))) %>%
      addTiles()
    
  })
  
  check_category <- function(id, category) {
    !categories_matrix %>%
      filter(businesses.id == id) %>%
      select(category) %>% 
      is.na()
  }
  
  # update data according to input parameters
  update_data <- function() {

    Yelp_update <- Yelp_SLO
      
    # filter by price
    if(input$price != 0) {
      Yelp_update <- Yelp_update %>%
        filter(businesses.price == input$price)
    }
    
    # filter by category
    if(input$category != "All") {
      Yelp_update <- Yelp_update %>% 
        filter(sapply(businesses.id, check_category, category = input$category))
    }
    
    # filter by review count / review number
    Yelp_update %>% 
      filter(businesses.review_count >= input$review_counts[1] & businesses.review_count <= input$review_counts[2]) %>%
      filter(businesses.rating >= input$review_number[1] & businesses.rating <= input$review_number[2])
  }
  
  updatePopup <- function(){
    popupContent <- "test"
  }
  
  # change markers / clustering mode / heatmap
  observe({

    proxy <- leafletProxy("map", data = update_data()) %>%
      clearMarkerClusters() %>%
      clearMarkers()
    
    popupContent <- ~paste0('<font face = "arial">',"<b><a href='",businesses.url,"'>", businesses.name, "</a></b><br>",
                            address, "<br>",
                            '<b><font color="green">Price: </b>', businesses.price, "</font><br>",
                            '<b><font color="red">Rating: </b>', businesses.rating, '</font><br><br>',
                            '<img src="', businesses.image_url,'"width="200" height="200"></font>'
                            
    )
    
    clearWebGLHeatmap(proxy)
    
    # conditional pin cluster
    if(input$cluster) {
      proxy %>% addMarkers(~longitude, ~latitude, popup = popupContent, clusterOptions = markerClusterOptions()
                              , icon = list(iconUrl = "img/red-map-marker.png", iconSize = c(25, 25)))
    }
    else if(input$heatmap){
      proxy %>%
        addWebGLHeatmap(lng=~longitude, lat=~latitude, size = 1000) 
    } else {
      proxy %>% addMarkers(~longitude, ~latitude, popup = popupContent, icon = list(iconUrl = "img/red-map-marker.png", iconSize = c(25, 25)))
    }
    
  })
  
  # Output Data Table of Selected Businesses

  output$table <- renderDataTable({
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
  
  # Render method for about pages
  
  output$about <- renderUI({
    includeHTML("YelpReport.html")
  })
  
})
