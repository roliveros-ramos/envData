
# Generic ncdf auxiliar functions -----------------------------------------


#' Get all variable's attributes from a ncdf object 
#'
#' @param nc An open connection to a netCDF file as in nc_open(file).
#' @param type A character to choose attributes for variables ("var") 
#' or dimensions ("dim").
#' @return A list with all the atributes.
#' @export
#'
#' @examples
ncatt_get_all = function(nc, type=c("var", "dim")) {
  type = match.arg(type)
  vars = names(nc[[type]])
  names(vars) = vars
  atts = lapply(vars, FUN=function(var) ncatt_get(nc, var))
  return(atts)
}

#' Get the dimensions of the variables in a ncdf object.
#'
#' @param nc An open connection to a netCDF file as in nc_open(file).
#'
#' @return A named list with the dimensions of the variables.
#' @export
#'
#' @examples
ncdim_size = function(nc) {
  lapply(nc$dim, function(x) x$len)
}


# get Data ----------------------------------------------------------------

# OI SST
#' Get Optimal Interpolation SST data
#'
#' @param year The year for data extraction.
#' @param month The month for data extraction.
#' @param output The folder to store the results, by default the
#' working directory.
#' @param type The type of variable, currently "avhrr-only".
#' @param server The server to download the data.
#' @param prec The precision of the returned ncdf file.
#' @param compression The level of compresion of the file, default
#' is maximum level (9).
#' @param allDays boolean, keep a file with daily data?
#' @param temp Temporal folder to download daily data. Specify it if
#' you want to keep daily files in a known folder. 
#'
#' @return The function saves in the disk the desired data. The 
#' temporal folder with individual daily files is returned invisibly. 
#' @export
#'
#' @examples
get_oisst = function(year, month, output=NULL, type="avhrr-only",
                         server="https://www.ncei.noaa.gov/data",
                         prec = "float", compression = 9,
                         allDays = FALSE, temp=NULL) {
  
  if(is.null(output)) output = getwd()
  
  var1   = "sea-surface-temperature-optimum-interpolation"
  temp = if(is.null(temp)) tempdir() else temp
  prefix = file.path(server, var1, "access", type)
  ndays = days_in_month(ymd(sprintf("%d-%d-01", year, month)))
  times = numeric(ndays)
  
  DateStamp("Getting data for", month.name[month], year)
  
    files = sprintf("%s-v2.%04d%02d%02d.nc", type, year, month, 1:ndays)
    url = sprintf("%s/%s%02d/%s", prefix, year, month, files)
    
    download.file(url=url, destfile = file.path(temp, files),
                  method="libcurl", quiet=TRUE, mode = "wb", cacheOK = TRUE)
    
  
  for(day in seq_len(ndays)) {
    
    pb = txtProgressBar(style=3)
    setTxtProgressBar(pb, value=(day-1)/ndays)
    file = sprintf("%s-v2.%04d%02d%02d.nc", type, year, month, day)
 
    nc = nc_open(file=file.path(temp, file))
    
    dlen = ncdim_size(nc)
    
    if(day==1) {
      vSST = array(dim=c(dlen$lon, dlen$lat, dlen$zlev, ndays))
      vERR = array(dim=c(dlen$lon, dlen$lat, dlen$zlev, ndays))
    }
    
    vSST[, , 1, day] = ncvar_get(nc, "sst")
    vERR[, , 1, day] = ncvar_get(nc, "err")
    times[day] = ncvar_get(nc, "time")
    if(day!=ndays) nc_close(nc)
    setTxtProgressBar(pb, value=day/ndays)
    
  }
  
  lon = ncvar_get(nc, "lon")
  lat = ncvar_get(nc, "lat")
  zlev = ncvar_get(nc, "zlev")
  time = mean(times)
  
  sst = apply(vSST, 1:2, mean)
  sst_err = sqrt(apply(vERR^2, 1:2, mean))
  sst_sd = apply(vSST, 1:2, sd)
  sst_min = apply(vSST, 1:2, min)
  sst_max = apply(vSST, 1:2, max)
  
  dimAtts = ncatt_get_all(nc, "dim")
  varAtts = ncatt_get_all(nc, "var")
  
  # create dimensions
  dimLon   = ncdim_def("lon", dimAtts$lon$units, vals=lon)
  dimLat   = ncdim_def("lat", dimAtts$lat$units, vals=lat)
  dimZlev  = ncdim_def("zlev", dimAtts$zlev$units, zlev)
  dimTime  = ncdim_def("time", dimAtts$time$units, time)
  
  # create variables
  
  SST   = ncvar_def(name="sst", units=varAtts$sst$units, 
                    dim=list(dimLon, dimLat, dimZlev, dimTime), 
                    missval=varAtts$sst$'_FillValue', 
                    longname="Monthly sea surface temperature average", 
                    prec=prec, compression=compression)
  # add attributes
  
  MIN   = ncvar_def(name="sst_min", units=varAtts$sst$units, 
                    dim=list(dimLon, dimLat, dimZlev, dimTime), 
                    missval=varAtts$sst$'_FillValue', 
                    longname="Monthly sea surface temperature minimum", prec=prec,
                    compression=compression)
  
  MAX   = ncvar_def(name="sst_max", units=varAtts$sst$units, 
                    dim=list(dimLon, dimLat, dimZlev, dimTime), 
                    missval=varAtts$sst$'_FillValue', 
                    longname="Monthly sea surface temperature maximum", 
                    prec=prec, compression=compression)
  
  SSD   = ncvar_def(name="sst_sd", units=varAtts$sst$units, 
                    dim=list(dimLon, dimLat, dimZlev, dimTime), 
                    missval=varAtts$sst$'_FillValue', 
                    longname="Monthly sea surface temperature standard deviation", 
                    prec=prec, compression=compression)
  
  ERR   = ncvar_def(name="sst_err", units=varAtts$sst$units, 
                    dim=list(dimLon, dimLat, dimZlev, dimTime), 
                    missval=varAtts$sst$'_FillValue', 
                    longname="Estimated error standard deviation of monthly sst", prec=prec,
                    compression=compression)
  
  newPatt = sprintf(".%d%02d.nc4", year, month)
  fileNew = gsub(x=basename(file), patt="\\.[0-9]*\\.nc", newPatt)
  fileNew = file.path(output, fileNew)
  ncNew = nc_create(filename=fileNew, vars=list(SST, SSD, MIN, MAX, ERR), 
                    force_v4=TRUE)
  ncvar_put(ncNew, SST, sst) 
  ncvar_put(ncNew, SSD, sst_sd) 
  ncvar_put(ncNew, MIN, sst_min) 
  ncvar_put(ncNew, MAX, sst_max) 
  ncvar_put(ncNew, ERR, sst_err) 
  nc_close(ncNew)
  
  if(isTRUE(allDays)) {
    
    dimTimes = ncdim_def("time", dimAtts$time$units, times)
    
    fSST   = ncvar_def(name="sst", units=varAtts$sst$units, 
                       dim=list(dimLon, dimLat, dimZlev, dimTimes), 
                       missval=varAtts$sst$'_FillValue', 
                       longname="Daily sea surface temperature average", 
                       prec=prec, compression=compression)
    
    fERR   = ncvar_def(name="err", units=varAtts$sst$units, 
                       dim=list(dimLon, dimLat, dimZlev, dimTimes), 
                       missval=varAtts$sst$'_FillValue', 
                       longname="Estimated error standard deviation of daily sst", prec=prec,
                       compression=compression)
    
    newPatt = sprintf(".%d%02d01-%d%02d%02d.nc4", 
                      year, month, year, month, ndays)
    fileNew = gsub(x=basename(file), patt="\\.[0-9]*\\.nc", newPatt)
    fileNew = file.path(output, fileNew)
    
    ncNew = nc_create(filename=fileNew, vars=list(fSST, fERR), force_v4=TRUE)
    
    ncvar_put(ncNew, fSST, vSST) 
    ncvar_put(ncNew, fERR, vERR) 
    nc_close(ncNew)
    
  }
  
  invisible(file.remove(file.path(temp, files)))
  DateStamp("\nFinishing")
  
  return(invisible(temp))
  
}

# SODA

#' Download SODA (Simple Ocean Data Assimilation) yearly files
#'
#' @param year The year to download data.
#' @param output The folder to store the results, by default the
#' working directory. 
#' @param version The SODA version.
#' @param server The server to download the data.
#'
#' @return 
#' @export
#'
#' @examples
download_soda = function(year, output, version = "3.3.1",
                         server = "http://dsrs.atmos.umd.edu") {
  
  path = sprintf("DATA/soda%s/REGRIDED", version) 
  file = sprintf("soda%s_mn_ocean_reg_%d.nc", version, year)
  url = file.path(server, path, file)
  DateStamp(sprintf("Getting SODA %s data for %d", version, year))
  try(download.file(url=url, destfile = file.path(output, file),
                    method="libcurl", quiet=FALSE, mode = "wb", 
                    cacheOK = FALSE))
  
  return(invisible())
  
}

.getBottom = function(x) {
  out = na.omit(x)
  if(length(out)==0) return(NA)
  return(tail(out, 1))
}

.getBottomC = function(x) {
  out = na.omit(x)
  return(length(out))
}