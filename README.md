# GPX plot
This repo contains the codes for reading and plotting gpx tracks with R.

## General comments  
  
  - When running the `app` file, the shiny app locally, which plots the 
  information of the available gpx tracks.  
  - The data of the gpx tracks is located in the file `geodf.csv`.  
    
## Add new tracks  
  
1. Copy the gpx files in the folder `data`.  
2. Rund the code `geodf.R` to add the data of the new tracks in the file `geodf.csv`.  
3. Add the corresponding metadata using the code written in the lines 11-26 of the file `geofiles.R`.  
   
