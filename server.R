library(shiny)
library(jsonlite)
library(DT)

shinyServer(function(input, output) {
  
  Yelp_SLO <- as.data.frame(fromJSON("data/businesses_SLO.json")) %>%
    select(Business = businesses.name, businesses.review_count, businesses.categories, businesses.rating, businesses.price)
   
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
  
  output$table <- DT::renderDataTable({
    Yelp_SLO
  })
})
