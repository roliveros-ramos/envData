library(kali)
library(ncdf4)
source("auxiliar_functions.R")

years = 1980
output = "raw/soda"

  
for(year in years) {
  
  download_soda(year=year, output=output)
  
}


nc = nc_open("raw/soda/soda3.3.1_mn_ocean_reg_1980.nc")

# just get what you need

depth = ncvar_get(nc, "depth")
lat = ncvar_get(nc, "latitude")
lon = ncvar_get(nc, "longitude")
lon2 = checkLongitude(ncvar_get(nc, "longitude"))
temp = ncvar_get(nc, "temp")

# sst (ºC)
# sbt (ºC)
# iso15 (m)
# tc (m)
# 
# mlt (m) ==
# mls (m) ==
# mlp (m) ==

# sss (psu)

# ssh (m) sea level ==

# surface u (m/s) 
# surface v (m/s)
# 
# taux
# tauy
image.map(lon, lat, temp[,,1,1], border=NA)
image.plot(temp[,,1,1])
