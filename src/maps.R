library(envimaR)
root_folder = path.expand("~/analysis/global_forest_cover/")
source(file.path(root_folder, "EI-GlobalForestAnalysis/src/000_setup.R"))

# Make pallets
# pal = choose_palette()
# saveRDS(pal, file = file.path(envrmt$path_graphics, "pal_mean_tree_water.rds"))
# saveRDS(pal, file = file.path(envrmt$path_graphics, "pal_tree_water_mean_error.rds"))

# Read datasets and aux data
data(World, metro, rivers)

ecoreg = readOGR(file.path(envrmt$path_ecoregions, "tnc_terr_ecoregions.shp"), layer = "tnc_terr_ecoregions")
ecoreg_u = unionSpatialPolygons(ecoreg, ecoreg$WWF_MHTNAM)

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
    tm_shape(ecoreg_u) +
    tm_borders("grey40") +
    # tm_shape(World, is.master=TRUE) +
    # tm_borders("grey20") +
    tm_grid(x = seq(-160, 160, 40), y = seq(-60, 60, 30), projection="longlat", col = "grey80", labels.size = .5) +
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
  map
  
  tiff(file.path(envrmt$path_graphics, paste0("map_", maps[[i]], ".tif")), width = 3000, height = 3000, res = 300)
  map
  dev.off()
}


