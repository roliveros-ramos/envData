library(nctools)
library(osmose.fishmip)

outputPath = "input"

files = c(sst="input/avhrr-only-v2-peru.198109-201706.nc4",
          sss="input/soda3.3.1_mn_ocean_reg_sss_peru.nc4",
          npp="input/npp-ms.melted-peru.nc4",
          do2="input/peru-oxiclina_198501-201406.nc")

LRmaskFile = "input/grid/grid_humboldt-n_LR.nc4"
HRmaskFile = "input/grid/grid_humboldt-n_HR.nc4"

newLR = readMask(LRmaskFile)
newHR = readMask(HRmaskFile)

for(i in seq_along(files)) {
  DateStamp("Regriding", files[i])
  output = sprintf("peru_HR-%s.nc4", names(files)[i])
  nc_regrid(filename=files[i], varid=names(files)[i], dim=c("lon","lat"),
            new=newHR, output=file.path(outputPath, output))
}


nc_sst = nc_open("input/peru_HR-sst.nc4")
nc_sss = nc_open("input/peru_HR-sss.nc4")
nc_npp = nc_open("input/peru_HR-npp.nc4")
nc_do2 = nc_open("input/peru_HR-do2.nc4")

sst = ncvar_get(nc_sst, "sst")
sss = ncvar_get(nc_sss, "sss")
npp = ncvar_get(nc_npp, "npp")
do2 = ncvar_get(nc_do2, "do2")
lon = ncvar_get(nc_npp, "lon")
lat = ncvar_get(nc_npp, "lat")

image.map(lon, lat, sst[,,12])
image.map(lon, lat, sss[,,6])
image.map(lon, lat, npp[,,5])
image.map(lon, lat, do2[,,16])
