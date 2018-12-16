library(envimaR)
root_folder = path.expand("~/plygrnd/global_forest_cover/")
source(file.path(root_folder, "EI-GlobalForestAnalysis/src/000_setup.R"))


# Read tree water content ------------------------------------------------------
twc = read.table(file.path(envrmt$path_tree_water_content, 
                           "tree_water_content.txt"),
                 header = TRUE, sep = ",", dec = ".")



# Read global biomass data 1950 to 2010 ----------------------------------------
bm = stack(file.path(envrmt$path_biomass_1950_2010, 
                     "historical_global_1-degree_forest_biomass.nc4"),
           varname = "AGB_ha")
names(bm) = paste0("Y_", seq(1950, 2010, 5))
plot(bm)


# Read global biomass data 200, GSV --------------------------------------------
# http://globbiomass.org/wp-content/uploads/GB_Maps/Globbiomass_global_dataset.html
gsv_files = list.files(envrmt$path_biomass_2010_gsv, 
                       pattern = glob2rx("*gsv.tif"),
                       full.names = TRUE)

i = 1
gsv = stack(gsv_files[i])
gsv_error = stack(paste0(substr(gsv_files[i], 1, nchar(gsv_files[i])-4),
                         "_err.tif"))



# MODIS land cover -------------------------------------------------------------
lc = stack(file.path(envrmt$path_modis_landcover, "MCD12Q1_V6_10000m.tif"))
plot(lc)