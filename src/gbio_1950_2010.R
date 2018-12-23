library(envimaR)
root_folder = path.expand("~/analysis/global_forest_cover/")
source(file.path(root_folder, "EI-GlobalForestAnalysis/src/000_setup.R"))



# Read global biomass data 200, GSV and map it to target WM projection ---------
# Units: m3/ha
# http://globbiomass.org/wp-content/uploads/GB_Maps/Globbiomass_global_dataset.html
gsv_files = list.files(envrmt$path_biomass_2010_gsv, 
                       pattern = glob2rx("*gsv.tif"),
                       full.names = TRUE)

gdalbuildvrt(gsv_files, file.path(envrmt$path_biomass_2010_gsv, "gsv.vrt"), verbose = TRUE)
gdalbuildvrt(paste0(substr(gsv_files, 1, nchar(gsv_files[i])-4), "_err.tif"), 
             file.path(envrmt$path_biomass_2010_gsv, "gsv_err.vrt"), verbose = TRUE)

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

gdalwarp(file.path(envrmt$path_biomass_2010_gsv, "gsv_err.vrt"), 
         file.path(envrmt$path_maped_datasets, "gsv_err_wm.tif"),
         s_srs = "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0 ",
         t_srs = "EPSG:3857",
         # tr = c(5000, 5000),
         te = c(-20040000.000, -19180000.000, 20040000.000, 19180000.000),
         # tap = TRUE,
         ts = c(8016, 7672),
         r = "average",
         verbose=TRUE)



# Prepare MODIS land cover and GLDAS 2.1 rainfall ------------------------------
# Units for precipitation: 	l/m^2/h
gdal_translate(file.path(envrmt$path_gee_landcover_rainfall, "gee_1981_2010.tif"),
               file.path(envrmt$path_maped_datasets, "gee_rainf_f_tavg.tif"),
               b = 1)
  
gdal_translate(file.path(envrmt$path_gee_landcover_rainfall, "gee_1981_2010.tif"),
               file.path(envrmt$path_maped_datasets, "gee_mlc_type1.tif"),
               b = 2)


# Prepare baseline dataset -----------------------------------------------------
bl_files = list.files(envrmt$path_maped_datasets, pattern = glob2rx("*.tif"),
           full.names = TRUE)
bl = stack(bl_files)

# Expand rainfall information along shorlines
rainfall = focal(bl[[2]], w=matrix(1,21,21), fun = modal, na.rm = TRUE)
bl[[2]] = merge(bl[[2]], rainfall)

# Convert rainfall from l/m2/h to m3/ha on an annual average
bl[[2]] = bl[[2]] * 24*365/1000*10000

# Crop and mask
ext = extent(bl)
ext@ymin = -8000000
bl = crop(bl, ext)

msk = bl[[1]]
msk[msk == 17] = NA

blm = mask(bl, msk)
saveRDS(blm, file.path(envrmt$path_maped_datasets, "baseline_data.rds"))

# Documentation only
writeRaster(msk, file.path(envrmt$path_maped_datasets, "msk.tif"),
            format="GTiff", overwrite = TRUE)
# writeRaster(rainfall, file.path(envrmt$path_maped_datasets, "rainfall.tif"),
#             format="GTiff", overwrite = TRUE)
writeRaster(blm, file.path(envrmt$path_maped_datasets, "baseline_data.tif"),
            format="GTiff", overwrite = TRUE)



# Read tree water content ------------------------------------------------------
twc = read.table(file.path(envrmt$path_tree_water_content, 
                           "tree_water_content.txt"),
                 header = TRUE, sep = ",", dec = ".")



# Compute tree water content ---------------------------------------------------
# 1 Evergreen Needleleaf Forests: 
# 2 Evergreen Broadleaf Forests: 
# 3	Deciduous Needleleaf Forests: 
# 4	Deciduous Broadleaf Forests: 
# 5	Mixed Forests: dominated by neither deciduous nor evergreen

forest_mask = blm[[1]]
forest_mask[forest_mask > 5] = NA

calcTWC = function(data, forest_mask, twc){
  data = mask(data, forest_mask)
  data[forest_mask == 1 | forest_mask == 3] = 
    data[forest_mask == 1 | forest_mask == 3] * twc[2]/100
  data[forest_mask == 2 | forest_mask == 4] = 
    data[forest_mask == 2 | forest_mask == 4] * twc[1]/100
  data[forest_mask == 5] = 
    data[forest_mask == 5] * mean(twc)/100
  return(data)
}

tree_water_mean = calcTWC(blm[[4]], forest_mask, twc$Mean)
tree_water_sd = calcTWC(blm[[4]], forest_mask, twc$SDev)
tree_water_mean_error = calcTWC(blm[[3]], forest_mask, twc$Mean)
tree_water_mean_plus_error = tree_water_mean + tree_water_mean_error
tree_water_mean_minus_error = tree_water_mean - tree_water_mean_error
tree_water_mean_per_precipitation = tree_water_mean / blm[[2]]
tree_water_mean_plus_error_per_precipitation = tree_water_mean_plus_error / blm[[2]]
tree_water_mean_minus_error_per_precipitation = tree_water_mean_minus_error / blm[[2]]

mean(getValues(tree_water_mean_per_precipitation), na.rm = TRUE)

writeRaster(tree_water_mean, 
            file.path(envrmt$path_maped_datasets, "tree_water_mean.tif"),
            format="GTiff", overwrite = TRUE)
writeRaster(tree_water_sd, 
            file.path(envrmt$path_maped_datasets, "tree_water_sd.tif"),
            format="GTiff", overwrite = TRUE)
writeRaster(tree_water_mean_error, 
            file.path(envrmt$path_maped_datasets, "tree_water_mean_error.tif"),
            format="GTiff", overwrite = TRUE)
writeRaster(tree_water_mean_plus_error, 
            file.path(envrmt$path_maped_datasets, "tree_water_mean_plus_error.tif"),
            format="GTiff", overwrite = TRUE)
writeRaster(tree_water_mean_minus_error, 
            file.path(envrmt$path_maped_datasets, "tree_water_mean_minus_error.tif"),
            format="GTiff", overwrite = TRUE)
writeRaster(tree_water_mean_per_precipitation, 
            file.path(envrmt$path_maped_datasets, "tree_water_mean_per_precipitation.tif"),
            format="GTiff", overwrite = TRUE)
writeRaster(tree_water_mean_plus_error_per_precipitation, 
            file.path(envrmt$path_maped_datasets, "tree_water_mean_plus_error_per_precipitation.tif"),
            format="GTiff", overwrite = TRUE)
writeRaster(tree_water_mean_minus_error_per_precipitation, 
            file.path(envrmt$path_maped_datasets, "tree_water_mean_minus_error_per_precipitation.tif"),
            format="GTiff", overwrite = TRUE)
