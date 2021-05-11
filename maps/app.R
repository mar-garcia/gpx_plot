library(shiny)
library(leaflet)
library(RColorBrewer)
library(dplyr)
library(XML)

geodf <- read.csv("geodf.csv")
mycols <- colorRampPalette(brewer.pal(9, "Set1"))(length(unique(geodf$file)))
geodf$color <- NA
maps <- list()
for(i in seq(length(unique(geodf$file)))){
  geodf$color[geodf$file == unique(geodf$file)[i]] <- mycols[i]
  maps[[i]] <- gsub(".gpx", "", unique(geodf$file)[i])
}

ui <- fluidPage(
  sidebarLayout(
    sidebarPanel(
      width = 2,
      checkboxGroupInput("checkMap", label = "Maps", 
                         choices = maps,
                         selected = "tn_a_trentino")),
    mainPanel(leafletOutput("gpxmap", height = 994, width = 1570))
  )
)

server <- shinyServer(function(input, output){
  
  filter_maps <- reactive({
    geodf %>%
      filter(grepl(paste(unlist(input$checkMap), collapse = "|"), file))
  })
  
  output$gpxmap <- renderLeaflet({
    datax <- filter_maps()
    map <- leaflet() %>% 
      addTiles() 
    for(i in seq(length(unique(datax$file)))){
      map <- map %>% 
        addPolylines(data = datax[datax$file == unique(datax$file)[i], ], 
                     lng = ~lon, 
                     lat = ~lat,
                     color = datax$color[datax$file == unique(datax$file)[i]]) 
    } 
    if(length(list.files("todo/")) > 0){
      files <- list.files("todo/")
      geolist <- list()
      for(i in seq(length(files))){
        pfile <- htmlTreeParse(file = paste0("todo/", files[i]), 
                               error = function(...) {}, useInternalNodes = T)
        coords <- xpathSApply(pfile, path = "//trkpt", xmlAttrs)
        geolist[[i]] <- data.frame(lat = as.numeric(coords["lat",]), 
                                   lon = as.numeric(coords["lon",]),
                                   file = files[i])
      }
      geodfx <- geolist[[1]]
      for(i in 2:length(geolist)){
        geodfx <- rbind(geodfx, geolist[[i]])
      }
      for(i in seq(length(unique(geodfx$file)))){
        map <- map %>% 
          addPolylines(data = geodfx[geodfx$file == unique(geodfx$file)[i], ], 
                       lng = ~lon, 
                       lat = ~lat,
                       color = "black") 
      } 
    }
    map
  })
}) # close SERVER
shinyApp(ui = ui, server = server)