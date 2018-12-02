library(ncdf4)
library(kali)
library(lubridate)

# to be updated with rnco

# concatenate all years (ncdf)
#   - PEPS domain: seaWIFS + MODIS

algorithms = "vgpm"
sources = c("s", "m")

inputDir = "input/npp/9km"

dx = dy = 1/12
xlon = lon + c(-1, +1)*dx
xlat = lat + c(-1, +1)*dy

ppVar = "npp"
missval  = -9999
longname = "Net primary production"
prec="float"
compression = 9

files = dir(path=inputDir, patt="\\.nc4$")

for(algorithm in algorithms) {
  
  DateStamp("\nProcessing algorithm:", algorithm)
  for(source in sources) {
    DateStamp("\nProcessing data source:", source)
    code = paste(algorithm, source, sep=".")
    ifiles = grep(x=files, patt=code, value = TRUE)
    
    output = list()
    
    for(i in seq_along(ifiles)) {
      pb <- txtProgressBar(style=3)
      setTxtProgressBar(pb, i/length(ifiles))
      nc =  nc_open(file.path(inputDir, ifiles[i]))
      olat = ncvar_get(nc, "lat")
      olon = ncvar_get(nc, "lon")
      ilat = isInside(olat, xlat)
      ilon = isInside(olon, xlon)
      out =  list(npp=ncvar_get(nc, ppVar)[ilon, ilat, ],
                  time=ncvar_get(nc, "time"), 
                  lat=olat[ilat], lon=olon[ilon], 
                  att=ncatt_get(nc, ppVar))
      output[[i]] = out
      nc_close(nc)
    }
    
    time = unlist(lapply(output, FUN="[[", i="time"))
    
    full = array(dim=c(dim(output[[1]]$npp)[1:2], length(time)))
    
    ini = 0
    end = 0
    for(i in seq_along(output)) {
      ini = end + 1
      end = ini + length(output[[i]]$time) - 1
      full[, , ini:end] = output[[i]]$npp
    }
    
    year = floor(time)
    days = time%%1*(365+leap_year(year)) + 1
    dates = as.Date(paste(year, "01", "01", sep="-"))
    yday(dates) = round(days,0)
    month = month(dates)
    
    start = c(year[1], month[1])
    end   = c(tail(year, 1), tail(month,1))
    xtime = createTimeAxis(start, end, center=TRUE)
    btime = year + (month-1)/12
    
    ind = head(xtime$bounds,-1) %in% btime
    
    npp = array(dim=c(dim(full)[1:2], length(xtime$center)))
    npp[,,ind] = full
    
    dimLon  = ncdim_def("lon", "degrees east", vals=output[[1]]$lon)
    dimLat  = ncdim_def("lat", "degrees north", vals=output[[1]]$lat)
    dimTime = ncdim_def("time", "years", xtime$center)
    
    # create variables
    units    = output[[1]]$att$units
    
    NPP   = ncvar_def(name=ppVar, units=units, dim=list(dimLon, dimLat, dimTime), 
                      missval=missval, longname=longname, prec=prec,
                      compression=compression)
    
    fileNew = paste(algorithm, source, domain,  
                    paste(range(year), collapse="-"), 
                    "nc4", sep=".")
    
    fileNew = file.path(outputDir, fileNew)
    ncNew = nc_create(filename=fileNew, vars=NPP, force_v4=TRUE)
    ncvar_put(ncNew, ppVar, npp) 
    nc_close(ncNew)
    
  }
}

