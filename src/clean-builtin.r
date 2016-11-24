# Clean PROBA-V files using builtin masks
# For Collection 1, should result in clean files; for Collection 0, cleans only partially
# (see clean-timeseries.r for the latter)

library(probaV)
library(tools)
source("utils/GetProbaVQCMask.r")

TileOfInterest = "X20Y01"
QC.vals = GetProbaVQCMask(bluegood=TRUE, redgood=TRUE, nirgood=TRUE, swirgood=TRUE,
    ice=FALSE, cloud=FALSE, shadow=FALSE)
DataDir = "/data/MTDA/TIFFDERIVED/PROBAV_L3_S1_TOC_100M"
NDVIOutputDir = "../../userdata/composite/1day/ndvi"
RadiometryOutputDir = "../../userdata/composite/1day/radiometry"

# Need a list of all YYYYMMDD numbered directories; these are Collection 0
lf = list.files(DataDir)
lf = lf[nchar(lf) == 8]
# Remove empty directories
Col0Dirs = character()
for (dir in lf)
{
    lsf = list.files(paste0(DataDir, "/", dir))
    if (!identical(lsf, character(0)))
        Col0Dirs = c(Col0Dirs, dir)
}
DataDirs = paste0(DataDir,'/',Col0Dirs)

# Also process Collection 1, YYYY/YYYYMMDD
lf = list.files(DataDir)
lf = lf[nchar(lf) == 4]
Col1Dirs = character()
for (dir in lf)
{
    lsf = list.files(paste0(DataDir, "/", dir))
    lsf = lsf[nchar(lsf) == 8]
    Col1Dirs = c(Col1Dirs, paste0(dir,'/',lsf))
}
DataDirs = c(DataDirs, paste0(DataDir,'/',Col1Dirs))

psnice(value = 1)
# First process radiometry (it can then be used for further cleaning of Collection 0)
processProbaVbatch(DataDirs, tiles = TileOfInterest, QC_val = QC.vals, overwrite=FALSE,
    pattern = "RADIOMETRY.tif$", outdir = RadiometryOutputDir, ncores = 2)

# Then process NDVI (for use in time series)
processProbaVbatch(DataDirs, tiles = TileOfInterest, QC_val = QC.vals, overwrite=FALSE,
    pattern = "NDVI.tif$", outdir = NDVIOutputDir, ncores = 2)