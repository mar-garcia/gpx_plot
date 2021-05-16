library(XML)
library(geosphere)
library(rgdal)
library(sp)

files <- list.files("data/", recursive = TRUE)
files <- gsub(".*/", "", files)
geolist <- list()

if(file.exists("geodf.csv")){
  geodf <- read.csv("geodf.csv")
  files <- files[!files %in% geodf$file]
}

for(i in 1:length(files)){
  
  # Parse the GPX file
  pfile <- htmlTreeParse(file = paste0("data/", substr(files[i], 1, 4), 
                                       "/", files[i]), 
                         error = function(...) {}, useInternalNodes = T)
  
  # Get all coordinates
  coords <- xpathSApply(pfile, path = "//trkpt", xmlAttrs)
  if(any(as.numeric(coords[1,])>90)){
    idx <- which(as.numeric(coords[1,])>90)
    coords <- coords[,-idx]
  }
  
  
  # Delete points that have a distance >100m with its consecutive one
  wp <- readOGR(paste0("data/", substr(files[i], 1, 4), 
                       "/", files[i]), layer = "track_points")
  hike.dists <- spDists(wp, segments=TRUE)
  tmp <- cumsum(hike.dists)
  idx <- c()
  for(j in seq(0.1, sum(hike.dists), 0.1)){
    idx <- c(idx, which.min(abs(j - tmp)))
  }
  coords <- coords[,idx]
  
  # Put everything in a dataframe and get rid of old variables
  geolist[[i]] <- data.frame(lat = as.numeric(coords["lat",]), 
                             lon = as.numeric(coords["lon",]),
                             file = files[i])
}
rm(files, pfile, coords, tmp, i, j)
#plot(coords[1,], coords[2,], type = "l")


# Put all information in a data frame
if(file.exists("geodf.csv")){
  for(i in 1:length(geolist)){
    geodf <- rbind(geodf, geolist[[i]])
  }
} else {
  geodf <- geolist[[1]]
  for(i in 2:length(geolist)){
    geodf <- rbind(geodf, geolist[[i]])
  }
}
rm(geolist, i)


write.csv(geodf, "geodf.csv", row.names = FALSE)
