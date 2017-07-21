library(kali)
library(ncdf4)
library(osmose.fishmip)

years = 2015:2000
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
salt = ncvar_get(nc, "salt")

# sst (ºC)
sst = temp[,,1,]
# sbt (ºC)
sbt = apply(temp, c(1,2,4), .getBottom)
# iso15 (m)
iso15 = calculateIsoline(temp, depth, ref=15)
# tc (m)
tc = calculateCline(temp, depth)
# mlt (m) ==
mlt = ncvar_get(nc, "mlt")
# mls (m) ==
mls = ncvar_get(nc, "mls")
# mlp (m) ==
mlp = ncvar_get(nc, "mlp")
# sss (psu)
sss = salt[,,1,] 
# ssh (m) sea level ==
ssh = ncvar_get(nc, "ssh")
# surface u (m/s) 
u = ncvar_get(nc, "u")
# surface v (m/s)
v = ncvar_get(nc, "v")
# taux
taux = ncvar_get(nc, "taux")
# tauy
tauy = ncvar_get(nc, "tauy")
