library(shiny)
library(jsonlite)
library(DT)

shinyServer(function(input, output) {
  
  # Data Handling 
  
  Yelp_SLO <- as.data.frame(fromJSON("data/businesses_SLO.json"))
  
  categories <- businesses_SLO %>% 
    select(businesses.id, businesses.categories) %>%
    unnest() 
  
  categories_matrix <- categories %>%
    spread(key = alias, value = title)
  
  categories_map <- data.frame(alias = unique(categories$alias), title = unique(categories$title))
   
  points <- eventReactive(input$recalc, {
    cbind(rnorm(40) * 2 + 13, rnorm(40) + 48)
  }, ignoreNULL = FALSE)
  
  output$mymap <- renderLeaflet({
    leaflet() %>%
      addProviderTiles(providers$Stamen.TonerLite,
                       options = providerTileOptions(noWrap = TRUE)
      ) %>%
      addMarkers(data = points())
  })
  
  output$generalmap <- renderLeaflet({
    leaflet(data = Yelp_SLO, options = leafletOptions(minZoom = 10, maxZoom = 20)) %>%
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
