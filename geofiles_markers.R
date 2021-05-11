library(XML)
library(dplyr)
library(leaflet)
geofiles <- read.csv("geofiles.csv")
geofiles <- geofiles[grep("Mezzavia", geofiles$file),]
files <- geofiles$file[1]
geolist <- list()
for(i in 1:length(files)){
  pfile <- htmlTreeParse(file = paste0("data/", files[i]), 
                         error = function(...) {}, useInternalNodes = T)
    coords <- xpathSApply(pfile, path = "//trkpt", xmlAttrs)
    geolist[[i]] <- data.frame(lat = as.numeric(coords["lat",]), 
                               lon = as.numeric(coords["lon",]),
                               file = files[i])
}
geodf <- geolist[[1]]
#for(i in 2:length(geolist)){
#  geodf <- rbind(geodf, geolist[[i]])
#}
map <- leaflet(geodf) %>% 
  addTiles()
for (i in 1:length(unique(geodf$file))) {
  map <- map %>% 
    addPolylines(data = geodf[geodf$file == unique(geodf$file)[i], ], 
                 lng = ~lon, 
                 lat = ~lat,
                 color = geodf$color[geodf$file == unique(geodf$file)[i]][1])
}
map %>%
  addMarkers(lat = 46.0329852, lng = 11.04351261,
             icon = makeIcon("_posts/waypoints/waypoint.png", 100, 100))

             