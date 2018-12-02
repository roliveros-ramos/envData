library(ncdf4)
library(nctools)
library(fields)
library(lubridate)
library(kali)

inputPath = "../BGC/regional/humboldt-n/ROMS-PISCES/vech"
outputPath = "input/roms-pisces/vech"
gridFile = "regional/humboldt-n/roms-pisces_RPSoda_do2_humboldt-n_1958-2008.nc4"

ltlFile = file.path(inputPath, "ROMS-PISCES_historical_ltl-osmose_humboldt-n_15days_1992_2008.nc")

nc = nc_open(ltlFile)
grid = nc_open(gridFile)

lon = ncvar_get(grid, "lon")[-1]
lat = ncvar_get(grid, "lat")[-1]
dx = mean(diff(lon))
dy = mean(diff(lat))

LAT = matrix(lat, ncol=length(lat), nrow=length(lon), byrow=TRUE)
area = as.numeric((111*dy)*(111*cos(LAT*pi/180)*dx))

ltl = ncvar_get(nc)[, , , c(TRUE, FALSE)]/area

if(!dir.exists(outputPath)) dir.create(outputPath, recursive=TRUE)

# months since 1950-01-01 # starts in 0
startYear = 1992
time = (startYear - 1950)*12 + seq_len(dim(ltl)[4]) - 1

dims = list(lon=lon, lat=lat, time=time)

plankton = c("sphy", "lphy", "szoo", "lzoo")
lplankton = c("small phytoplankton", "large phytoplankton",
              "small zooplankton", "large zooplankton")

outputFile = "roms-pisces_vech_%s_peru6_1992-2008.nc4"
longname = "density of %s"

for(i in seq_len(dim(ltl)[3])) {
  
  plk = plankton[i]
  oFile = sprintf(outputFile, plk)
  kali::DateStamp("Processing", oFile)
  write_ncdf(x=ltl[,,i,], filename=file.path(outputPath, oFile), 
             varid = plk, dim = dims, 
             longname = sprintf(longname, lplankton[i]),
             units = "tonnes/km2", 
             dim.units=c(lon="degrees east", lat="degrees north", 
                         time="months since 1950-01-01"))
}

