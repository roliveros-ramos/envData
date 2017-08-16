require(ncdf4)
require(kali)
require(nctools)

inputDir = "raw/oxi_pisces"
outputDir = "input"
domain = "peru"
dx = dy = 1/12
mx = 12
lat = c(-20, 6) + mx*c(-1, +1)*dy
lon =  c(-93, -70) + mx*c(-1, +1)*dx

varid = "OXICLINA_MAX"

filename = file.path(inputDir, dir(path=inputDir))

DateStamp("Processing", varid)
# modify time

output = basename(gsub(x=filename, patt="peps", rep="peru"))

out2 = nc_subset(filename=filename, varid=varid, 
                 output=file.path(outputDir, output), 
                 LAT=lat, LON=lon)

out2 = ncdim_rename(out2, old=c("LON", "LAT", "TIME"),
                    new=c("lon", "lat", "time"))

nc = nc_open(out2, write=TRUE)

nc = ncvar_rename(nc, "OXICLINA_MAX", "do2")

nc_close(nc)


