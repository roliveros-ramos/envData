require(ncdf4)
require(kali)
require(nctools)

inputDir = "input/oi_sst"
dx = dy = 1/4
xlon = lon + c(-1, +1)*dx
xlat = lat + c(-1, +1)*dy

varid = "sst"

files = dir(path=inputDir, patt="\\.[0-9]*.nc4$")

dates = range(as.numeric(sapply(strsplit(x=files, split="\\."), 
                  FUN="[", i=2)))

DateStamp("Processing", varid)
output = gsub(x=files[1], patt="\\.([0-9]*)\\.", 
              rep=sprintf(".%s-%s.", dates[1], dates[2]))
out1 = nc_rcat(filenames = file.path(inputDir, files), varid=varid, 
               output=file.path(outputDir, output))
out1 = nc_changePrimeMeridian(filename=out1, 
                                     primeMeridian = findPrimeMeridian(xlon), 
                                     overwrite=TRUE)

DateStamp("Extracting data for", domain)
output = gsub(x=output, patt="v2", rep=paste("v2", domain, sep="-"))
nc_subset(filename=out1, varid=varid, output=file.path(outputDir, output), 
          lat=xlat, lon=xlon)
file.remove(out1)
DateStamp("Done.")

