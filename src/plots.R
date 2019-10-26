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
maps = list("tree_water_mean", 
            "tree_water_mean_error", 
            "tree_water_mean_per_precipitation")
lables = list(expression("Mean tree water (m"^3*"/ha)"), 
              expression("Mean standard error (m"^3*"/ha)"),
              expression("Mean tree water/annual precipitation"))
pallets = list(brewer.pal(9, "YlGnBu"), brewer.pal(9, "OrRd"), brewer.pal(9, "PuRd"))


i = 1
for(i in seq(length(maps))){
  act_data = raster(map_files[grep(paste0(maps[[i]], ".tif"), map_files)])
  # act_data = aggregate(act_data, factor = 10)
  # act_data = aggregate(act_data, factor = 10)
  # act_data = aggregate(act_data, factor = 10)
  # act_data = aggregate(act_data, factor = 10)
  
  ecoreg_p = spTransform(ecoreg, projection(act_data))
  
  act_extract = extract(act_data, ecoreg_p, df = FALSE)
  saveRDS(act_extract, file = file.path(envrmt$path_graphics, "act_extract.rds"))
  
  act_eco_extr = lapply(seq(length(ecoreg_p)), function(j){
    if(length(act_extract[[j]]) > 0) {
      return(data.frame(MHTNAM = ecoreg_p$WWF_MHTNAM[[j]],
                        VALUES = unlist(act_extract[[j]]),
                        COUNT = j))
    } else {
      return(data.frame(MHTNAM = ecoreg_p$WWF_MHTNAM[[j]],
                        VALUES = NA,
                        COUNT = j))
    }
  })
  act_eco_extr = do.call("rbind", act_eco_extr)
  
  saveRDS(act_eco_extr, file = file.path(envrmt$path_graphics, paste0("ecoregions_", maps[[i]], ".rds")))
  # act_eco_extr = readRDS(file.path(envrmt$path_graphics, paste0("ecoregions_", maps[[i]], ".rds")))
  
  # Calculate fraction of woody vegetated area in the dataset for each ecoregion (based on 5000 x 5000 m )
  frct = lapply(unique(act_eco_extr$MHTNAM), function(c){
    act = act_eco_extr[act_eco_extr$MHTNAM == c,]
    data.frame(MHTNAM = c,
               VALUES_MEAN = mean(act$VALUES, na.rm = TRUE),
               FRAC = round(sum(!is.na(act$VALUES)) / nrow(act), 2))
  })
  frct = do.call("rbind", frct)
  frct$MHTNAM_FRCT = paste0(frct$MHTNAM, " (", frct$FRAC*100, "%)")
  
  # Do not consider selected biomes (forest considered in this study has an aeral fraction of <= 0.01; uncertainties in map projections)
  act_eco_extr_final = act_eco_extr[!(act_eco_extr$MHTNAM %in% c("Tundra","Deserts and Xeric Shrublands", "Rock and Ice", "Inland Water")), ]
  
  act_eco_extr_final = merge(act_eco_extr_final, frct[, grep("MHTNAM", colnames(frct))], by = "MHTNAM")
  
  plt = ggplot(data = act_eco_extr_final, aes(x = MHTNAM_FRCT, y = VALUES)) +
    geom_boxplot() + 
    theme_light() + 
    theme(axis.text.x = element_text(angle = 45, hjust = 1),
          axis.title.x = element_blank()) + 
    labs(y = lables[[i]])
  
  png(file.path(envrmt$path_graphics, paste0("plot_ecoregions_", maps[[i]], ".png")), width = 3000, height = 3000, res = 300)
  plt
  dev.off()
    
}

