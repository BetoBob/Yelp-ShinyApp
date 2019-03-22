library(shiny)
library(shinyWidgets)
library(leaflet)
library(jsonlite)
library(tidyverse)

Yelp_SLO <- as.data.frame(fromJSON("data/businesses_SLO.json"))

categories <- Yelp_SLO %>% 
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
    selectizeInput("category", "Search By Category", categories, selected = "All", multiple = FALSE, options = NULL),
    
    # slide for price range
    sliderTextInput("price","Select Price Range" , 
                    choices = c("0", "$", "$$", "$$$", "$$$$"), 
                                animate = FALSE, grid = FALSE, 
                                hide_min_max = FALSE, from_fixed = FALSE,
                                to_fixed = FALSE, from_min = NULL, from_max = NULL, to_min = NULL,
                                to_max = NULL, force_edges = FALSE, width = NULL, pre = NULL,
                                post = NULL, dragRange = TRUE),
    
    h3(textOutput("caption"))
  ),
  
  # An Overview of Our Data
  tabPanel("Data",
    DT::dataTableOutput("table")
  ), 
  
  
  tabPanel("About", 
    p("Stuff")
  )
)

