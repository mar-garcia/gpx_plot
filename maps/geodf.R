library(XML)

files <- list.files("regions/")
geolist <- list()

if(file.exists("geodf.csv")){
  geodf <- read.csv("geodf.csv")
  files <- files[!files %in% geodf$file]
}

for(i in seq(length(files))){
  pfile <- htmlTreeParse(file = paste0("regions/", files[i]), 
                         error = function(...) {}, useInternalNodes = T)
  coords <- xpathSApply(pfile, path = "//trkpt", xmlAttrs)
  geolist[[i]] <- data.frame(lat = as.numeric(coords["lat",]), 
                             lon = as.numeric(coords["lon",]),
                             file = files[i])
}

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

write.csv(geodf, "geodf.csv", row.names = FALSE)
