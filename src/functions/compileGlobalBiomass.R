#' Compile global biomass data.
#' 
#' @description Combine biomass dataset tiles into one dataset with a defined
#' projection, extent and resolution and store them as GeoTIFF. Set all pixels
#' with biomass == 0 to NA to exclude them from further consideration.
#'
#' @param input_path path to the biomass datasets
#' @param output_path path where the compiled datasets will be stored
#' @param source_projection projection of the source biomass dataset
#' @param target_projection projection of the compiled dataset
#' @param output_extends extension in map coordinates of the compiled dataset
#' @param output_dimensions dimensions in pixels of the compiled dataset
#' @author Thomas Nauss
#' @contributer Pierre L. Ibisch, Jeanette S. Blumröder, Tobias Cremer, 
#' Katharina Lüdicke, Peter R. Hobson, Douglas Sheil
#'

compileGlobalBiomass = function(input_path, output_path,
                                source_projection, target_projection,
                                output_extends, output_dimensions){
  gsv_files = list.files(input_path, 
                         pattern = glob2rx("*gsv.tif"),
                         full.names = TRUE)
  
  # Combine and project datasets
  gdalbuildvrt(gsv_files, file.path(input_path, "gsv.vrt"), verbose = TRUE)
  gdalbuildvrt(paste0(substr(gsv_files, 1, nchar(gsv_files[1])-4), "_err.tif"), 
               file.path(input_path, "gsv_err.vrt"), verbose = TRUE)
  
  gdalwarp(file.path(input_path, "gsv.vrt"), 
           file.path(output_path, "gsv_wm.tif"),
           s_srs = source_projection,
           t_srs = target_projection,
           te = output_extends,
           ts = output_dimensions,
           r = "average",
           verbose=TRUE)
  
  gdalwarp(file.path(input_path, "gsv_err.vrt"), 
           file.path(output_path, "gsv_err_wm.tif"),
           s_srs = source_projection,
           t_srs = target_projection,
           te = output_extends,
           ts = output_dimensions,
           r = "average",
           verbose=TRUE)
  
  # Set biomass values of 0 to NA
  gsv = raster(file.path(output_path, "gsv_wm.tif"))
  gsv = reclassify(gsv, cbind(-Inf, 0, NA), right=TRUE)
  writeRaster(gsv, file.path(output_path, "gsv_wm_na.tif"), 
              format="GTiff")
  
  map = reclassify(gsv, cbind(0, +Inf, 1), right=TRUE)
  gsv_err = gsv_err * map
  writeRaster(gsv_err, file.path(output_path, "gsv_err_wm_na.tif"), 
              format="GTiff")
}
