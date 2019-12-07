#' Extract rainfall and land cover data from GEE processed dataseat.
#' 
#' @description Extract rainfall and land cover data from a stacked dataset
#' resulting from a Google Earth Engine processing to individual files.
#'
#' @param input_path path to the input datasets
#' @param output_path path where the individual datasets will be stored
#' @param rainfall_band rainfall layer number within the GEE dataset
#' @param landcover_band landcover layer number within the GEE dataset
#' 
#' @author Thomas Nauss
#' @contributer Pierre L. Ibisch, Jeanette S. Blumröder, Tobias Cremer, 
#' Katharina Lüdicke, Peter R. Hobson, Douglas Sheil
#'

compileGEEData = function(input_path, output_path,
                          landcover_band,
                          rainfall_band){
  
  # Land cover data ------------------------------------------------------------
  gdal_translate(input_path,
                 file.path(output_path, "gee_mlc_type1.tif"),
                 b = landcover_band)
  
  gee_mlc_type1_forest = raster(file.path(output_path, "gee_mlc_type1.tif"))

  # Trim to forest areas -------------------------------------------------------
  # MODIS land cover type 1 IDs: 
  # 1 Evergreen Needleleaf Forests
  # 2 Evergreen Broadleaf Forests 
  # 3	Deciduous Needleleaf Forests
  # 4	Deciduous Broadleaf Forests 
  # 5	Mixed Forests
  gee_mlc_type1_forest[gee_mlc_type1_forest > 5] = NA
  gee_mlc_type1_forest = trim(gee_mlc_type1_forest)

  writeRaster(gee_mlc_type1_forest, 
              file.path(output_path, "gee_mlc_type1_forest.tif"), 
              format="GTiff")

  
  # Rainfall data --------------------------------------------------------------
  gdal_translate(input_path,
                 file.path(output_path, "gee_rainf_f_tavg.tif"),
                 b = rainfall_band)
  
  gee_rainf_f_tavg = raster(file.path(output_path, "gee_rainf_f_tavg.tif"))
  
  # Convert rainfall from kg/m^2/s to m^3/ha/a
  #                                    min hour  day  year      ha    m^3
  gee_rainf_f_tavg = gee_rainf_f_tavg * 60 * 60 * 24 * 365 * 10000 / 1000
  
  # Expand rainfall information along shorlines
  expansion = focal(gee_rainf_f_tavg, w=matrix(1, 21, 21), fun = modal, 
                    na.rm = TRUE)
  gee_rainf_f_tavg = merge(gee_rainf_f_tavg, expansion)
  
  gee_rainf_f_tavg = crop(gee_rainf_f_tavg, gee_mlc_type1_forest)
  
  writeRaster(gee_rainf_f_tavg, 
              file.path(output_path, "gee_rainf_f_tavg_m3ha.tif"), 
              format="GTiff")
  
  return(list(output_extends = extent(gee_mlc_type1_forest), 
              output_dimensions = dim(gee_mlc_type1_forest)))
}
