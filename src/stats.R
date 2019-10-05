library(envimaR)
root_folder = path.expand("~/analysis/global_forest_cover/")
source(file.path(root_folder, "EI-GlobalForestAnalysis/src/000_setup.R"))

# Make pallets
# pal = choose_palette()
# saveRDS(pal, file = file.path(envrmt$path_graphics, "pal_mean_tree_water.rds"))
# saveRDS(pal, file = file.path(envrmt$path_graphics, "pal_tree_water_mean_error.rds"))

# Read datasets and aux data
ecoreg = readOGR(file.path(envrmt$path_ecoregions, "tnc_terr_ecoregions.shp"), layer = "tnc_terr_ecoregions")

map_files = list.files(envrmt$path_maped_datasets, pattern = glob2rx("tree_water*.tif"), full.names = TRUE)


twm = raster(file.path(envrmt$path_maped_datasets, "tree_water_mean.tif"))

# Convert from m3/ha to m3/cell and sum up values
twm_abs = twm * res(twm)[1] * res(twm)[2] / 10000
twm_sum = sum(twm_abs[], na.rm = TRUE)

# Convert from m3 to km3
twm_sum = twm_sum / 1e+09

# Compare to great lakes
gl = 22810
twm_sum/gl
