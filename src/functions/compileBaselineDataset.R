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
  bl_files = c("gee_mlc_type1_forest", 
               "gsv_wm_na", "gsv_err_wm_na", 
               "gee_rainf_f_tavg_m3ha")
  bl = stack(file.path(filepath, paste0(bl_files, ".tif")))
  
  # Crop dataset
  ext = extent(bl)
  ext@ymin = -8000000
  bl = crop(bl, ext)
  
  # Mask dataset to valid biomass values (NA indicates <= 0) and 
  # forest areas (NA indicates land cover type > 5)
  
  
  land_see_mask = bl[["gsv_err_wm_na"]]
  
  msk = bl[[1]]
  msk[msk == 17] = NA
  
  blm = mask(bl, msk)
  
  writeRaster(bl, file.path(output_path, "baseline_data.tif"), format="GTiff")
  
  saveRDS(bl, file.path(envrmt$path_rds_data, "baseline_data.rds"))
  
  
  return(bl)
}
