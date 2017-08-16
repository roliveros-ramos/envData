require(ncdf4)
require(fields)
require(kali)
require(R.utils)
require(stringr)
require(lubridate)

# dx  = 1/12
# lat = c(-90,90)  
# lon = c(-180,180) 
# 
# grid = createGridAxes(lat=lat, lon=lon, dx=dx, center=TRUE)
# 
# image.plot(grid$lon, grid$lat, pp)
# image.map(grid$lon, grid$lat, pp)

path = "raw/pp"
output = "input/pp"
files = file.path(path, dir(path=path))

ppVar = "npp"
na.name = "Hole Value"
reverse = TRUE
verbose =  TRUE
compression=9

for(file in files) {

  cat(sprintf("Processing file %s...\n", file))
  # check default parameters
  
  tempDir = tempdir()
  xfiles = untar(file, list = TRUE)
  allData = vector(mode="list", length=length(xfiles))
  untar(file, exdir=tempDir)
  
  for(i in seq_along(xfiles)) {
    ifile = xfiles[i]
    tempFile = gunzip(file.path(tempDir, ifile), 
                      remove=FALSE, overwrite=TRUE)
    newFile = gsub(x=tempFile, patt="\\.hdf$",
                   ".h5")
    call = sprintf("h4toh5convert %s %s", tempFile, newFile)
    ocall = system(call, wait=TRUE)
    if(ocall!=0) {
      allData[[i]] = list(var=NULL, att=NULL, file=basename(tempFile))
    }
    nc = nc_open(newFile)
    pp = ncvar_get(nc, ppVar)
    varAtt = ncatt_get(nc, ppVar) 
    pp[pp==varAtt[[na.name]]] = NA
    nc_close(nc)
    if(isTRUE(reverse)) pp = pp[, ncol(pp):1]
    
    allData[[i]] = list(var=pp, att=varAtt, file=basename(tempFile))
    
  }
  
  checkAtts = sapply(allData, y=allData[[1]],
                     FUN = function(x, y) 
                       identical(x$att, y$att))
  
  checkDims = sapply(allData, y=allData[[1]],
                     FUN = function(x, y) 
                       identical(dim(x$var), dim(y$var)))
  
  if(!all(checkAtts)) warning("Attributes don't match!")
  if(!all(checkDims)) stop("Dimensions don't match!")
  
  out = array(dim=c(dim(allData[[1]]$var), length(allData)))
  
  for(i in seq_along(allData)) out[,,i] = allData[[i]]$var
  
  # dx  = 1/12
  lat = allData[[1]]$att$Limit[c(1,3)]  
  lon = allData[[1]]$att$Limit[c(2,4)]
  dx = diff(lon)/dim(allData[[1]]$var)[1]
  dy = diff(lat)/dim(allData[[1]]$var)[2]
  grid = createGridAxes(lat=lat, lon=lon, 
                        dx=dx, dy=dy, center=TRUE)
  
  files = sapply(allData, FUN="[[", i="file")
  dates = str_extract_all(files, patt="[0-9]+")
  dates = sapply(dates, function(x) x[which(nchar(x)==7)])
  year  = as.numeric(substr(dates, 1, 4))
  day   = as.numeric(substr(dates, 5, 7))
  
  dates = as.Date(paste(year, "01", "01", sep="-"))
  yday(dates) = day
  month = month(dates)
  
  ndays = diff(day)
  nday = 365 + leap_year(dates)
  
  time = year + (day-1)/nday
  # time: years since 0000 0:0:0 Gregorian calendar
  
  # day := (time %% 1)*nday + 1
  # span := diff(time)*nday
  # year := floor(time)
  # month := .getMonth()
  
  # create dimensions
  dimLon  = ncdim_def("lon", "degrees east", vals=grid$lon)
  dimLat  = ncdim_def("lat", "degrees north", vals=grid$lat)
  dimTime = ncdim_def("time", "years", time)
  
  # create variables
  units    = allData[[1]]$att[["Units"]] 
  missval  = allData[[1]]$att[[na.name]] 
  longname = "Net primary production"
  prec="float"
  
  NPP   = ncvar_def(name=ppVar, units=units, dim=list(dimLon, dimLat, dimTime), 
                    missval=missval, longname=longname, prec=prec,
                    compression=compression)
  
  fileNew = gsub(x=basename(file), patt="\\.tar$", ".nc4")
  fileNew = file.path(output, fileNew)
  ncNew = nc_create(filename=fileNew, vars=NPP, force_v4=TRUE)
  ncvar_put(ncNew, ppVar, out) 
  nc_close(ncNew)
  
}






