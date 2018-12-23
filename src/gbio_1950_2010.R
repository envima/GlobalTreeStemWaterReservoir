library(envimaR)
root_folder = path.expand("~/analysis/global_forest_cover/")
source(file.path(root_folder, "EI-GlobalForestAnalysis/src/000_setup.R"))


# Read global biomass data 200, GSV --------------------------------------------
# http://globbiomass.org/wp-content/uploads/GB_Maps/Globbiomass_global_dataset.html
gsv_files = list.files(envrmt$path_biomass_2010_gsv, 
                       pattern = glob2rx("*gsv.tif"),
                       full.names = TRUE)

gdalbuildvrt(gsv_files, file.path(envrmt$path_biomass_2010_gsv, "gsv.vrt"), verbose = TRUE)

# target = gdalinfo(file.path(envrmt$path_gee_landcover_rainfall, "gee_1981_2010.tif"))

gdalwarp(file.path(envrmt$path_biomass_2010_gsv, "gsv.vrt"), 
         file.path(envrmt$path_maped_datasets, "gsv_wm.tif"),
         s_srs = "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0 ",
         t_srs = "EPSG:3857",
         # tr = c(5000, 5000),
         te = c(-20040000.000, -19180000.000, 20040000.000, 19180000.000),
         # tap = TRUE,
         ts = c(8016, 7672),
         r = "average",
         verbose=TRUE)









# Read tree water content ------------------------------------------------------
twc = read.table(file.path(envrmt$path_tree_water_content, 
                           "tree_water_content.txt"),
                 header = TRUE, sep = ",", dec = ".")



# Reproject data
for(i in seq(length(gsv_files))){
  gsv_error_filename = paste0(substr(gsv_files[i], 1, nchar(gsv_files[i])-4),
                              "_err.tif")
  
  gdalwarp(gsv_files[i], file.path(envrmt$path_biomass_2010_gsv_wm, basename(gsv_files[i])),
           s_srs = "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0 ",
           t_srs = "EPSG:3857",
           tr = c(5000, 5000),
           r = "average",
           verbose=TRUE)

  
  
  gsv = stack(gsv_files[i])
  gsv_wm = projectRaster(gsv, res = 5000, crs = crs("+init=epsg:3857"), 
                         method="bilinear")
  saveRDS(gsv_wm, file = file.path(envrmt$path_biomass_2010_gsv_wm, 
                                   paste0(substr(basename(gsv_files[i]), 1, (
                                     nchar(basename(gsv_files[i]))-4)), ".rds")))
  rm(gsv, gsv_wm)
  
  gsv_error = stack(gsv_error_filename)
  gsv_error_wm = projectRaster(gsv_error, res = 5000, crs = crs("+init=epsg:3857"), 
                               method="bilinear")
  saveRDS(gsv_error_wm, file = file.path(envrmt$path_biomass_2010_gsv_wm, 
                                   paste0(substr(basename(gsv_error_filename), 1, (
                                     nchar(basename(gsv_error_filename))-4)), ".rds")))
  rm(gsv_error, gsv_error_wm)
  
}


# MODIS land cover and rainfall ------------------------------------------------
lcr = stack(file.path(envrmt$path_gee_landcover_rainfall, "gee_1981_2010.tif"))



