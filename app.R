library(shiny)
library(leaflet)
library(dplyr)

geodf <- read.csv("geodf.csv")
geofiles <- read.csv("geofiles.csv")
geodf <- merge(geodf, geofiles, by = "file")
rm(geofiles)
geodf$color <- c("#DF536B", "#61D04F", "#2297E6", "#28E2E5", 
                 "#CD0BBC", "#F5C710")[factor(geodf$type)]
geodf$type <- factor(geodf$type)
geodf$country <- factor(geodf$country)
geodf$region <- factor(geodf$region)

if(file.exists("geodf_new.csv")){
  new <- read.csv("geodf_new.csv")
}

ui <- navbarPage(
  title = "GPX tracks",
  tabPanel(title = "Map",
           leafletOutput("gpxmap", height = 850),
           absolutePanel(
             id = "controls", top = 60, left = "auto", right = 0,
             checkboxInput("markers", label = "addMarkers", value = F),
             selectInput("type", "Type", 
                         choices = levels(geodf$type), 
                         selected = levels(geodf$type), 
                         multiple = TRUE),
             selectInput("country", "Country",
                         choices = levels(geodf$country),
                         selected = c("Italy", "Others"), #levels(geodf$country), #
                         multiple = TRUE),
             selectInput("region", "Region",
                         choices = levels(geodf$region),
                         selected = c("Trentino", "Sud Tirolo",
                                      "Lombardia", "Veneto", "Austria"), #levels(geodf$region),#
                         multiple = TRUE)
           ) # close absolutePanel-controls
  ), # close tabPanel-Map
  tabPanel(title = "Data"), # close tabPanel-Data
  tabPanel(title = "Stats") # close tabPanel-Stats
) # close UI

server <- shinyServer(function(input, output){
  
  filter_type <- reactive({
    geodf %>%
      filter(grepl(paste(input$type, collapse = "|"), type))
  })
  
  filter_country <- reactive({
    filter_type() %>%
      filter(grepl(paste(input$country, collapse = "|"), country))
  })
  
  filter_region <- reactive({
    filter_country() %>%
      filter(grepl(paste(input$region, collapse = "|"), region))
  })
  
  output$gpxmap <- renderLeaflet({
    datax <- filter_region()
    map <- leaflet(datax) %>% 
      addTiles()
    for(i in seq(length(unique(datax$file)))){
      map <- map %>% 
        addPolylines(data = datax[datax$file == unique(datax$file)[i], ], 
                     lng = ~lon, 
                     lat = ~lat,
                     color = datax$color[datax$file == unique(datax$file)[i]][1]) 
    } # close file "i"
    if(file.exists("geodf_new.csv")){
      for(i in unique(new$file)){
        map <- map %>%
          addPolylines(data = new[new$file == i, ],
                       lng = ~lon,
                       lat = ~lat,
                       color = "black")
      }}
    if(input$markers){
      mrks <- datax[!duplicated(datax$file),]
      mrks <- mrks[!duplicated(mrks$marker_popup), ]
      map <- map %>%
        addMarkers(data = mrks, lat = ~marker_lat, lng = ~marker_lon, 
                   popup = ~marker_popup)
    }
    map
  }) # close output$gpxmap
}) # close SERVER

shinyApp(ui = ui, server = server)