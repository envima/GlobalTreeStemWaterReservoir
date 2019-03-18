library(envimaR)
root_folder = path.expand("~/analysis/global_forest_cover/")
source(file.path(root_folder, "EI-GlobalForestAnalysis/src/000_setup.R"))

tree_water_mean = raster(file.path(envrmt$path_maped_datasets, "tree_water_mean.tif"))
twm = aggregate(tree_water_mean, factor = 10)
twm = aggregate(twm, factor = 10)
twm = aggregate(twm, factor = 10)
twm = aggregate(twm, factor = 10)



data(World, metro, rivers)
pal = choose_palette()

ltwm = expression("Mean tree water (m"^3*"/ha)")
ptwm = rev(pal(50))
prjt = st_crs(54012)


tmap_mode("plot")
tmap_style("white")
tm_shape(twm, projection = prjt) +
  tm_raster(style = "cont", palette = ptwm, title = ltwm) + 
  tm_shape(World, is.master=TRUE) +
  tm_borders("grey20") + 
  tm_grid(projection="longlat", labels.size = .5) + 
  tm_compass(position = c(.70, .15), color.light = "grey90") +
  tm_credits("Eckert IV projection", position = c("RIGHT", "BOTTOM")) +
  tm_layout(inner.margins=c(.04,.03, .02, .01), 
            legend.position = c("left", "bottom"), 
            legend.frame = TRUE, 
            bg.color="white", 
            legend.bg.color="white", 
            earth.boundary = TRUE, 
            space.color="white")


# Compute tree water content ---------------------------------------------------
# 1 Evergreen Needleleaf Forests: 
# 2 Evergreen Broadleaf Forests: 
# 3	Deciduous Needleleaf Forests: 
# 4	Deciduous Broadleaf Forests: 
# 5	Mixed Forests: dominated by neither deciduous nor evergreen



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
