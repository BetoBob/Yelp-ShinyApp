library(shiny)
library(shinyWidgets)
library(leaflet)
library(jsonlite)
library(tidyverse)

# Data Handling

Yelp_SLO <- as.data.frame(fromJSON("data/businesses_SLO.json")) %>%
  filter(!businesses.is_closed)

categories <- Yelp_SLO %>% 
  select(businesses.id, businesses.categories) %>%
  unnest() %>% 
  select(title) %>%
  rbind("All") %>%
  unique() %>% 
  arrange(title)

max_reviews <- Yelp_SLO %>% select(businesses.review_count) %>% max()  

# UI

navbarPage("Yelp Leaflet App",
           
  # Map Panel for Map Stuff
  tabPanel("Map",
    
    # display general map
    leafletOutput("generalmap"),
    p(),
    
    # select category
    selectizeInput("category", "Search By Category", categories, selected = "All", multiple = FALSE, options = NULL),
    
    # slide for price range
    sliderTextInput("price","Select Price" , 
                    choices = c("0", "$", "$$", "$$$", "$$$$"), 
                                animate = FALSE, grid = FALSE, 
                                hide_min_max = FALSE, from_fixed = FALSE,
                                to_fixed = FALSE, from_min = NULL, from_max = NULL, to_min = NULL,
                                to_max = NULL, force_edges = FALSE, width = NULL, pre = NULL,
                                post = NULL, dragRange = TRUE),
    
    # range of review counts
    sliderInput("review_counts", "Review Counts",
                min = 1, max = 1000,
                value = c(1, 1000)),
    
    # range of review counts
    sliderInput("review_number", "Review Score",
                min = 1, max = 5,
                value = c(1, max_reviews)), 
    
    # checkbox for clustering
    checkboxInput("cluster", "Enable Clustering", FALSE)
  ),
  
  # An Overview of Our Data
  tabPanel("Data",
    dataTableOutput("table")
  ), 
  
  
  tabPanel("About", 
    p("Stuff")
  )
)

