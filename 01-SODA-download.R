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

# vars = c("sst", "sbt", "sss", "mlt")
# files = dir(path=outputDir)
# 
# for(varid in vars) {
#   
#   DateStamp("Processing", varid)
#   output = gsub(x=files[1], patt="2D_[0-9]*", rep=varid)
#   out1 = nc_rcat(filenames = file.path(inputDir, files), varid=varid,
#                  output=file.path("input", output))
#   
# }

