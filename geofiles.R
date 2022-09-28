geofiles <- data.frame(file = list.files("C:/Users/lenovo/Documents/GitHub/gpx_plot/data/"))
geofiles$year <- substr(geofiles$file, 1, 4)
geofiles$month <- substr(geofiles$file, 5, 6)
geofiles$day <- substr(geofiles$file, 7, 8)
geofiles$abr <- substr(geofiles$file, 10, 100)
geofiles$abr <- gsub(".gpx", "", geofiles$abr)
write.csv(geofiles, "geofiles.csv", row.names = FALSE)



geofiles <- read.csv("geofiles.csv")
geodf <- read.csv("geodf.csv")
geofiles_new <- data.frame(file  = unique(geodf$file)[!unique(geodf$file) %in% geofiles$file])
geofiles_new$year <- substr(geofiles_new$file, 1, 4)
geofiles_new$month <- substr(geofiles_new$file, 5, 6)
geofiles_new$day <- substr(geofiles_new$file, 7, 8)
geofiles_new$abr <- substr(geofiles_new$file, 10, 100)
geofiles_new$abr <- gsub(".gpx", "", geofiles_new$abr)
geofiles_new$type <- geofiles_new$subtype <- geofiles_new$country <- geofiles_new$region <- geofiles_new$tags <-rep("x", nrow(geofiles_new))
geofiles_new$type <- c("ski", "walk", rep("ski",4), rep("walk", 4), rep("ski", 8))  # walk - ski - others
# run - hike - climb - ferrata - 
# bike - alpinism - scialpinismo - ski alpino - ski touring - trekking - walk
geofiles_new$subtype <- c("ski touring", "hike", "scialpinismo", "ski touring", "ski alpino", "sci fondo", rep("ferrata", 2), rep("hike", 2), "ski touring", rep("ski alpino", 2), "scialpinismo", rep("ski touring", 4))
geofiles_new$country <- "Italy"#c(rep("Italy", 10))
geofiles_new$region <- "Trentino"#c(rep("Trentino", 3), rep("Brescia", 5), rep("Trentino", 2))
geofiles_new$tags <- "x"
for(i in 1:nrow(geofiles_new)){
  geofiles_new$marker_lat[i] <- mean(geodf$lat[geodf$file == geofiles_new$file[i]])
  geofiles_new$marker_lon[i] <- mean(geodf$lon[geodf$file == geofiles_new$file[i]])
  geofiles_new$marker_popup[i] <- geofiles_new$abr[i]
}
geofiles <- rbind(geofiles, geofiles_new)
write.csv(geofiles, "geofiles.csv", row.names = F)


for(i in 1:nrow(geofiles)){
  if(is.na(geofiles$marker_lat[i])){
    geofiles$marker_lat[i] <- mean(geodf$lat[geodf$file == geofiles$file[i]])
    geofiles$marker_lon[i] <- mean(geodf$lon[geodf$file == geofiles$file[i]])
    geofiles$marker_popup[i] <- geofiles$abr[i]
  }
}
write.csv(geofiles, "geofiles.csv", row.names = F)