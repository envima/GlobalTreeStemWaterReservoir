#' Analyse and plot global tree water data.
#'
#' @author Thomas Nauss
#' @contributer Pierre L. Ibisch, Jeanette S. Blumröder, Tobias Cremer, 
#' Katharina Lüdicke, Peter R. Hobson, Douglas Sheil
#'


# Set up working environment and defaults --------------------------------------
library(envimaR)
root_folder = path.expand("~/analysis/globalTreeWater/")
source(file.path(root_folder, "EI-GlobalTreeWater/src/functions/000_setup.R"))


# Plot global tree water by ecoregion ------------------------------------------
tw_ecoreg = readRDS(file.path(envrmt$path_rds_data, "tw_ecoreg.rds"))

# Do not consider regions with fractional woody cover <= 0.01 caused by 
# uncertainties in map projections etc.
non_forest_ecoregions = 
  tw_ecoreg$twc_mean$curfrct$MHTNAM[tw_ecoreg$twc_mean$curfrct$FRAC<=0.01]

tw_information = c("twc_mean", 
                   "twc_error", 
                   "twc_mean_precip")

lables = list(expression("Mean tree water (m"^3*"/ha)"), 
              expression("Mean standard error (m"^3*"/ha)"),
              expression("Mean tree water/annual precipitation"))

for(i in seq(length(tw_information))){
  info = tw_information[i]
  
  plt = ggplot(data = tw_ecoreg[[info]]$curdat_eco_final[
    !(tw_ecoreg[[info]]$curdat_eco_final$MHTNAM %in% non_forest_ecoregions), ], 
    aes(x = MHTNAM, y = VALUES)) +
    geom_boxplot() + 
    theme_light() + 
    theme(axis.text.x = element_text(angle = 45, hjust = 1),
          axis.title.x = element_blank()) + 
    labs(y = lables[[i]])
  
  png(file.path(envrmt$path_graphics, paste0("plot_ecoregions_", info, ".png")),
      width = 3000, height = 3000, res = 300)
  plot(plt)
  dev.off()
  
  plt = ggplot(data = tw_ecoreg[[info]]$curdat_eco_final[
    !(tw_ecoreg[[info]]$curdat_eco_final$MHTNAM %in% non_forest_ecoregions), ], 
    aes(x = MHTNAM_FRCT, y = VALUES)) +
    geom_boxplot() + 
    theme_light() + 
    theme(axis.text.x = element_text(angle = 45, hjust = 1),
          axis.title.x = element_blank()) + 
    labs(y = lables[[i]])
  
  png(file.path(envrmt$path_graphics, 
                paste0("plot_ecoregions_", info, "_frac.png")),
      width = 3000, height = 3000, res = 300)
  plot(plt)
  dev.off()
}


# Plot global tree water maps --------------------------------------------------
data(World, metro, rivers)

ecoreg = readOGR(file.path(envrmt$path_ecoregions, "tnc_terr_ecoregions.shp"), 
                 layer = "tnc_terr_ecoregions")
ecoreg_u = unionSpatialPolygons(ecoreg, ecoreg$WWF_MHTNAM)

tw = readRDS(file.path(envrmt$path_rds_data, "tw.rds"))

maps = c("twc_mean", 
         "twc_error", 
         "twc_mean_precip")

lables = list(expression("Mean tree water (m"^3*"/ha)"), 
              expression("Mean standard error (m"^3*"/ha)"),
              expression("Mean tree water/annual precipitation"))

pallets = list(brewer.pal(9, "YlGnBu"), 
               brewer.pal(9, "OrRd"), 
               brewer.pal(9, "PuRd"))

prjt = st_crs(54012)

for(i in seq(length(maps))){
  tmap_mode("plot")
  tmap_style("white")
  map = tm_shape(tw[[maps[i]]], projection = prjt) +
    tm_raster(style = "cont", palette = pallets[[i]], title = lables[[i]]) + 
    tm_shape(ecoreg_u) +
    tm_borders("grey40") +
    # tm_shape(World, is.master=TRUE) +
    # tm_borders("grey20") +
    tm_grid(x = seq(-160, 160, 40), y = seq(-60, 60, 30), 
            projection="longlat", col = "grey80", labels.size = .5) +
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
  
  tiff(file.path(envrmt$path_graphics, paste0("map_", maps[[i]], ".tif")), 
       width = 3000, height = 3000, res = 300)
  print(map)
  dev.off()
}
