#' Compile baseline dataset for tree water analysis.
#' 
#' @description Compile a stack and mask  all datasets to biomass > 0.
#'
#' @param filepath path to the input and output datasets
#' 
#' @return baseline dataset for tree water computation
#' 
#' @author Thomas Nauss
#' @contributer Pierre L. Ibisch, Jeanette S. Blumröder, Tobias Cremer, 
#' Katharina Lüdicke, Peter R. Hobson, Douglas Sheil
#'

compileBaselineDataset = function(filepath){
  
  # Stack datasets
  bl_files = c("gsv_wm_na", 
               "gsv_err_wm_na",
               "gee_mlc_type1_forest", 
               "gee_rainf_f_tavg_m3ha")
  
  bl = stack(file.path(filepath, paste0(bl_files, ".tif")))

  # Mask dataset to valid values in biomass and tree layers and crop dataset to 
  # bounding box of valid values afterwards.
  bl = trim(
    mask(bl, calc(bl[[c("gsv_wm_na","gee_mlc_type1_forest")]], fun = sum)))
  
  writeRaster(bl, file.path(filepath, "baseline_data.tif"), format="GTiff")
  
  saveRDS(bl, file.path(envrmt$path_rds_data, "baseline_data.rds"))

  return(bl)
}


