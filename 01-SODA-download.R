library(kali)
library(ncdf4)
library(osmose.fishmip)
source("auxiliar_functions.R")

years = 1980:2015

rawDir = "raw/soda"
outputDir = "input/soda"

for(year in years) {
  # add try to all functions!
  DateStamp("Processing year", year)
  file = download_soda(year=year, output=rawDir)
  process_soda(file, output=outputDir)
  file.remove(file)
  cat("File downloaded on", date(), file=file)
  
}

