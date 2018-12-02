library(ncdf4)
library(nctools)
library(fields)
library(lubridate)
library(kali)

inputPath = "../BGC/regional/humboldt-n/ROMS-PISCES/Rpsoda"
outputPath = "input/roms-pisces/RPSoda"

gridFile = "roms_grd.nc"

daysPerYear = 365 # days per year
ndays = 5         # saving dt (days)
xlon = c(-100, -70) # PEPS domain
xlat = c(-40, 10) # PEPS domain

.toMonths = function(x, ndays, daysPerYear, months) {
  x = matrix(rep(x, each=ndays), nrow=daysPerYear)
  y = rowsum(x, group=months, reorder=FALSE)/as.numeric(table(months))
  return(as.numeric(y))
}

days = date("2001-01-01") + seq_len(daysPerYear) - 1
months = month(days)

# coordinates

if(!dir.exists(outputPath)) dir.create(outputPath, recursive = TRUE)

ncgrid = nc_open(file.path(inputPath, gridFile))
lon_rho = ncvar_get(ncgrid, "lon_rho")
lat_rho = ncvar_get(ncgrid, "lat_rho")

lon = rowMeans(lon_rho)
lat = colMeans(lat_rho)

# Oxycline depth ----------------------------------------------------------

do2file = "roms6b.oxi_1ml.y1958-2008.rsodi1.nc"

nc = nc_open(file.path(inputPath, do2file))
do2_base = ncvar_get(nc)
xdim = dim(do2_base)
xdim[3] = 12*xdim[3]*ndays/daysPerYear # monthly data

do2 = array(dim=xdim)
for(i in seq_len(xdim[1])) {
  kali::DateStamp("Processing row", i)
  for(j in seq_len(xdim[2])) {
    x = do2_base[i, j, ]
    if(all(is.na(x))) next
    do2[i, j, ] = .toMonths(x, ndays=ndays, 
                            daysPerYear=daysPerYear, months=months)
  }
}

# months since 1950-01-01 # starts in 0
startYear = 1958
time = (startYear - 1950)*12 + seq_len(xdim[3]) - 1

dims = list(lon=lon, lat=lat, time=time)

outputFile = "roms-pisces_RPSoda_do2_peps_1958-2008.nc4"

write_ncdf(x=do2, filename=file.path(outputPath, outputFile), 
           varid = "do2", dim = dims, 
           longname = "depth of the 1mL/L oxygen layer",
           units = "meters", 
           dim.units=c(lon="degrees east", lat="degrees north", 
                       time="months since 1950-01-01"))
