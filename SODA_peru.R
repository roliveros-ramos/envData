require(ncdf4)
require(kali)

ncFile = "soda/soda3.3.1_mn_ocean_reg_1980.nc"
nc = nc_open(ncFile)

z = ncvar_get(nc, "z")
lat = ncvar_get(nc, "latitude")
lon = ncvar_get(nc, "longitude")
depth = ncvar_get(nc, "depth")
temp = ncvar_get(nc, "temp")

