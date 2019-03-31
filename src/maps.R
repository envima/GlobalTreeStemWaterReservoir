library(envimaR)
root_folder = path.expand("~/analysis/global_forest_cover/")
source(file.path(root_folder, "EI-GlobalForestAnalysis/src/000_setup.R"))

# Make pallets
# pal = choose_palette()
# saveRDS(pal, file = file.path(envrmt$path_graphics, "pal_mean_tree_water.rds"))
# saveRDS(pal, file = file.path(envrmt$path_graphics, "pal_tree_water_mean_error.rds"))

# Read datasets and aux data
data(World, metro, rivers)

map_files = list.files(envrmt$path_maped_datasets, pattern = glob2rx("tree_water*.tif"), full.names = TRUE)

maps = list("tree_water_mean", 
            "tree_water_mean_error", 
            "tree_water_mean_per_precipitation")
lables = list(expression("Mean tree water (m"^3*"/ha)"), 
              expression("Mean standard error (m"^3*"/ha)"),
              expression("Mean tree water/annual precipitation"))
pallets = list(brewer.pal(9, "YlGnBu"), brewer.pal(9, "OrRd"), brewer.pal(9, "PuRd"))
prjt = st_crs(54012)

i = 2
for(i in seq(length(maps))){
  act_data = raster(map_files[grep(paste0(maps[[i]], ".tif"), map_files)])
  # act_data = aggregate(act_data, factor = 10)
  # act_data = aggregate(act_data, factor = 10)
  # act_data = aggregate(act_data, factor = 10)
  # act_data = aggregate(act_data, factor = 10)
  
  tmap_mode("plot")
  tmap_style("white")
  map = tm_shape(act_data, projection = prjt) +
    tm_raster(style = "cont", palette = pallets[[i]], title = lables[[i]]) + 
    tm_shape(World, is.master=TRUE) +
    tm_borders("grey20") + 
    tm_grid(projection="longlat", labels.size = .5) + 
    tm_compass(position = c(.74, .14), color.light = "grey90", size = 1.5) +
    # tm_credits("Eckert IV projection", position = c("RIGHT", "BOTTOM")) +
    tm_layout(inner.margins=c(.04,.03, .02, .01), 
              legend.position = c("left", "bottom"), 
              legend.frame = TRUE, 
              legend.title.size = 1.0,
              bg.color="white", 
              legend.bg.color="white", 
              earth.boundary = TRUE, 
              space.color="white")

  tiff(file.path(envrmt$path_graphics, paste0("map_", maps[[i]], ".tif")), width = 3000, height = 3000, res = 300)
  map
  dev.off()
}





# Compute tree water content ---------------------------------------------------
# 1 Evergreen Needleleaf Forests: 
# 2 Evergreen Broadleaf Forests: 
# 3	Deciduous Needleleaf Forests: 
# 4	Deciduous Broadleaf Forests: 
# 5	Mixed Forests: dominated by neither deciduous nor evergreen



writeRaster(act_data, 
            file.path(envrmt$path_maped_datasets, "act_data.tif"),
            format="GTiff", overwrite = TRUE)
writeRaster(tree_water_sd, 
            file.path(envrmt$path_maped_datasets, "tree_water_sd.tif"),
            format="GTiff", overwrite = TRUE)
writeRaster(act_data_error, 
            file.path(envrmt$path_maped_datasets, "act_data_error.tif"),
            format="GTiff", overwrite = TRUE)
writeRaster(act_data_plus_error, 
            file.path(envrmt$path_maped_datasets, "act_data_plus_error.tif"),
            format="GTiff", overwrite = TRUE)
writeRaster(act_data_minus_error, 
            file.path(envrmt$path_maped_datasets, "act_data_minus_error.tif"),
            format="GTiff", overwrite = TRUE)
writeRaster(act_data_per_precipitation, 
            file.path(envrmt$path_maped_datasets, "act_data_per_precipitation.tif"),
            format="GTiff", overwrite = TRUE)
writeRaster(act_data_plus_error_per_precipitation, 
            file.path(envrmt$path_maped_datasets, "act_data_plus_error_per_precipitation.tif"),
            format="GTiff", overwrite = TRUE)
writeRaster(act_data_minus_error_per_precipitation, 
            file.path(envrmt$path_maped_datasets, "act_data_minus_error_per_precipitation.tif"),
            format="GTiff", overwrite = TRUE)
