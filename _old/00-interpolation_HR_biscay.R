library(nctools)
library(osmose.fishmip)

outputPath = "input"
domain = "biscay"

files = c(sst="input/avhrr-only-v2-biscay.198109-201706.nc4",
          sss="input/soda3.3.1_mn_ocean_reg_sss_biscay.nc4",
          npp="input/vgpm.m.biscay.2002-2017.nc4")

HRmaskFile = "input/grid/mask_biscay_HR.nc4"

newHR = readMask(HRmaskFile)

for(i in seq_along(files)) {
  DateStamp("Regriding", files[i])
  output = sprintf("%s_HR-%s.nc4", domain, names(files)[i])
  nc_regrid(filename=files[i], varid=names(files)[i], dim=c("lon","lat"),
            new=newHR, output=file.path(outputPath, output))
}


nc_sst = nc_open(sprintf("input/%s_HR-sst.nc4", domain))
nc_sss = nc_open(sprintf("input/%s_HR-sss.nc4", domain))
nc_npp = nc_open(sprintf("input/%s_HR-npp.nc4", domain))
# nc_do2 = nc_open(sprintf("input/%s_HR-do2.nc4", domain))

sst = ncvar_get(nc_sst, "sst")
sss = ncvar_get(nc_sss, "sss")
npp = ncvar_get(nc_npp, "npp")
# do2 = ncvar_get(nc_do2, "do2")
lon = ncvar_get(nc_npp, "lon")
lat = ncvar_get(nc_npp, "lat")

image.map(lon, lat, sst[,,12])
image.map(lon, lat, sss[,,6])
image.map(lon, lat, npp[,,5])
# image.map(lon, lat, do2[,,16])
