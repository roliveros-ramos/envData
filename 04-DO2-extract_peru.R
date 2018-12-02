require(ncdf4)
require(kali)
require(nctools)

inputDir = "input/roms-pisces/RPSoda"

dx = dy = 1/6
xlon = lon + c(-1, +1)*dx
xlat = lat + c(-1, +1)*dy

varid = "do2"

file = file.path(inputDir, dir(path=inputDir, patt=".*do2.*.nc4$"))

DateStamp("Extracting data for", domain)
output = gsub(x=basename(file), patt="peps", rep=domain)
nc_subset(filename=file, varid=varid, output=file.path(outputDir, output), 
          lat=xlat, lon=xlon)

DateStamp("Done.")
