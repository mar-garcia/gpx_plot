library(XML)
library(geosphere)

files <- list.files("data/")
geolist <- list()

if(file.exists("geodf.csv")){
  geodf <- read.csv("geodf.csv")
  files <- files[!files %in% geodf$file]
}

for(i in 1:length(files)){
  
  # Parse the GPX file
  pfile <- htmlTreeParse(file = paste0("data/", files[i]), 
                         error = function(...) {}, useInternalNodes = T)
  
  # Get all coordinates
  coords <- xpathSApply(pfile, path = "//trkpt", xmlAttrs)
  if(any(as.numeric(coords[1,])>90)){
    idx <- which(as.numeric(coords[1,])>90)
    coords <- coords[,-idx]
  }
  
  
  # Delete points that have a distance >100m with its consecutive one
  for(j in 1:ncol(coords)){
    tmp <- c()
    if(j < ncol(coords)){
      for(k in (j+1):ncol(coords)){
        tmp <- c(tmp, distm(c(as.numeric(coords["lon", j]), 
                              as.numeric(coords["lat", j])), 
                            c(as.numeric(coords["lon", k]), 
                              as.numeric(coords["lat",k])), 
                            fun = distHaversine))
      }
      if(!is.na(which(tmp > 100)[1])){
        coords <- coords[,c(1:j, ((which(tmp > 100)[1]+j)):ncol(coords))]
      } else {
        coords <- coords[,c(1:j, (which(tmp > 100)[1]+j))]
      }
    }
  }
  
  coords <- coords[, colSums(is.na(coords)) != nrow(coords)]
  
  # Put everything in a dataframe and get rid of old variables
  geolist[[i]] <- data.frame(lat = as.numeric(coords["lat",]), 
                             lon = as.numeric(coords["lon",]),
                             file = files[i])
}
rm(files, pfile, coords, tmp, i, j, k)
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
