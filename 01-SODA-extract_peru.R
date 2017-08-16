require(ncdf4)
require(kali)
require(nctools)

inputDir = "input/soda"
outputDir = "input"
domain = "peru"
dx = dy = 1/2
lat = c(-20, 6) + 2*c(-1, +1)*dy
lon =  360 + c(-93, -70) + 2*c(-1, +1)*dx
vars = c("sst", "sss")

files = dir(path=inputDir)

for(varid in vars) {
  
  DateStamp("Processing", varid)
  output = gsub(x=files[1], patt="2D_[0-9]*", rep=varid)
  out1 = nc_rcat(filenames = file.path(inputDir, files), varid=varid,
                 output=file.path(outputDir, output))
  # out1 = file.path(outputDir, output)
  # modify time
  output = gsub(x=output, patt=varid, rep=paste(varid, domain, sep="_"))
  out2 = nc_subset(filename=out1, varid=varid, output=file.path(outputDir, output), 
            latitude=lat, longitude=lon)
  
  ncdim_rename(out2, old=c("longitude", "latitude"),
               new=c("lon", "lat"))
  
}

