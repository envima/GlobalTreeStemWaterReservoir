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
                          rainfall_band,
                          landcover_band){
  
  # Land cover data ------------------------------------------------------------
  gdal_translate(file.path(input_path, 
                           "gee_mcd12q1_2010_gldas21_rainf_f_tavg_mean.tif"),
                 file.path(output_path, "gee_mlc_type1.tif"),
                 b = landcover_band)
  
  gee_mlc_type1_forest = raster(file.path(output_path, "gee_mlc_type1.tif"))

  # Forest mask ----------------------------------------------------------------
  # MODIS land cover type 1 IDs: 
  # 1 Evergreen Needleleaf Forests
  # 2 Evergreen Broadleaf Forests 
  # 3	Deciduous Needleleaf Forests
  # 4	Deciduous Broadleaf Forests 
  # 5	Mixed Forests
  gee_mlc_type1_forest[gee_mlc_type1_forest > 5] = NA

  writeRaster(gee_mlc_type1_forest, 
              file.path(output_path, "gee_mlc_type1_forest.tif"), 
              format="GTiff")

  
  # Rainfall data --------------------------------------------------------------
  gdal_translate(file.path(input_path, "gee_1981_2010.tif"),
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
  
  writeRaster(gee_rainf_f_tavg, 
              file.path(output_path, "gee_rainf_f_tavg_m3ha.tif"), 
              format="GTiff")
}
