#' Compile global tree water analysis dataset.
#'
#' @author Thomas Nauss
#' @contributer Pierre L. Ibisch, Jeanette S. Blumröder, Tobias Cremer, 
#' Katharina Lüdicke, Peter R. Hobson, Douglas Sheil
#'


# Set up working environment and defaults --------------------------------------
library(envimaR)
root_folder = path.expand("~/analysis/globalTreeWater/")
source(file.path(root_folder, "EI-GlobalTreeWater/src/functions/000_setup.R"))

# Set projection defaults
source_projection = "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"
target_projection = "EPSG:3857"
output_extends = c(-20040000.000, -19180000.000, 20040000.000, 19180000.000)
output_dimensions = c(8016, 7672)

# Set computation flags
comp_preprocessing = FALSE


# PREPROCESS GLOBAL BIOMASS DATA -----------------------------------------------
# Map global biomass data and error dataset to target projection and set all 
# biomass values of 0 to NA.
# Units of the biomass data are m3/ha. For more details see:
# http://globbiomass.org/wp-content/uploads/GB_Maps/Globbiomass_global_dataset.html
if(comp_preprocessing){
  compileGlobalBiomass(input_path = envrmt$path_biomass_2010_gsv, 
                       output_path = envrmt$path_maped_datasets,
                       source_projection = source_projection, 
                       target_projection = target_projection,
                       output_extends = output_extends,
                       output_dimensions = output_dimensions)
}


# PREPROCESS MODIS land cover and GLDAS 2.1 rainfall data ----------------------
# Units for precipitation are	l/m^2/h
if(comp_preprocessing){
  compileGEEData(input_path = envrmt$path_gee_landcover_rainfall,
                 output_path = envrmt$path_maped_datasets,
                 rainfall_band = 1,
                 landcover_band = 2)
}


# Compile baseline dataset -----------------------------------------------------
if(comp_preprocessing){
  bl = compileBaselineDataset(filepath = envrmt$path_maped_datasets)
} else{
  bl = readRDS(file.path(envrmt$path_rds_data, "baseline_data.rds"))
}


# Compute tree water content ---------------------------------------------------
if(comp_preprocessing){
  tw = compileTreeWaterContent(bl, twc_lut = file.path(
    envrmt$path_tree_water_content, "tree_water_content.txt"))
} else {
  tw = readRDS(file.path(envrmt$path_rds_data, "tw.rds"))
}


# Compute tree water content for each eco region -------------------------------
tw_datasets = c("tree_water_mean", 
                "tree_water_mean_error", 
                "tree_water_mean_per_precipitation")
compileTreeWaterContentEcoReg(tw = tw, tw_datasets = tw_datasets, 
                              ecoreg = file.path(envrmt$path_ecoregions, 
                                            "tnc_terr_ecoregions.shp"))


# Cross check ------------------------------------------------------------------
# Global forest volume: 117 m3/ha (FAO 2000)
## mean(tw[["tree_water_mean"]]) 
