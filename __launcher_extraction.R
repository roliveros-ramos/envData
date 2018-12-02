
# domain = "biscay-celtic"
# lon = c(-20, +03)
# lat = c(+35, +61)

domain = "humboldt-n"
lon = c(-93, -70)
lat = c(-20, +06)

# create directory
outputDir = file.path("regional", domain) 
if(!dir.exists(outputDir)) dir.create(outputDir, recursive=TRUE)

# extract SST and SSS from SODA v3.3.1
source("01-SODA-extract_regional.R")

# extract NPP from Ocean Productivity web
source("02-NPP-extract_regional.R")

# extract SST from OI-SST (Reynolds)
source("03-OI_SST-extract_regional.R")

# extract DO2 from ROMS-PISCES (RPSoda)
if(domain=="humboldt-n") {
  source("04-DO2-extract_peru.R")
}

