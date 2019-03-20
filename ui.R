library(shiny)
library(leaflet)

Yelp_SLO <- as.data.frame(fromJSON("data/businesses_SLO.json"))

categories <- businesses_SLO %>% 
  select(businesses.id, businesses.categories) %>%
  unnest() %>% 
  select(title) %>%
  rbind("All") %>%
  unique() %>% 
  arrange(title)

navbarPage("Yelp Leaflet App",
           
  # Map Panel for Map Stuff
  tabPanel("Map",
    leafletOutput("generalmap"),
    p(),
    selectizeInput("category", "Search By Category", categories, selected = "All", multiple = FALSE, options = NULL)
  ),
  
  # An Overview of Our Data
  tabPanel("Data",
    DT::dataTableOutput("table")
  ), 
  
  
  tabPanel("About", 
    p("Stuff")
  )
)

