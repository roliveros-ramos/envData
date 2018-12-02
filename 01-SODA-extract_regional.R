require(ncdf4)
require(kali)
require(nctools)
library(lubridate)

inputDir = "input/soda"

dx = dy = 1/2
xlon = lon + c(-1, +1)*dx
xlat = lat + c(-1, +1)*dy

xtime = dmy(apply(expand.grid(15, 1:12, 1980:2015), 1, paste, collapse="-"))
xtime = as.numeric(xtime - ymd("1978-01-01"))
  
vars = c("sst", "sbt", "sss", "mlt")

files = dir(path=inputDir)

DateStamp("Extracting data from SODA v3.3.1")

for(varid in vars) {
  
  DateStamp("Processing", varid)
  globalInput = gsub(x=files[1], patt="2D_[0-9]*", rep=varid)
  globalInput = nc_rcat(filenames = file.path(inputDir, files), varid=varid,
                  output=file.path(outputDir, globalInput))
  tmp = nc_open(globalInput, write=TRUE)
  ncvar_put(tmp, varid="time", vals = xtime)
  nc_close(tmp)
  globalInput = nc_changePrimeMeridian(filename=globalInput, 
                                       primeMeridian = findPrimeMeridian(xlon), 
                                       overwrite=TRUE)
  output = gsub(x=basename(globalInput), patt=varid, rep=paste(varid, domain, sep="_"))
  output = nc_subset(filename=globalInput, varid=varid, 
                   output=file.path(outputDir, output), 
                   latitude=xlat, longitude=xlon)
  file.remove(globalInput)
  nc_rename(filename=output, oldnames=c("longitude", "latitude"),
               newnames=c("lon", "lat"), overwrite=TRUE)
}



