setwd("~/GitHub/gpx_plot")
#file <- "20200510_Sentiero_delle_Glare.gpx"
file <- list.files("tmp/")

geodf <- read.csv("geodf.csv")
geodf <- geodf[!geodf$file %in% file,]
write.csv(geodf, "geodf.csv", row.names = FALSE)
