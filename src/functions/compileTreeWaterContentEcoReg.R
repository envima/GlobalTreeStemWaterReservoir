#' Compile tree water content for each ecological region
#' 
#' @description Combine biomass dataset tiles into one dataset with a defined
#' projection, extent and resolution and store them as GeoTIFF. Set all pixels
#' with biomass == 0 to NA to exclude them from further consideration.
#'
#' @param tw global tree water content
#' @param tw_datasets datasets within tw to be computed
#' @param ecoreg path to the eco region dataset
#' 
#' @author Thomas Nauss
#' @contributer Pierre L. Ibisch, Jeanette S. Blumröder, Tobias Cremer, 
#' Katharina Lüdicke, Peter R. Hobson, Douglas Sheil
#'

compileTreeWaterContentEcoReg = function(tw, tw_datasets, 
                                         ecoreg){
  
  ecoreg = readOGR(
    ecoreg, layer = substr(basename(ecoreg), 1, nchar(basename(ecoreg))-4))
  
  tw_ecoreg = lapply(tw_datasets, function(d){
    
    ecoreg_p = spTransform(ecoreg, projection(tw[[d]]))
    
    curdat = extract(tw[[d]], ecoreg_p, df = FALSE)
    
    curdat_eco = lapply(seq(length(ecoreg_p)), function(j){
      if(length(curdat[[j]]) > 0) {
        return(data.frame(MHTNAM = ecoreg_p$WWF_MHTNAM[[j]],
                          VALUES = unlist(curdat[[j]]),
                          COUNT = j))
      } else {
        return(data.frame(MHTNAM = ecoreg_p$WWF_MHTNAM[[j]],
                          VALUES = NA,
                          COUNT = j))
      }
    })
    curdat_eco = do.call("rbind", curdat_eco)
    
    # Calculate fraction of woody vegetated area in the dataset for each
    # ecoregion
    curfrct = lapply(unique(curdat_eco$MHTNAM), function(c){
      act = curdat_eco[curdat_eco$MHTNAM == c,]
      data.frame(MHTNAM = c,
                 VALUES_MEAN = mean(act$VALUES, na.rm = TRUE),
                 FRAC = round(sum(!is.na(act$VALUES)) / nrow(act), 2))
    })
    curfrct = do.call("rbind", curfrct)
    curfrct$MHTNAM_FRCT = paste0(curfrct$MHTNAM, " (", curfrct$FRAC*100, "%)")
    
    curdat_eco_final = merge(curdat_eco, 
                             curfrct[, grep("MHTNAM", colnames(curfrct))], 
                             by = "MHTNAM")
    return(list(curdat_eco_final = curdat_eco_final, curfrct = curfrct))
  })
  names(tw_ecoreg) = tw_datasets
  
  saveRDS(tw_ecoreg, file.path(envrmt$path_rds_data, "tw_ecoreg.rds"))
}

# curdat_eco_final = curdat_eco[!(curdat_eco$MHTNAM %in% c("Tundra","Deserts and Xeric Shrublands", "Rock and Ice", "Inland Water")), ]
# curdat_eco_final = merge(curdat_eco_final, frct[, grep("MHTNAM", colnames(frct))], by = "MHTNAM")

