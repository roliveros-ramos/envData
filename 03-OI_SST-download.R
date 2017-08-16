library(ncdf4)
library(fields)
library(lubridate)
library(kali)
library(nctools)

source("auxiliar_functions.R")  

rawDir = "raw/oi_sst"
outputDir = "input/oi_sst"

years = 1981:2017

for(year in years)
  for(month in 1:12) 
    try(get_oisst(year=year, month=month, output=rawDir, allDays = TRUE))

if(!dir.exists(outputDir)) dir.create(outputDir, recursive = TRUE)

files = dir(path=rawDir, patt="\\.[0-9]*.nc4$")

#moving files to input
file.rename(from=file.path(rawDir, files),
            to=file.path(outputDir, files))

