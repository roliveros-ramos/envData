library(ncdf4)
library(kali)

output = "input/grid"
fileMask = "mask_global_MR.nc4"
  
file = "input/avhrr-only-v2.198109-201706.nc4"

nc = nc_open(file)
var = ncvar_get(nc, "sst")

mask = var[,,1]/var[,,1]

lat = ncvar_get(nc, "lat")
lon = ncvar_get(nc, "lon")

dimLon  = ncdim_def("lon", "degrees", vals=lon)
dimLat  = ncdim_def("lat", "degrees", vals=lat)

MASK = ncvar_def(name="mask", units="", dim=list(dimLon, dimLat), 
                missval=0, longname="Ocean mask", prec="integer",
                compression=9)

ncNew = nc_create(filename=file.path(output, fileMask), vars=MASK)
ncvar_put(ncNew, MASK, mask) 
nc_close(ncNew)
nc_close(nc)
