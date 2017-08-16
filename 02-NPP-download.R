library(kali)
library(ncdf4)
library(osmose.fishmip)
source("auxiliar_functions.R")

years = 1980:2015

rawDir = "raw/pp"
outputDir = "input/pp"

for(year in years) {
  # # add try to all functions!
  # DateStamp("Processing year", year)
  # file = download_pp(year=year, output=rawDir) #skip
  # process_pp(file, output=outputDir)
  # cat("File downloaded on", date(), file=logFile)
  
}

