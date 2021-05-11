library(XML)
library(geosphere)

files <- list.files("new/")
geolist <- list()

for(i in 1:length(files)){
  
  # Parse the GPX file
  pfile <- htmlTreeParse(file = paste0("new/", files[i]), 
                         error = function(...) {}, useInternalNodes = T)
  
  # Get all coordinates
  coords <- xpathSApply(pfile, path = "//trkpt", xmlAttrs)
  
  # Delete points that have a distance >100m with its consecutive one
  #for(j in 1:ncol(coords)){
  #  tmp <- c()
  #  if(j < ncol(coords)){
  #    for(k in (j+1):ncol(coords)){
  #      tmp <- c(tmp, distm(c(as.numeric(coords["lon", j]), 
  #                            as.numeric(coords["lat", j])), 
  #                          c(as.numeric(coords["lon", k]), 
  #                            as.numeric(coords["lat",k])), 
  #                          fun = distHaversine))
  #    }
      #if(!is.na(which(tmp > 100)[1])){
      #  coords <- coords[,c(1:j, ((which(tmp > 100)[1]+j)):ncol(coords))]
      #} else {
      #  coords <- coords[,c(1:j, (which(tmp > 100)[1]+j))]
      #}
    #}
  #}
  
  coords <- coords[, colSums(is.na(coords)) != nrow(coords)]
  
  # Put everything in a dataframe and get rid of old variables
  geolist[[i]] <- data.frame(lat = as.numeric(coords["lat",]), 
                             lon = as.numeric(coords["lon",]),
                             file = files[i])
}
rm(files, pfile, coords, tmp, i, j, k)


# Put all information in a data frame
geodf <- geolist[[1]]
if(length(geolist) > 1){
  for(i in 2:length(geolist)){
    geodf <- rbind(geodf, geolist[[i]])
  }
  rm(i)
}
rm(geolist)


write.csv(geodf, "geodf_new.csv", row.names = FALSE)
